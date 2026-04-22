const { AppError } = require('../errors');

function normalizeCoupleId(coupleId) {
  const trimmed = String(coupleId || '').trim();
  if (!trimmed) throw new AppError('invalid_request', 'coupleId is required');
  return trimmed;
}

function normalizeCurrentUserId(currentUserId) {
  const trimmed = String(currentUserId || '').trim();
  if (!trimmed) throw new AppError('invalid_request', 'currentUserId is required');
  return trimmed;
}

function normalizeSince(since) {
  const value = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (!value) return null;
  if (Number.isNaN(Date.parse(value))) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }
  return value;
}

async function ensureCouple(client, coupleId) {
  const res = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (res.rowCount === 0) throw new AppError('couple_not_found', 'Couple not found', 404);
  return res.rows[0];
}

function ensureCoupleMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function getPartnerUserId(couple, currentUserId) {
  return currentUserId === couple.user1_id ? couple.user2_id : couple.user1_id;
}

function parseDoneUserIds(raw) {
  if (!raw || !String(raw).trim()) return [];
  try {
    const decoded = JSON.parse(raw);
    if (Array.isArray(decoded)) {
      return decoded.filter((item) => typeof item === 'string' && item.trim());
    }
  } catch (_) {}
  return [];
}

function mapTodoRow(row, couple, currentUserId) {
  const partnerUserId = getPartnerUserId(couple, currentUserId);
  const doneUserIds = parseDoneUserIds(row.done_user_ids);
  let owner = 'shared';
  if (row.owner_type !== 'shared' && row.owner_user_id) {
    owner = row.owner_user_id === currentUserId ? 'me' : 'partner';
  }
  return {
    id: row.id,
    coupleId: row.couple_id,
    title: row.title,
    description: row.description,
    dueAt: row.due_at,
    owner,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    isDeleted: row.is_deleted === true,
    meDone: doneUserIds.includes(currentUserId),
    partnerDone: doneUserIds.includes(partnerUserId),
  };
}

function normalizeTodoPayload(couple, currentUserId, payload) {
  const id = String(payload.id || '').trim();
  const title = String(payload.title || '').trim();
  const description = String(payload.description || '').trim();
  const owner = String(payload.owner || 'shared').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();
  const dueAt = payload.dueAt == null ? null : String(payload.dueAt).trim();
  if (!id || !title) throw new AppError('invalid_request', 'id and title are required');
  if (!createdAt || Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (!updatedAt || Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }
  if (dueAt && Number.isNaN(Date.parse(dueAt))) {
    throw new AppError('invalid_request', 'dueAt must be a valid ISO timestamp');
  }
  const partnerUserId = getPartnerUserId(couple, currentUserId);
  let ownerType = 'shared';
  let ownerUserId = null;
  if (owner === 'me') {
    ownerType = 'single';
    ownerUserId = currentUserId;
  } else if (owner === 'partner') {
    ownerType = 'single';
    ownerUserId = partnerUserId;
  }
  const doneUserIds = [];
  if (payload.meDone === true) doneUserIds.push(currentUserId);
  if (payload.partnerDone === true) doneUserIds.push(partnerUserId);
  return {
    id,
    title,
    description,
    dueAt,
    ownerType,
    ownerUserId,
    createdAt,
    updatedAt,
    isDeleted: payload.isDeleted === true,
    doneUserIds: JSON.stringify(doneUserIds),
  };
}

async function listTodoItemsPg(pool, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const trimmedCurrentUserId = normalizeCurrentUserId(currentUserId);
  const sinceValue = normalizeSince(since);
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureCoupleMember(couple, trimmedCurrentUserId);
    const rows = sinceValue
      ? await client.query(
          `
          SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                 created_at, updated_at, is_deleted, done_user_ids
          FROM todo_items
          WHERE couple_id = $1 AND updated_at > $2
          ORDER BY updated_at ASC, id ASC
          `,
          [trimmedCoupleId, sinceValue],
        )
      : await client.query(
          `
          SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                 created_at, updated_at, is_deleted, done_user_ids
          FROM todo_items
          WHERE couple_id = $1
          ORDER BY updated_at ASC, id ASC
          `,
          [trimmedCoupleId],
        );
    return rows.rows.map((row) => mapTodoRow(row, couple, trimmedCurrentUserId));
  } finally {
    client.release();
  }
}

async function upsertTodoItemPg(pool, payload) {
  const coupleId = normalizeCoupleId(payload.coupleId);
  const currentUserId = normalizeCurrentUserId(payload.currentUserId);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureCoupleMember(couple, currentUserId);
    const todo = normalizeTodoPayload(couple, currentUserId, payload);

    const existingRes = await client.query(
      `
      SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
             created_at, updated_at, is_deleted, done_user_ids
      FROM todo_items
      WHERE id = $1 AND couple_id = $2
      `,
      [todo.id, coupleId],
    );
    const existing = existingRes.rows[0];
    if (existing && Date.parse(existing.updated_at) > Date.parse(todo.updatedAt)) {
      await client.query('COMMIT');
      return mapTodoRow(existing, couple, currentUserId);
    }

    if (existing) {
      await client.query(
        `
        UPDATE todo_items
        SET title = $1, description = $2, due_at = $3, owner_type = $4, owner_user_id = $5,
            created_at = $6, updated_at = $7, is_deleted = $8, done_user_ids = $9
        WHERE id = $10 AND couple_id = $11
        `,
        [
          todo.title,
          todo.description,
          todo.dueAt,
          todo.ownerType,
          todo.ownerUserId,
          todo.createdAt,
          todo.updatedAt,
          todo.isDeleted,
          todo.doneUserIds,
          todo.id,
          coupleId,
        ],
      );
    } else {
      await client.query(
        `
        INSERT INTO todo_items (
          id, couple_id, title, description, due_at, owner_type, owner_user_id,
          created_at, updated_at, is_deleted, done_user_ids
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
        `,
        [
          todo.id,
          coupleId,
          todo.title,
          todo.description,
          todo.dueAt,
          todo.ownerType,
          todo.ownerUserId,
          todo.createdAt,
          todo.updatedAt,
          todo.isDeleted,
          todo.doneUserIds,
        ],
      );
    }

    const latest = await client.query(
      `
      SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
             created_at, updated_at, is_deleted, done_user_ids
      FROM todo_items
      WHERE id = $1 AND couple_id = $2
      `,
      [todo.id, coupleId],
    );
    await client.query('COMMIT');
    return mapTodoRow(latest.rows[0], couple, currentUserId);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteTodoItemPg(pool, { coupleId, id, updatedAt }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const trimmedId = String(id || '').trim();
  const trimmedUpdatedAt = String(updatedAt || '').trim();
  if (!trimmedId || !trimmedUpdatedAt || Number.isNaN(Date.parse(trimmedUpdatedAt))) {
    throw new AppError('invalid_request', 'id and updatedAt are required');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCouple(client, trimmedCoupleId);
    const existing = await client.query(
      'SELECT updated_at FROM todo_items WHERE id = $1 AND couple_id = $2',
      [trimmedId, trimmedCoupleId],
    );
    if (existing.rowCount > 0 && Date.parse(existing.rows[0].updated_at) > Date.parse(trimmedUpdatedAt)) {
      await client.query('COMMIT');
      return { ok: true };
    }
    await client.query(
      `
      UPDATE todo_items
      SET is_deleted = true, updated_at = $1
      WHERE id = $2 AND couple_id = $3
      `,
      [trimmedUpdatedAt, trimmedId, trimmedCoupleId],
    );
    await client.query('COMMIT');
    return { ok: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listTodoItemsPg,
  upsertTodoItemPg,
  deleteTodoItemPg,
};

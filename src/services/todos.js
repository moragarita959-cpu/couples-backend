const { AppError } = require('../errors');

function ensureCouple(db, coupleId) {
  const couple = db
    .prepare('SELECT id, user1_id, user2_id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');
  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return couple;
}

function ensureCoupleMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function normalizeCoupleId(coupleId) {
  const trimmed = String(coupleId || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', 'coupleId is required');
  }
  return trimmed;
}

function normalizeCurrentUserId(currentUserId) {
  const trimmed = String(currentUserId || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', 'currentUserId is required');
  }
  return trimmed;
}

function getPartnerUserId(couple, currentUserId) {
  return currentUserId === couple.user1_id ? couple.user2_id : couple.user1_id;
}

function parseDoneUserIds(raw) {
  if (!raw || !String(raw).trim()) {
    return [];
  }
  try {
    const decoded = JSON.parse(raw);
    if (Array.isArray(decoded)) {
      return decoded.filter((item) => typeof item === 'string' && item.trim());
    }
  } catch (_) {
    return [];
  }
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
    isDeleted: row.is_deleted === 1,
    meDone: doneUserIds.includes(currentUserId),
    partnerDone: doneUserIds.includes(partnerUserId),
  };
}

function normalizeSince(since) {
  const value = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (!value) {
    return null;
  }
  if (Number.isNaN(Date.parse(value))) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }
  return value;
}

function listTodoItems(db, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const trimmedCurrentUserId = normalizeCurrentUserId(currentUserId);
  const sinceValue = normalizeSince(since);
  const couple = ensureCouple(db, trimmedCoupleId);
  ensureCoupleMember(couple, trimmedCurrentUserId);

  const rows = sinceValue
    ? db
        .prepare(
          `
            SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                   created_at, updated_at, is_deleted, done_user_ids
            FROM todo_items
            WHERE couple_id = ? AND updated_at > ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId, sinceValue)
    : db
        .prepare(
          `
            SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                   created_at, updated_at, is_deleted, done_user_ids
            FROM todo_items
            WHERE couple_id = ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId);

  return rows.map((row) => mapTodoRow(row, couple, trimmedCurrentUserId));
}

function normalizeTodoPayload(couple, currentUserId, payload) {
  const id = String(payload.id || '').trim();
  const title = String(payload.title || '').trim();
  const description = String(payload.description || '').trim();
  const owner = String(payload.owner || 'shared').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();
  const dueAt = payload.dueAt == null ? null : String(payload.dueAt).trim();

  if (!id || !title) {
    throw new AppError('invalid_request', 'id and title are required');
  }
  if (!createdAt || Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (!updatedAt || Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }
  if (dueAt && Number.isNaN(Date.parse(dueAt))) {
    throw new AppError('invalid_request', 'dueAt must be a valid ISO timestamp');
  }

  let ownerUserId = null;
  let ownerType = 'shared';
  const partnerUserId = getPartnerUserId(couple, currentUserId);
  if (owner === 'me') {
    ownerType = 'single';
    ownerUserId = currentUserId;
  } else if (owner === 'partner') {
    ownerType = 'single';
    ownerUserId = partnerUserId;
  }

  const doneUserIds = [];
  if (payload.meDone === true) {
    doneUserIds.push(currentUserId);
  }
  if (payload.partnerDone === true) {
    doneUserIds.push(partnerUserId);
  }

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

function upsertTodoItem(db, payload) {
  const coupleId = normalizeCoupleId(payload.coupleId);
  const currentUserId = normalizeCurrentUserId(payload.currentUserId);

  const transaction = db.transaction(() => {
    const couple = ensureCouple(db, coupleId);
    ensureCoupleMember(couple, currentUserId);
    const todo = normalizeTodoPayload(couple, currentUserId, payload);

    const existing = db
      .prepare(
        `
          SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                 created_at, updated_at, is_deleted, done_user_ids
          FROM todo_items
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(todo.id, coupleId);

    if (existing && Date.parse(existing.updated_at) > Date.parse(todo.updatedAt)) {
      return mapTodoRow(existing, couple, currentUserId);
    }

    if (existing) {
      db.prepare(
        `
          UPDATE todo_items
          SET title = ?, description = ?, due_at = ?, owner_type = ?, owner_user_id = ?,
              created_at = ?, updated_at = ?, is_deleted = ?, done_user_ids = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(
        todo.title,
        todo.description,
        todo.dueAt,
        todo.ownerType,
        todo.ownerUserId,
        todo.createdAt,
        todo.updatedAt,
        todo.isDeleted ? 1 : 0,
        todo.doneUserIds,
        todo.id,
        coupleId,
      );
    } else {
      db.prepare(
        `
          INSERT INTO todo_items (
            id, couple_id, title, description, due_at, owner_type, owner_user_id,
            created_at, updated_at, is_deleted, done_user_ids
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
      ).run(
        todo.id,
        coupleId,
        todo.title,
        todo.description,
        todo.dueAt,
        todo.ownerType,
        todo.ownerUserId,
        todo.createdAt,
        todo.updatedAt,
        todo.isDeleted ? 1 : 0,
        todo.doneUserIds,
      );
    }

    const latest = db
      .prepare(
        `
          SELECT id, couple_id, title, description, due_at, owner_type, owner_user_id,
                 created_at, updated_at, is_deleted, done_user_ids
          FROM todo_items
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(todo.id, coupleId);
    return mapTodoRow(latest, couple, currentUserId);
  });

  return transaction();
}

function deleteTodoItem(db, { coupleId, id, updatedAt }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const trimmedId = String(id || '').trim();
  const trimmedUpdatedAt = String(updatedAt || '').trim();
  if (!trimmedId || !trimmedUpdatedAt || Number.isNaN(Date.parse(trimmedUpdatedAt))) {
    throw new AppError('invalid_request', 'id and updatedAt are required');
  }

  const transaction = db.transaction(() => {
    ensureCouple(db, trimmedCoupleId);
    const existing = db
      .prepare(
        `
          SELECT updated_at
          FROM todo_items
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(trimmedId, trimmedCoupleId);

    if (existing && Date.parse(existing.updated_at) > Date.parse(trimmedUpdatedAt)) {
      return { ok: true };
    }

    db.prepare(
      `
        UPDATE todo_items
        SET is_deleted = 1, updated_at = ?
        WHERE id = ? AND couple_id = ?
      `,
    ).run(trimmedUpdatedAt, trimmedId, trimmedCoupleId);
    return { ok: true };
  });

  return transaction();
}

module.exports = {
  listTodoItems,
  upsertTodoItem,
  deleteTodoItem,
};

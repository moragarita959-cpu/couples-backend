const { AppError } = require('../errors');

async function ensureCoupleExistsPg(client, coupleId) {
  const result = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return result.rows[0];
}

async function ensureActorInCouplePg(client, coupleId, actorUserId) {
  const trimmedActor = String(actorUserId || '').trim();
  if (!trimmedActor) {
    throw new AppError('invalid_request', 'actorUserId is required');
  }
  const couple = await ensureCoupleExistsPg(client, coupleId);
  if (couple.user1_id !== trimmedActor && couple.user2_id !== trimmedActor) {
    throw new AppError('forbidden', 'actorUserId is not a member of this couple', 403);
  }
  return trimmedActor;
}

function normalizeCoupleId(coupleId) {
  const trimmed = String(coupleId || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', 'coupleId is required');
  }
  return trimmed;
}

function normalizeSince(since) {
  const sinceValue = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (!sinceValue) {
    return null;
  }
  const timestamp = Date.parse(sinceValue);
  if (Number.isNaN(timestamp)) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }
  return sinceValue;
}

function normalizeBillPayload(payload) {
  const id = String(payload.id || '').trim();
  const coupleId = normalizeCoupleId(payload.coupleId);
  const type = String(payload.type || '').trim();
  const category = String(payload.category || 'other.misc').trim() || 'other.misc';
  const note = String(payload.note || '').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();
  const isDeleted = payload.isDeleted === true;
  const amount = Number(payload.amount);
  const ownerUserId = String(payload.ownerUserId || '').trim();

  if (!id) {
    throw new AppError('invalid_request', 'id is required');
  }
  if (type !== 'income' && type !== 'expense') {
    throw new AppError('invalid_request', 'type must be income or expense');
  }
  if (!Number.isFinite(amount) || amount < 0) {
    throw new AppError('invalid_request', 'amount must be a valid number');
  }
  if (!createdAt || Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (!updatedAt || Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  return {
    id,
    coupleId,
    ownerUserId,
    type,
    category,
    amount,
    note,
    createdAt,
    updatedAt,
    isDeleted,
  };
}

function mapBillRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    ownerUserId: row.owner_user_id != null ? String(row.owner_user_id) : '',
    type: row.type,
    category: row.category,
    amount: Number(row.amount),
    note: row.note || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    isDeleted: row.is_deleted === true,
  };
}

async function listBillRecordsPg(pool, { coupleId, since }) {
  const normalizedCoupleId = normalizeCoupleId(coupleId);
  const normalizedSince = normalizeSince(since);
  const client = await pool.connect();
  try {
    await ensureCoupleExistsPg(client, normalizedCoupleId);
  } finally {
    client.release();
  }

  const rows = normalizedSince
    ? await pool.query(
        `
          SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE couple_id = $1 AND updated_at > $2
          ORDER BY updated_at ASC, id ASC
        `,
        [normalizedCoupleId, normalizedSince],
      )
    : await pool.query(
        `
          SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE couple_id = $1
          ORDER BY updated_at ASC, id ASC
        `,
        [normalizedCoupleId],
      );

  return rows.rows.map(mapBillRow);
}

async function upsertBillRecordPg(pool, payload) {
  const bill = normalizeBillPayload(payload || {});
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const actorUserId = await ensureActorInCouplePg(client, bill.coupleId, (payload || {}).actorUserId);

    const existingRes = await client.query(
      `
        SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
        FROM bill_records
        WHERE id = $1 AND couple_id = $2
      `,
      [bill.id, bill.coupleId],
    );
    const existing = existingRes.rows[0];

    if (existing) {
      if (Date.parse(existing.updated_at) > Date.parse(bill.updatedAt)) {
        await client.query('COMMIT');
        return mapBillRow(existing);
      }

      const existingOwner = existing.owner_user_id != null ? String(existing.owner_user_id) : '';
      if (!existingOwner) {
        throw new AppError('forbidden', 'Cannot modify bill without owner (legacy row)', 403);
      }
      if (existingOwner !== actorUserId) {
        throw new AppError('forbidden', 'Cannot modify another user bill', 403);
      }

      await client.query(
        `
          UPDATE bill_records
          SET type = $1, category = $2, amount = $3, note = $4, created_at = $5, updated_at = $6, is_deleted = $7, owner_user_id = $8
          WHERE id = $9 AND couple_id = $10
        `,
        [
          bill.type,
          bill.category,
          bill.amount,
          bill.note,
          bill.createdAt,
          bill.updatedAt,
          bill.isDeleted,
          existingOwner,
          bill.id,
          bill.coupleId,
        ],
      );
    } else {
      if (!bill.ownerUserId || bill.ownerUserId !== actorUserId) {
        throw new AppError('invalid_request', 'ownerUserId must match actorUserId for new bills');
      }
      await client.query(
        `
          INSERT INTO bill_records (
            id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        `,
        [
          bill.id,
          bill.coupleId,
          bill.ownerUserId,
          bill.type,
          bill.category,
          bill.amount,
          bill.note,
          bill.createdAt,
          bill.updatedAt,
          bill.isDeleted,
        ],
      );
    }

    const latestRes = await client.query(
      `
        SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
        FROM bill_records
        WHERE id = $1 AND couple_id = $2
      `,
      [bill.id, bill.coupleId],
    );
    await client.query('COMMIT');
    return mapBillRow(latestRes.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteBillRecordPg(pool, payload) {
  const normalizedCoupleId = normalizeCoupleId((payload || {}).coupleId);
  const normalizedId = String((payload || {}).id || '').trim();
  const normalizedUpdatedAt = String((payload || {}).updatedAt || '').trim();
  if (!normalizedId) {
    throw new AppError('invalid_request', 'id is required');
  }
  if (!normalizedUpdatedAt || Number.isNaN(Date.parse(normalizedUpdatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const actorUserId = await ensureActorInCouplePg(client, normalizedCoupleId, (payload || {}).actorUserId);

    const existingRes = await client.query(
      `
        SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
        FROM bill_records
        WHERE id = $1 AND couple_id = $2
      `,
      [normalizedId, normalizedCoupleId],
    );
    const existing = existingRes.rows[0];
    if (!existing) {
      await client.query('COMMIT');
      return {
        id: normalizedId,
        coupleId: normalizedCoupleId,
        ownerUserId: actorUserId,
        updatedAt: normalizedUpdatedAt,
        isDeleted: true,
      };
    }

    const existingOwner = existing.owner_user_id != null ? String(existing.owner_user_id) : '';
    if (!existingOwner) {
      throw new AppError('forbidden', 'Cannot delete legacy bill without owner', 403);
    }
    if (existingOwner !== actorUserId) {
      throw new AppError('forbidden', 'Cannot delete another user bill', 403);
    }
    if (Date.parse(existing.updated_at) > Date.parse(normalizedUpdatedAt)) {
      await client.query('COMMIT');
      return mapBillRow(existing);
    }

    await client.query(
      `
        UPDATE bill_records
        SET is_deleted = true, updated_at = $1
        WHERE id = $2 AND couple_id = $3
      `,
      [normalizedUpdatedAt, normalizedId, normalizedCoupleId],
    );

    const latestRes = await client.query(
      `
        SELECT id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
        FROM bill_records
        WHERE id = $1 AND couple_id = $2
      `,
      [normalizedId, normalizedCoupleId],
    );
    await client.query('COMMIT');
    return mapBillRow(latestRes.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listBillRecordsPg,
  upsertBillRecordPg,
  deleteBillRecordPg,
};

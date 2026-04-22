const { AppError } = require('../errors');

function normalizeCoupleId(coupleId) {
  const trimmed = String(coupleId || '').trim();
  if (!trimmed) throw new AppError('invalid_request', 'coupleId is required');
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
  const result = await client.query('SELECT id FROM couples WHERE id = $1 AND status = $2', [
    coupleId,
    'active',
  ]);
  if (result.rowCount === 0) throw new AppError('couple_not_found', 'Couple not found', 404);
}

function normalizePayload(payload) {
  const id = String(payload.id || '').trim();
  const coupleId = normalizeCoupleId(payload.coupleId);
  const name = String(payload.name || '').trim();
  const date = String(payload.date || '').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();
  if (!id || !name) throw new AppError('invalid_request', 'id and name are required');
  if (!date || Number.isNaN(Date.parse(date))) throw new AppError('invalid_request', 'date must be a valid ISO timestamp');
  if (!createdAt || Number.isNaN(Date.parse(createdAt))) throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  if (!updatedAt || Number.isNaN(Date.parse(updatedAt))) throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  return { id, coupleId, name, date, createdAt, updatedAt, isDeleted: payload.isDeleted === true };
}

async function listCountdownEventsPg(pool, { coupleId, since }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const sinceValue = normalizeSince(since);
  const client = await pool.connect();
  try {
    await ensureCouple(client, trimmedCoupleId);
    const rows = sinceValue
      ? await client.query(
          `
          SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
          FROM countdown_events
          WHERE couple_id = $1 AND updated_at > $2
          ORDER BY updated_at ASC, id ASC
          `,
          [trimmedCoupleId, sinceValue],
        )
      : await client.query(
          `
          SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
          FROM countdown_events
          WHERE couple_id = $1
          ORDER BY updated_at ASC, id ASC
          `,
          [trimmedCoupleId],
        );
    return rows.rows.map((row) => ({
      id: row.id,
      coupleId: row.couple_id,
      name: row.name,
      date: row.date,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      isDeleted: row.is_deleted === true,
    }));
  } finally {
    client.release();
  }
}

async function upsertCountdownEventPg(pool, payload) {
  const event = normalizePayload(payload);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCouple(client, event.coupleId);
    const existing = await client.query(
      `
      SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
      FROM countdown_events
      WHERE id = $1 AND couple_id = $2
      `,
      [event.id, event.coupleId],
    );
    if (existing.rowCount > 0 && Date.parse(existing.rows[0].updated_at) > Date.parse(event.updatedAt)) {
      await client.query('COMMIT');
      const row = existing.rows[0];
      return {
        id: row.id,
        coupleId: row.couple_id,
        name: row.name,
        date: row.date,
        createdAt: row.created_at,
        updatedAt: row.updated_at,
        isDeleted: row.is_deleted === true,
      };
    }
    await client.query(
      `
      INSERT INTO countdown_events (id, couple_id, name, date, created_at, updated_at, is_deleted)
      VALUES ($1,$2,$3,$4,$5,$6,$7)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        name = EXCLUDED.name,
        date = EXCLUDED.date,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at,
        is_deleted = EXCLUDED.is_deleted
      `,
      [event.id, event.coupleId, event.name, event.date, event.createdAt, event.updatedAt, event.isDeleted],
    );
    await client.query('COMMIT');
    return {
      id: event.id,
      coupleId: event.coupleId,
      name: event.name,
      date: event.date,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      isDeleted: event.isDeleted,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteCountdownEventPg(pool, { coupleId, id, updatedAt }) {
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
    await client.query(
      `
      UPDATE countdown_events
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
  listCountdownEventsPg,
  upsertCountdownEventPg,
  deleteCountdownEventPg,
};

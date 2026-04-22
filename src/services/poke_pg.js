const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) throw new AppError('invalid_request', `${field} is required`);
  return trimmed;
}

async function ensureCouple(client, coupleId) {
  const res = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (res.rowCount === 0) throw new AppError('couple_not_found', 'Couple not found', 404);
  return res.rows[0];
}

function ensureMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function mapPoke(row, currentUserId) {
  return {
    id: row.id,
    sender: row.sender_user_id === currentUserId ? 'me' : 'partner',
    createdAt: row.created_at,
    message: row.message,
  };
}

async function listPokeEventsPg(pool, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const sinceValue = typeof since === 'string' && since.trim() ? since.trim() : null;
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const rows = sinceValue
      ? await client.query(
          `
          SELECT id, couple_id, sender_user_id, message, created_at
          FROM poke_events
          WHERE couple_id = $1 AND created_at > $2
          ORDER BY created_at ASC, id ASC
          `,
          [trimmedCoupleId, sinceValue],
        )
      : await client.query(
          `
          SELECT id, couple_id, sender_user_id, message, created_at
          FROM poke_events
          WHERE couple_id = $1
          ORDER BY created_at ASC, id ASC
          `,
          [trimmedCoupleId],
        );
    return rows.rows.map((row) => mapPoke(row, trimmedCurrentUserId));
  } finally {
    client.release();
  }
}

async function sendPokePg(pool, { coupleId, currentUserId, message }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const trimmedMessage = String(message || '').trim() || '轻轻戳了你一下';
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const now = new Date().toISOString();
    const id = `poke-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
    await client.query(
      `
      INSERT INTO poke_events (id, couple_id, sender_user_id, message, created_at)
      VALUES ($1,$2,$3,$4,$5)
      `,
      [id, trimmedCoupleId, trimmedCurrentUserId, trimmedMessage, now],
    );
    await client.query('COMMIT');
    return mapPoke(
      { id, sender_user_id: trimmedCurrentUserId, message: trimmedMessage, created_at: now },
      trimmedCurrentUserId,
    );
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listPokeEventsPg,
  sendPokePg,
};

const { randomUUID } = require('crypto');
const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

async function ensureCoupleMember(client, coupleId, currentUserId) {
  const result = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  const couple = result.rows[0];
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

async function listFeedEventsPg(pool, { coupleId, currentUserId, limit }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const numericLimit = Number.isFinite(Number(limit))
    ? Math.max(1, Math.min(200, Number(limit)))
    : 100;

  const client = await pool.connect();
  try {
    await ensureCoupleMember(client, trimmedCoupleId, trimmedCurrentUserId);
    const rows = await client.query(
      `
      SELECT id, couple_id, event_type, actor_user_id, target_type, target_id, summary_text, created_at, is_read
      FROM feed_events
      WHERE couple_id = $1
      ORDER BY created_at DESC, id DESC
      LIMIT $2
      `,
      [trimmedCoupleId, numericLimit],
    );
    return rows.rows.map((row) => ({
      id: row.id,
      coupleId: row.couple_id,
      eventType: row.event_type,
      actorUserId: row.actor_user_id,
      targetType: row.target_type,
      targetId: row.target_id,
      summaryText: row.summary_text,
      createdAt: row.created_at,
      isRead: row.is_read === true,
    }));
  } finally {
    client.release();
  }
}

async function addFeedEventPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const eventType = normalizeRequired(payload.eventType, 'eventType');
  const targetType = normalizeRequired(payload.targetType, 'targetType');
  const targetId = normalizeRequired(payload.targetId, 'targetId');
  const summaryText = normalizeRequired(payload.summaryText, 'summaryText');
  const id = String(payload.id || '').trim() || `feed-${randomUUID()}`;
  const createdAt = String(payload.createdAt || '').trim() || new Date().toISOString();
  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCoupleMember(client, coupleId, currentUserId);
    await client.query(
      `
      INSERT INTO feed_events (
        id, couple_id, event_type, actor_user_id, target_type, target_id, summary_text, created_at, is_read
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      ON CONFLICT (id) DO NOTHING
      `,
      [id, coupleId, eventType, currentUserId, targetType, targetId, summaryText, createdAt, false],
    );
    const latest = await client.query(
      `
      SELECT id, couple_id, event_type, actor_user_id, target_type, target_id, summary_text, created_at, is_read
      FROM feed_events
      WHERE id = $1
      `,
      [id],
    );
    await client.query('COMMIT');
    const row = latest.rows[0];
    return {
      id: row.id,
      coupleId: row.couple_id,
      eventType: row.event_type,
      actorUserId: row.actor_user_id,
      targetType: row.target_type,
      targetId: row.target_id,
      summaryText: row.summary_text,
      createdAt: row.created_at,
      isRead: row.is_read === true,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listFeedEventsPg,
  addFeedEventPg,
};

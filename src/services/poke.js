const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

function ensureCouple(db, coupleId) {
  const couple = db
    .prepare('SELECT id, user1_id, user2_id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');
  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return couple;
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

function listPokeEvents(db, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const couple = ensureCouple(db, trimmedCoupleId);
  ensureMember(couple, trimmedCurrentUserId);
  const sinceValue = typeof since === 'string' && since.trim() ? since.trim() : null;

  const rows = sinceValue
    ? db
        .prepare(
          `
            SELECT id, couple_id, sender_user_id, message, created_at
            FROM poke_events
            WHERE couple_id = ? AND created_at > ?
            ORDER BY created_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId, sinceValue)
    : db
        .prepare(
          `
            SELECT id, couple_id, sender_user_id, message, created_at
            FROM poke_events
            WHERE couple_id = ?
            ORDER BY created_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId);

  return rows.map((row) => mapPoke(row, trimmedCurrentUserId));
}

function sendPoke(db, { coupleId, currentUserId, message }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const trimmedMessage = String(message || '').trim() || '轻轻戳了你一下';

  const transaction = db.transaction(() => {
    const couple = ensureCouple(db, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const now = new Date().toISOString();
    const id = `poke-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
    db.prepare(
      `
        INSERT INTO poke_events (id, couple_id, sender_user_id, message, created_at)
        VALUES (?, ?, ?, ?, ?)
      `,
    ).run(id, trimmedCoupleId, trimmedCurrentUserId, trimmedMessage, now);

    return mapPoke(
      {
        id,
        sender_user_id: trimmedCurrentUserId,
        message: trimmedMessage,
        created_at: now,
      },
      trimmedCurrentUserId,
    );
  });

  return transaction();
}

module.exports = {
  listPokeEvents,
  sendPoke,
};

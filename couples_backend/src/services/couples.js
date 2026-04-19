const { AppError } = require('../errors');

function normalizeUserPair(userIdA, userIdB) {
  return [userIdA, userIdB].sort((left, right) => left.localeCompare(right));
}

function bindCoupleByPairCode(db, { currentUserId, targetPairCode }) {
  const trimmedCurrentUserId = String(currentUserId || '').trim();
  const normalizedPairCode = String(targetPairCode || '').trim().toUpperCase();

  if (!trimmedCurrentUserId || !normalizedPairCode) {
    throw new AppError('invalid_request', 'currentUserId and targetPairCode are required');
  }

  const transaction = db.transaction(() => {
    const currentUser = db
      .prepare('SELECT id, nickname, pair_code, couple_id FROM users WHERE id = ?')
      .get(trimmedCurrentUserId);

    if (!currentUser) {
      throw new AppError('user_not_found', 'Current user not found', 404);
    }

    if (currentUser.couple_id) {
      throw new AppError('current_user_already_bound', 'Current user already bound');
    }

    const targetUser = db
      .prepare('SELECT id, nickname, pair_code, couple_id FROM users WHERE UPPER(pair_code) = ?')
      .get(normalizedPairCode);

    if (!targetUser) {
      throw new AppError('invalid_pair_code', 'Pair code is invalid');
    }

    if (targetUser.id === trimmedCurrentUserId) {
      throw new AppError('cannot_bind_self', 'Cannot bind self');
    }

    if (targetUser.couple_id) {
      throw new AppError('target_user_already_bound', 'Target user already bound');
    }

    const [user1Id, user2Id] = normalizeUserPair(currentUser.id, targetUser.id);
    const existingCouple = db
      .prepare('SELECT id, created_at FROM couples WHERE user1_id = ? AND user2_id = ?')
      .get(user1Id, user2Id);

    if (existingCouple) {
      throw new AppError('current_user_already_bound', 'Current user already bound');
    }

    const now = new Date().toISOString();
    const coupleId = `couple-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;

    db.prepare(
      `
        INSERT INTO couples (id, user1_id, user2_id, status, created_at)
        VALUES (?, ?, ?, 'active', ?)
      `,
    ).run(coupleId, user1Id, user2Id, now);

    db.prepare(
      `
        UPDATE users
        SET couple_id = ?, updated_at = ?
        WHERE id IN (?, ?)
      `,
    ).run(coupleId, now, currentUser.id, targetUser.id);

    return {
      coupleId,
      createdAt: now,
      updatedAt: now,
      currentUser: {
        id: currentUser.id,
        nickname: currentUser.nickname,
      },
      partner: {
        id: targetUser.id,
        nickname: targetUser.nickname,
      },
    };
  });

  return transaction();
}

module.exports = {
  bindCoupleByPairCode,
  normalizeUserPair,
};

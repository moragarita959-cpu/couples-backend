const { AppError } = require('../errors');
const { normalizeUserPair } = require('./couples');

async function bindCoupleByPairCodePg(pool, { currentUserId, targetPairCode }) {
  const trimmedCurrentUserId = String(currentUserId || '').trim();
  const normalizedPairCode = String(targetPairCode || '').trim().toUpperCase();
  if (!trimmedCurrentUserId || !normalizedPairCode) {
    throw new AppError('invalid_request', 'currentUserId and targetPairCode are required');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const currentResult = await client.query(
      'SELECT id, nickname, pair_code, couple_id FROM users WHERE id = $1',
      [trimmedCurrentUserId],
    );
    if (currentResult.rowCount === 0) {
      throw new AppError('user_not_found', 'Current user not found', 404);
    }
    const currentUser = currentResult.rows[0];
    if (currentUser.couple_id) {
      throw new AppError('current_user_already_bound', 'Current user already bound');
    }

    const targetResult = await client.query(
      'SELECT id, nickname, pair_code, couple_id FROM users WHERE UPPER(pair_code) = $1',
      [normalizedPairCode],
    );
    if (targetResult.rowCount === 0) {
      throw new AppError('invalid_pair_code', 'Pair code is invalid');
    }
    const targetUser = targetResult.rows[0];
    if (targetUser.id === trimmedCurrentUserId) {
      throw new AppError('cannot_bind_self', 'Cannot bind self');
    }
    if (targetUser.couple_id) {
      throw new AppError('target_user_already_bound', 'Target user already bound');
    }

    const [user1Id, user2Id] = normalizeUserPair(currentUser.id, targetUser.id);
    const existingCouple = await client.query(
      'SELECT id, created_at FROM couples WHERE user1_id = $1 AND user2_id = $2',
      [user1Id, user2Id],
    );
    if (existingCouple.rowCount > 0) {
      throw new AppError('current_user_already_bound', 'Current user already bound');
    }

    const now = new Date().toISOString();
    const coupleId = `couple-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
    await client.query(
      `
      INSERT INTO couples (id, user1_id, user2_id, status, created_at)
      VALUES ($1, $2, $3, 'active', $4)
      `,
      [coupleId, user1Id, user2Id, now],
    );
    await client.query(
      `
      UPDATE users
      SET couple_id = $1, updated_at = $2
      WHERE id IN ($3, $4)
      `,
      [coupleId, now, currentUser.id, targetUser.id],
    );
    await client.query('COMMIT');
    return {
      coupleId,
      createdAt: now,
      updatedAt: now,
      currentUser: { id: currentUser.id, nickname: currentUser.nickname },
      partner: { id: targetUser.id, nickname: targetUser.nickname },
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function getPartnerUserIdPg(pool, { coupleId, currentUserId }) {
  const normalizedCoupleId = String(coupleId || '').trim();
  const trimmedMe = String(currentUserId || '').trim();
  if (!normalizedCoupleId || !trimmedMe) {
    throw new AppError('invalid_request', 'coupleId and currentUserId are required');
  }

  const result = await pool.query(
    'SELECT user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [normalizedCoupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  const row = result.rows[0];
  if (row.user1_id !== trimmedMe && row.user2_id !== trimmedMe) {
    throw new AppError('forbidden', 'currentUserId is not a member of this couple', 403);
  }
  const partnerUserId = row.user1_id === trimmedMe ? row.user2_id : row.user1_id;
  return { partnerUserId };
}

module.exports = {
  bindCoupleByPairCodePg,
  getPartnerUserIdPg,
};

const { AppError } = require('../errors');

function generatePairCode(db) {
  const query = db.prepare('SELECT 1 FROM users WHERE pair_code = ? LIMIT 1');
  for (let i = 0; i < 20; i += 1) {
    const code = String(Math.floor(Math.random() * 900000) + 100000);
    if (!query.get(code)) {
      return code;
    }
  }
  throw new AppError('pair_code_generation_failed', 'Failed to generate pair code', 500);
}

function bootstrapUser(db, { userId, nickname }) {
  const trimmedNickname = String(nickname || '').trim();
  const trimmedUserId = String(userId || '').trim();

  if (!trimmedUserId || !trimmedNickname) {
    throw new AppError('invalid_request', 'userId and nickname are required');
  }

  const now = new Date().toISOString();
  const existing = db
    .prepare('SELECT id, nickname, pair_code, couple_id, created_at, updated_at FROM users WHERE id = ?')
    .get(trimmedUserId);

  if (existing) {
    // Strategy: userId is the stable identity key; when it already exists, nickname is updated to the latest submitted value.
    db.prepare(
      `
        UPDATE users
        SET nickname = ?, updated_at = ?
        WHERE id = ?
      `,
    ).run(trimmedNickname, now, trimmedUserId);

    return {
      id: existing.id,
      nickname: trimmedNickname,
      pairCode: existing.pair_code,
      coupleId: existing.couple_id,
      createdAt: existing.created_at,
      updatedAt: now,
    };
  }

  // Recovery path: If device local identity was lost (reinstall/clear data),
  // try to recover by nickname when it maps to exactly one existing user.
  // This avoids creating a brand-new account and "losing" prior couple/chat data.
  const sameNicknameRows = db
    .prepare(
      `
        SELECT id, nickname, pair_code, couple_id, created_at, updated_at
        FROM users
        WHERE lower(nickname) = lower(?)
      `,
    )
    .all(trimmedNickname);
  if (sameNicknameRows.length === 1) {
    const recovered = sameNicknameRows[0];
    db.prepare(
      `
        UPDATE users
        SET updated_at = ?
        WHERE id = ?
      `,
    ).run(now, recovered.id);
    return {
      id: recovered.id,
      nickname: recovered.nickname,
      pairCode: recovered.pair_code,
      coupleId: recovered.couple_id,
      createdAt: recovered.created_at,
      updatedAt: now,
    };
  }

  const pairCode = generatePairCode(db);
  db.prepare(
    `
      INSERT INTO users (id, nickname, pair_code, couple_id, created_at, updated_at)
      VALUES (?, ?, ?, NULL, ?, ?)
    `,
  ).run(trimmedUserId, trimmedNickname, pairCode, now, now);

  return {
    id: trimmedUserId,
    nickname: trimmedNickname,
    pairCode,
    coupleId: null,
    createdAt: now,
    updatedAt: now,
  };
}

module.exports = {
  bootstrapUser,
};

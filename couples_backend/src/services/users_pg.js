const { AppError } = require('../errors');

async function generatePairCodePg(client) {
  for (let i = 0; i < 20; i += 1) {
    const code = String(Math.floor(Math.random() * 900000) + 100000);
    const hit = await client.query('SELECT 1 FROM users WHERE pair_code = $1 LIMIT 1', [code]);
    if (hit.rowCount === 0) {
      return code;
    }
  }
  throw new AppError('pair_code_generation_failed', 'Failed to generate pair code', 500);
}

async function bootstrapUserPg(pool, { userId, nickname }) {
  const trimmedNickname = String(nickname || '').trim();
  const trimmedUserId = String(userId || '').trim();
  if (!trimmedUserId || !trimmedNickname) {
    throw new AppError('invalid_request', 'userId and nickname are required');
  }

  const now = new Date().toISOString();
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const existing = await client.query(
      'SELECT id, nickname, pair_code, couple_id, created_at, updated_at FROM users WHERE id = $1',
      [trimmedUserId],
    );
    if (existing.rowCount > 0) {
      await client.query('UPDATE users SET nickname = $1, updated_at = $2 WHERE id = $3', [
        trimmedNickname,
        now,
        trimmedUserId,
      ]);
      await client.query('COMMIT');
      const row = existing.rows[0];
      return {
        id: row.id,
        nickname: trimmedNickname,
        pairCode: row.pair_code,
        coupleId: row.couple_id,
        createdAt: row.created_at,
        updatedAt: now,
      };
    }

    const sameNicknameRows = await client.query(
      `
      SELECT id, nickname, pair_code, couple_id, created_at, updated_at
      FROM users
      WHERE lower(nickname) = lower($1)
      `,
      [trimmedNickname],
    );
    if (sameNicknameRows.rowCount === 1) {
      const recovered = sameNicknameRows.rows[0];
      await client.query('UPDATE users SET updated_at = $1 WHERE id = $2', [now, recovered.id]);
      await client.query('COMMIT');
      return {
        id: recovered.id,
        nickname: recovered.nickname,
        pairCode: recovered.pair_code,
        coupleId: recovered.couple_id,
        createdAt: recovered.created_at,
        updatedAt: now,
      };
    }

    const pairCode = await generatePairCodePg(client);
    await client.query(
      `
      INSERT INTO users (id, nickname, pair_code, couple_id, created_at, updated_at)
      VALUES ($1, $2, $3, NULL, $4, $5)
      `,
      [trimmedUserId, trimmedNickname, pairCode, now, now],
    );
    await client.query('COMMIT');
    return {
      id: trimmedUserId,
      nickname: trimmedNickname,
      pairCode,
      coupleId: null,
      createdAt: now,
      updatedAt: now,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  bootstrapUserPg,
};

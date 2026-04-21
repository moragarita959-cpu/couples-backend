const fs = require('fs');
const { Pool } = require('pg');

const config = require('./config');

fs.mkdirSync(config.chatMediaDir, { recursive: true });

const pool = new Pool({
  connectionString: config.databaseUrl,
  ssl: { rejectUnauthorized: false },
});

async function initPostgresSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      nickname TEXT NOT NULL,
      pair_code TEXT NOT NULL UNIQUE,
      couple_id TEXT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query('CREATE INDEX IF NOT EXISTS idx_users_couple_id ON users(couple_id);');

  await pool.query(`
    CREATE TABLE IF NOT EXISTS couples (
      id TEXT PRIMARY KEY,
      user1_id TEXT NOT NULL,
      user2_id TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      UNIQUE(user1_id, user2_id)
    );
  `);
  await pool.query('CREATE INDEX IF NOT EXISTS idx_couples_user1_id ON couples(user1_id);');
  await pool.query('CREATE INDEX IF NOT EXISTS idx_couples_user2_id ON couples(user2_id);');

  await pool.query(`
    CREATE TABLE IF NOT EXISTS chat_messages (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      sender_user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      client_message_id TEXT NOT NULL,
      message_type TEXT NOT NULL DEFAULT 'text',
      media_url TEXT NULL,
      media_duration_ms INTEGER NOT NULL DEFAULT 0,
      created_at TIMESTAMPTZ NOT NULL,
      UNIQUE(couple_id, client_message_id)
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_chat_messages_couple_created
      ON chat_messages(couple_id, created_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS chat_push_tokens (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      token TEXT NOT NULL,
      platform TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      UNIQUE(couple_id, user_id, token)
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_chat_push_tokens_couple_user
      ON chat_push_tokens(couple_id, user_id);
  `);
}

module.exports = {
  pool,
  initPostgresSchema,
};

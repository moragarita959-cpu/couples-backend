const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

const config = require('./config');

const schemaSql = fs.readFileSync(
  path.resolve(__dirname, 'database', 'init.sql'),
  'utf8',
);

fs.mkdirSync(path.dirname(config.dbPath), { recursive: true });
fs.mkdirSync(config.chatMediaDir, { recursive: true });

const db = new DatabaseSync(config.dbPath);
db.exec(schemaSql);

function ensureColumn(tableName, columnName, alterSql) {
  const columns = db.prepare(`PRAGMA table_info(${tableName})`).all();
  if (columns.some((column) => column.name === columnName)) {
    return;
  }
  db.exec(alterSql);
}

ensureColumn(
  'chat_messages',
  'message_type',
  "ALTER TABLE chat_messages ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text'",
);
ensureColumn(
  'chat_messages',
  'media_url',
  'ALTER TABLE chat_messages ADD COLUMN media_url TEXT',
);
ensureColumn(
  'chat_messages',
  'media_duration_ms',
  'ALTER TABLE chat_messages ADD COLUMN media_duration_ms INTEGER NOT NULL DEFAULT 0',
);

db.transaction = (work) => (...args) => {
  db.exec('BEGIN');
  try {
    const result = work(...args);
    db.exec('COMMIT');
    return result;
  } catch (error) {
    try {
      db.exec('ROLLBACK');
    } catch (_) {
      // Ignore rollback failures and rethrow the original error.
    }
    throw error;
  }
};

module.exports = db;

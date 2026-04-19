const path = require('path');

require('dotenv').config();

const rootDir = path.resolve(__dirname, '..');

const config = {
  port: Number(process.env.PORT || 3000),
  dbPath: path.resolve(rootDir, process.env.DB_PATH || './data/couples.db'),
  messageMaxLength: Number(process.env.MESSAGE_MAX_LENGTH || 1000),
  publicBaseUrl: String(process.env.PUBLIC_BASE_URL || '').trim(),
  chatMediaDir: path.resolve(
    rootDir,
    process.env.CHAT_MEDIA_DIR || './data/chat-media',
  ),
};

module.exports = config;

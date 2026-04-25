const path = require('path');

require('dotenv').config();

const rootDir = path.resolve(__dirname, '..');

const config = {
  port: Number(process.env.PORT || 3000),
  dbPath: path.resolve(rootDir, process.env.DB_PATH || './data/couples.db'),
  databaseUrl: String(process.env.DATABASE_URL || '').trim(),
  messageMaxLength: Number(process.env.MESSAGE_MAX_LENGTH || 1000),
  publicBaseUrl: String(process.env.PUBLIC_BASE_URL || '').trim(),
  chatMediaDir: path.resolve(
    rootDir,
    process.env.CHAT_MEDIA_DIR || './data/chat-media',
  ),
  albumMediaDir: path.resolve(
    rootDir,
    process.env.ALBUM_MEDIA_DIR || './data/album-media',
  ),
  fcmServerKey: String(process.env.FCM_SERVER_KEY || '').trim(),
};

config.usePostgres = config.databaseUrl.length > 0;

module.exports = config;

const fs = require('fs');
const path = require('path');

const config = require('../config');

const ALLOWED_MIMES = new Set(['image/jpeg', 'image/jpg', 'image/png', 'image/webp']);
const RELATIVE_ALBUM_PREFIX = '/media/album';

/**
 * 生成可替换为对象存储的本地文件名
 */
function generateStoredFileName(originalName) {
  const ext = path.extname(String(originalName || '')).toLowerCase();
  const safeExt = ext && ext.length <= 8 ? ext : '.jpg';
  return `album_${Date.now()}_${Math.floor(Math.random() * 9000) + 1000}${safeExt}`;
}

/**
 * 校验 multer 上传的 mime（image/jpeg, png, webp）
 */
function isAllowedImageMime(mime) {
  const m = String(mime || '').toLowerCase();
  if (ALLOWED_MIMES.has(m)) {
    return true;
  }
  if (m === 'image/pjpeg' || m === 'image/jpg') {
    return true;
  }
  return false;
}

function buildPublicImageUrl(filename, publicBaseUrl) {
  const relative = `${RELATIVE_ALBUM_PREFIX.replace(/\/$/, '')}/${filename}`.replace(/\/+/g, '/');
  const base = String(publicBaseUrl || '').replace(/\/+$/, '');
  if (!base) {
    return relative.startsWith('/') ? relative : `/${relative}`;
  }
  return `${base}${relative.startsWith('/') ? relative : `/${relative}`}`;
}

/**
 * 根据返回给客户端的 image_url 或路径删除本地文件（失败忽略）
 */
function tryDeleteLocalFileByImageUrl(storedValue) {
  if (!storedValue) {
    return;
  }
  const s = String(storedValue);
  const prefix = '/media/album/';
  const idx = s.indexOf(prefix);
  const name = idx >= 0 ? s.slice(idx + prefix.length).split('?')[0] : null;
  if (!name || name.includes('..') || name.includes(path.sep)) {
    return;
  }
  const full = path.join(config.albumMediaDir, name);
  try {
    if (fs.existsSync(full) && full.startsWith(path.resolve(config.albumMediaDir))) {
      fs.unlinkSync(full);
    }
  } catch (_) {
    // Railway 等环境下忽略删除失败
  }
}

module.exports = {
  generateStoredFileName,
  isAllowedImageMime,
  buildPublicImageUrl,
  tryDeleteLocalFileByImageUrl,
  RELATIVE_ALBUM_PREFIX,
  ALLOWED_MIMES,
};

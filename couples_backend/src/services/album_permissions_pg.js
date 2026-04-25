const { AppError } = require('../errors');

/**
 * 校验 currentUserId 是 active couple 成员；不信任前端仅传的 coupleId（结合后续资源归属校验）。
 * @param {import('pg').Pool|import('pg').PoolClient} clientOrPool
 */
async function assertUserInCouple(clientOrPool, coupleId, currentUserId) {
  const trimmedCoupleId = String(coupleId || '').trim();
  const trimmedUserId = String(currentUserId || '').trim();
  if (!trimmedCoupleId || !trimmedUserId) {
    throw new AppError('invalid_request', 'coupleId and currentUserId are required');
  }

  const result = await clientOrPool.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [trimmedCoupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  const row = result.rows[0];
  if (trimmedUserId !== row.user1_id && trimmedUserId !== row.user2_id) {
    throw new AppError('forbidden', 'Current user does not belong to couple', 403);
  }
  return row;
}

/**
 * 相册必须属于该 couple
 */
async function assertAlbumInCouple(clientOrPool, albumId, coupleId) {
  const r = await clientOrPool.query(
    'SELECT id, couple_id, title, description, cover_photo_url, created_by_user_id, created_at, updated_at FROM albums WHERE id = $1 AND couple_id = $2',
    [albumId, coupleId],
  );
  if (r.rowCount === 0) {
    throw new AppError('album_not_found', 'Album not found', 404);
  }
  return r.rows[0];
}

async function assertPhotoInCouple(clientOrPool, photoId, coupleId) {
  const r = await clientOrPool.query(
    `SELECT id, album_id, couple_id, uploader_user_id, image_url, local_path, caption, taken_at, created_at, updated_at
     FROM album_photos WHERE id = $1 AND couple_id = $2`,
    [photoId, coupleId],
  );
  if (r.rowCount === 0) {
    throw new AppError('photo_not_found', 'Photo not found', 404);
  }
  return r.rows[0];
}

async function assertCommentInCouple(clientOrPool, commentId, coupleId) {
  const r = await clientOrPool.query(
    `SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
     FROM photo_comments WHERE id = $1 AND couple_id = $2`,
    [commentId, coupleId],
  );
  if (r.rowCount === 0) {
    throw new AppError('comment_not_found', 'Comment not found', 404);
  }
  return r.rows[0];
}

module.exports = {
  assertUserInCouple,
  assertAlbumInCouple,
  assertPhotoInCouple,
  assertCommentInCouple,
};

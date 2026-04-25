const { AppError } = require('../errors');
const {
  assertUserInCouple,
  assertAlbumInCouple,
  assertPhotoInCouple,
  assertCommentInCouple,
} = require('./album_permissions_pg');
const { buildPublicImageUrl, tryDeleteLocalFileByImageUrl } = require('./album_media_storage');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

function normalizeOptional(value) {
  const trimmed = String(value || '').trim();
  return trimmed || null;
}

function mapAlbumRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    title: row.title,
    description: row.description || '',
    coverPhotoUrl: row.cover_photo_url || row.fallback_cover_photo_url || null,
    createdByUserId: row.created_by_user_id,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    photoCount: Number(row.photo_count || 0),
    lastPhotoAt: row.last_photo_at || null,
  };
}

function mapPhotoRow(row) {
  return {
    id: row.id,
    albumId: row.album_id,
    coupleId: row.couple_id,
    uploaderUserId: row.uploader_user_id,
    imageUrl: row.image_url,
    localPath: row.local_path || null,
    caption: row.caption || '',
    takenAt: row.taken_at || null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    commentCount: Number(row.comment_count || 0),
    albumTitle: row.album_title || null,
  };
}

function mapCommentRow(row) {
  return {
    id: row.id,
    photoId: row.photo_id,
    coupleId: row.couple_id,
    authorUserId: row.author_user_id,
    content: row.content,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function newAlbumId() {
  return `album-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

function newPhotoId() {
  return `photo-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

function newCommentId() {
  return `comment-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

/**
 * POST /album/list
 */
async function listAlbumsPg(pool, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  await assertUserInCouple(pool, trimmedCoupleId, trimmedCurrentUserId);

  const rows = await pool.query(
    `
      SELECT a.id, a.couple_id, a.title, a.description, a.cover_photo_url,
             a.created_by_user_id, a.created_at, a.updated_at,
             COUNT(p.id) AS photo_count,
             MAX(COALESCE(p.updated_at, p.created_at)) AS last_photo_at,
             (
               SELECT ap.image_url
               FROM album_photos ap
               WHERE ap.album_id = a.id
               ORDER BY COALESCE(ap.updated_at, ap.created_at) DESC, ap.id DESC
               LIMIT 1
             ) AS fallback_cover_photo_url
      FROM albums a
      LEFT JOIN album_photos p ON p.album_id = a.id
      WHERE a.couple_id = $1
      GROUP BY a.id
      ORDER BY a.updated_at DESC, a.id DESC
    `,
    [trimmedCoupleId],
  );
  return rows.rows.map(mapAlbumRow);
}

/**
 * POST /album/create
 */
async function createAlbumPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const title = normalizeRequired(payload.title, 'title');
  const description = String(payload.description || '').trim();
  const id = String(payload.id || payload.albumId || '').trim() || newAlbumId();

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);

    const existing = await client.query('SELECT id FROM albums WHERE id = $1 AND couple_id = $2', [
      id,
      coupleId,
    ]);
    if (existing.rowCount > 0) {
      throw new AppError('album_already_exists', 'Album already exists', 409);
    }

    const now = new Date().toISOString();
    await client.query(
      `
        INSERT INTO albums (
          id, couple_id, title, description, cover_photo_url,
          created_by_user_id, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, NULL, $5, $6, $7)
      `,
      [id, coupleId, title, description || null, currentUserId, now, now],
    );

    const result = await client.query(
      `
        SELECT a.*, 0 AS photo_count, NULL AS last_photo_at, NULL AS fallback_cover_photo_url
        FROM albums a
        WHERE a.id = $1 AND a.couple_id = $2
      `,
      [id, coupleId],
    );
    await client.query('COMMIT');
    return mapAlbumRow(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/update
 */
async function updateAlbumPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const albumId = normalizeRequired(payload.albumId || payload.id, 'albumId');
  const title = normalizeRequired(payload.title, 'title');
  const description = String(payload.description || '').trim();

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);
    await assertAlbumInCouple(client, albumId, coupleId);

    const now = new Date().toISOString();
    await client.query(
      `
        UPDATE albums
        SET title = $1, description = $2, updated_at = $3
        WHERE id = $4 AND couple_id = $5
      `,
      [title, description || null, now, albumId, coupleId],
    );

    const result = await client.query(
      `
        SELECT a.id, a.couple_id, a.title, a.description, a.cover_photo_url,
               a.created_by_user_id, a.created_at, a.updated_at,
               COUNT(p.id) AS photo_count,
               MAX(COALESCE(p.updated_at, p.created_at)) AS last_photo_at,
               (
                 SELECT ap.image_url
                 FROM album_photos ap
                 WHERE ap.album_id = a.id
                 ORDER BY COALESCE(ap.updated_at, ap.created_at) DESC, ap.id DESC
                 LIMIT 1
               ) AS fallback_cover_photo_url
        FROM albums a
        LEFT JOIN album_photos p ON p.album_id = a.id
        WHERE a.id = $1 AND a.couple_id = $2
        GROUP BY a.id
      `,
      [albumId, coupleId],
    );
    await client.query('COMMIT');
    return mapAlbumRow(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/delete — 子表由 ON DELETE CASCADE 处理
 */
async function deleteAlbumPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const albumId = normalizeRequired(payload.albumId, 'albumId');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);
    await assertAlbumInCouple(client, albumId, coupleId);

    const photos = await client.query(
      'SELECT image_url FROM album_photos WHERE album_id = $1 AND couple_id = $2',
      [albumId, coupleId],
    );
    for (const r of photos.rows) {
      tryDeleteLocalFileByImageUrl(r.image_url);
    }

    await client.query('DELETE FROM albums WHERE id = $1 AND couple_id = $2', [albumId, coupleId]);
    await client.query('COMMIT');
    return { id: albumId, deleted: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/list — 按 created_at DESC
 */
async function listAlbumPhotosPg(pool, { albumId, coupleId, currentUserId }) {
  const trimmedAlbumId = normalizeRequired(albumId, 'albumId');
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');

  const client = await pool.connect();
  try {
    await assertUserInCouple(client, trimmedCoupleId, trimmedCurrentUserId);
    await assertAlbumInCouple(client, trimmedAlbumId, trimmedCoupleId);

    const rows = await client.query(
      `
        SELECT p.id, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
               p.caption, p.taken_at, p.created_at, p.updated_at,
               a.title AS album_title,
               COUNT(c.id) AS comment_count
        FROM album_photos p
        INNER JOIN albums a ON a.id = p.album_id
        LEFT JOIN photo_comments c ON c.photo_id = p.id
        WHERE p.album_id = $1 AND p.couple_id = $2
        GROUP BY p.id, a.title, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
                 p.caption, p.taken_at, p.created_at, p.updated_at
        ORDER BY p.created_at DESC, p.id DESC
      `,
      [trimmedAlbumId, trimmedCoupleId],
    );
    return rows.rows.map(mapPhotoRow);
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/upload
 */
async function uploadAlbumPhotoPg(pool, payload, publicBaseUrl) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const albumId = normalizeRequired(payload.albumId, 'albumId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = String(payload.id || '').trim() || newPhotoId();
  const caption = String(payload.caption || '').trim();
  const file = payload.file;
  if (!file || !file.filename) {
    throw new AppError('invalid_request', 'file is required');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);
    const album = await assertAlbumInCouple(client, albumId, coupleId);

    const existing = await client.query('SELECT id FROM album_photos WHERE id = $1 AND couple_id = $2', [
      id,
      coupleId,
    ]);
    if (existing.rowCount > 0) {
      throw new AppError('photo_already_exists', 'Photo already exists', 409);
    }

    const imageUrl = buildPublicImageUrl(file.filename, publicBaseUrl);
    const now = new Date().toISOString();

    await client.query(
      `
        INSERT INTO album_photos (
          id, album_id, couple_id, uploader_user_id, image_url, local_path,
          caption, taken_at, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, NULL, $8, $9)
      `,
      [id, albumId, coupleId, currentUserId, imageUrl, null, caption || null, now, now],
    );

    if (!album.cover_photo_url) {
      await client.query('UPDATE albums SET cover_photo_url = $1, updated_at = $2 WHERE id = $3 AND couple_id = $4', [
        imageUrl,
        now,
        albumId,
        coupleId,
      ]);
    } else {
      await client.query('UPDATE albums SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [now, albumId, coupleId]);
    }

    const result = await client.query(
      `
        SELECT p.id, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
               p.caption, p.taken_at, p.created_at, p.updated_at,
               a.title AS album_title, 0 AS comment_count
        FROM album_photos p
        INNER JOIN albums a ON a.id = p.album_id
        WHERE p.id = $1 AND p.couple_id = $2
      `,
      [id, coupleId],
    );
    await client.query('COMMIT');
    return mapPhotoRow(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/update — 仅 uploader 可改 caption
 */
async function updateAlbumPhotoPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const photoId = normalizeRequired(payload.photoId || payload.id, 'photoId');
  const caption = String(payload.caption || '').trim();

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);
    const existing = await assertPhotoInCouple(client, photoId, coupleId);
    if (existing.uploader_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only uploader can update this photo', 403);
    }

    const now = new Date().toISOString();
    await client.query(
      `
        UPDATE album_photos
        SET caption = $1, updated_at = $2
        WHERE id = $3 AND couple_id = $4
      `,
      [caption || null, now, photoId, coupleId],
    );
    await client.query('UPDATE albums SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
      now,
      existing.album_id,
      coupleId,
    ]);

    const result = await client.query(
      `
        SELECT p.id, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
               p.caption, p.taken_at, p.created_at, p.updated_at,
               a.title AS album_title,
               (
                 SELECT COUNT(*)
                 FROM photo_comments pc
                 WHERE pc.photo_id = p.id
               ) AS comment_count
        FROM album_photos p
        INNER JOIN albums a ON a.id = p.album_id
        WHERE p.id = $1 AND p.couple_id = $2
      `,
      [photoId, coupleId],
    );
    await client.query('COMMIT');
    return mapPhotoRow(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function pickNewCoverForAlbum(client, albumId, coupleId) {
  const latest = await client.query(
    `
      SELECT image_url FROM album_photos
      WHERE album_id = $1 AND couple_id = $2
      ORDER BY created_at DESC, id DESC
      LIMIT 1
    `,
    [albumId, coupleId],
  );
  const cover = latest.rowCount > 0 ? latest.rows[0].image_url : null;
  const now = new Date().toISOString();
  await client.query('UPDATE albums SET cover_photo_url = $1, updated_at = $2 WHERE id = $3 AND couple_id = $4', [
    cover,
    now,
    albumId,
    coupleId,
  ]);
}

/**
 * POST /album/photo/delete
 */
async function deleteAlbumPhotoPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const photoId = normalizeRequired(payload.photoId, 'photoId');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const photo = await assertPhotoInCouple(client, photoId, coupleId);
    if (photo.uploader_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only uploader can delete this photo', 403);
    }

    const album = await assertAlbumInCouple(client, photo.album_id, coupleId);
    const wasCover = album.cover_photo_url && album.cover_photo_url === photo.image_url;

    tryDeleteLocalFileByImageUrl(photo.image_url);

    await client.query('DELETE FROM album_photos WHERE id = $1 AND couple_id = $2', [photoId, coupleId]);

    if (wasCover) {
      await pickNewCoverForAlbum(client, photo.album_id, coupleId);
    } else {
      const now = new Date().toISOString();
      await client.query('UPDATE albums SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
        now,
        photo.album_id,
        coupleId,
      ]);
    }

    await client.query('COMMIT');
    return { id: photoId, deleted: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/comment/list
 */
async function listPhotoCommentsPg(pool, { photoId, coupleId, currentUserId }) {
  const trimmedPhotoId = normalizeRequired(photoId, 'photoId');
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');

  const client = await pool.connect();
  try {
    await assertUserInCouple(client, trimmedCoupleId, trimmedCurrentUserId);
    await assertPhotoInCouple(client, trimmedPhotoId, trimmedCoupleId);

    const rows = await client.query(
      `
        SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        FROM photo_comments
        WHERE photo_id = $1 AND couple_id = $2
        ORDER BY created_at ASC, id ASC
      `,
      [trimmedPhotoId, trimmedCoupleId],
    );
    return rows.rows.map(mapCommentRow);
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/comment/create
 */
async function createPhotoCommentPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const photoId = normalizeRequired(payload.photoId, 'photoId');
  const content = normalizeRequired(payload.content, 'content');
  const id = String(payload.id || '').trim() || newCommentId();

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await assertUserInCouple(client, coupleId, currentUserId);
    const photo = await assertPhotoInCouple(client, photoId, coupleId);

    const existing = await client.query('SELECT id FROM photo_comments WHERE id = $1 AND couple_id = $2', [
      id,
      coupleId,
    ]);
    if (existing.rowCount > 0) {
      throw new AppError('comment_already_exists', 'Comment already exists', 409);
    }

    const now = new Date().toISOString();
    await client.query(
      `
        INSERT INTO photo_comments (
          id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
      `,
      [id, photoId, coupleId, currentUserId, content, now, now],
    );
    await client.query('UPDATE album_photos SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
      now,
      photoId,
      coupleId,
    ]);
    await client.query('UPDATE albums SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
      now,
      photo.album_id,
      coupleId,
    ]);

    const result = await client.query(
      `
        SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        FROM photo_comments
        WHERE id = $1 AND couple_id = $2
      `,
      [id, coupleId],
    );
    await client.query('COMMIT');
    return mapCommentRow(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * POST /album/photo/comment/delete
 */
async function deletePhotoCommentPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const commentId = normalizeRequired(payload.commentId, 'commentId');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const comment = await assertCommentInCouple(client, commentId, coupleId);
    if (comment.author_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only author can delete this comment', 403);
    }
    const photo = await assertPhotoInCouple(client, comment.photo_id, coupleId);

    await client.query('DELETE FROM photo_comments WHERE id = $1 AND couple_id = $2', [commentId, coupleId]);

    const now = new Date().toISOString();
    await client.query('UPDATE album_photos SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
      now,
      comment.photo_id,
      coupleId,
    ]);
    await client.query('UPDATE albums SET updated_at = $1 WHERE id = $2 AND couple_id = $3', [
      now,
      photo.album_id,
      coupleId,
    ]);

    await client.query('COMMIT');
    return { id: commentId, deleted: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listAlbumsPg,
  createAlbumPg,
  updateAlbumPg,
  deleteAlbumPg,
  listAlbumPhotosPg,
  uploadAlbumPhotoPg,
  updateAlbumPhotoPg,
  deleteAlbumPhotoPg,
  listPhotoCommentsPg,
  createPhotoCommentPg,
  deletePhotoCommentPg,
};

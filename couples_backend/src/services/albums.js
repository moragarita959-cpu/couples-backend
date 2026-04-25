const { AppError } = require('../errors');

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

function normalizeIso(value, field, { allowNull = false } = {}) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    if (allowNull) {
      return null;
    }
    throw new AppError('invalid_request', `${field} is required`);
  }
  if (Number.isNaN(Date.parse(trimmed))) {
    throw new AppError('invalid_request', `${field} must be a valid ISO timestamp`);
  }
  return trimmed;
}

function buildPublicMediaUrl(publicBaseUrl, relativePath) {
  const base = String(publicBaseUrl || '').replace(/\/+$/, '');
  const relative = String(relativePath || '').replace(/\\/g, '/');
  return `${base}${relative.startsWith('/') ? relative : `/${relative}`}`;
}

function ensureCoupleMember(db, coupleId, currentUserId) {
  const couple = db
    .prepare('SELECT id, user1_id, user2_id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');
  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('forbidden', 'Current user does not belong to couple', 403);
  }
  return couple;
}

function ensureAlbumAccessible(db, albumId, coupleId, currentUserId) {
  ensureCoupleMember(db, coupleId, currentUserId);
  const album = db
    .prepare(
      `
        SELECT id, couple_id, title, description, cover_photo_url,
               created_by_user_id, created_at, updated_at
        FROM albums
        WHERE id = ? AND couple_id = ?
      `,
    )
    .get(albumId, coupleId);
  if (!album) {
    throw new AppError('album_not_found', 'Album not found', 404);
  }
  return album;
}

function ensurePhotoAccessible(db, photoId, coupleId, currentUserId) {
  ensureCoupleMember(db, coupleId, currentUserId);
  const photo = db
    .prepare(
      `
        SELECT id, album_id, couple_id, uploader_user_id, image_url, local_path,
               caption, taken_at, created_at, updated_at
        FROM album_photos
        WHERE id = ? AND couple_id = ?
      `,
    )
    .get(photoId, coupleId);
  if (!photo) {
    throw new AppError('photo_not_found', 'Photo not found', 404);
  }
  return photo;
}

function ensureCommentAccessible(db, commentId, coupleId, currentUserId) {
  ensureCoupleMember(db, coupleId, currentUserId);
  const comment = db
    .prepare(
      `
        SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        FROM photo_comments
        WHERE id = ? AND couple_id = ?
      `,
    )
    .get(commentId, coupleId);
  if (!comment) {
    throw new AppError('comment_not_found', 'Comment not found', 404);
  }
  return comment;
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

function listAlbums(db, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  ensureCoupleMember(db, trimmedCoupleId, trimmedCurrentUserId);

  const rows = db
    .prepare(
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
        WHERE a.couple_id = ?
        GROUP BY a.id
        ORDER BY a.updated_at DESC, a.id DESC
      `,
    )
    .all(trimmedCoupleId);
  return rows.map(mapAlbumRow);
}

function newLocalAlbumId() {
  return `album-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

function newLocalPhotoId() {
  return `photo-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

function newLocalCommentId() {
  return `comment-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
}

function createAlbum(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = String(payload.id || payload.albumId || '').trim() || newLocalAlbumId();
  const title = normalizeRequired(payload.title, 'title');
  const description = String(payload.description || '').trim();
  const coverPhotoUrl = normalizeOptional(payload.coverPhotoUrl);
  const now = new Date().toISOString();
  const createdAt = payload.createdAt
    ? normalizeIso(payload.createdAt, 'createdAt')
    : now;
  const updatedAt = payload.updatedAt
    ? normalizeIso(payload.updatedAt, 'updatedAt')
    : now;

  const transaction = db.transaction(() => {
    ensureCoupleMember(db, coupleId, currentUserId);
    const existing = db.prepare('SELECT id FROM albums WHERE id = ? AND couple_id = ?').get(id, coupleId);
    if (existing) {
      throw new AppError('album_already_exists', 'Album already exists', 409);
    }
    db.prepare(
      `
        INSERT INTO albums (
          id, couple_id, title, description, cover_photo_url,
          created_by_user_id, created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `,
    ).run(id, coupleId, title, description, coverPhotoUrl, currentUserId, createdAt, updatedAt);
    return db
      .prepare(
        `
          SELECT a.*, 0 AS photo_count, NULL AS last_photo_at, NULL AS fallback_cover_photo_url
          FROM albums a
          WHERE a.id = ? AND a.couple_id = ?
        `,
      )
      .get(id, coupleId);
  });

  return mapAlbumRow(transaction());
}

function updateAlbum(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = normalizeRequired(payload.albumId || payload.id, 'albumId');
  const title = normalizeRequired(payload.title, 'title');
  const description = String(payload.description || '').trim();
  const updatedAt = new Date().toISOString();

  const transaction = db.transaction(() => {
    ensureAlbumAccessible(db, id, coupleId, currentUserId);
    db.prepare(
      `
        UPDATE albums
        SET title = ?, description = ?, updated_at = ?
        WHERE id = ? AND couple_id = ?
      `,
    ).run(title, description, updatedAt, id, coupleId);
    return db
      .prepare(
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
          WHERE a.id = ? AND a.couple_id = ?
          GROUP BY a.id
        `,
      )
      .get(id, coupleId);
  });

  return mapAlbumRow(transaction());
}

function deleteAlbum(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const albumId = normalizeRequired(payload.albumId, 'albumId');

  const transaction = db.transaction(() => {
    ensureAlbumAccessible(db, albumId, coupleId, currentUserId);
    const photos = db.prepare('SELECT id FROM album_photos WHERE album_id = ? AND couple_id = ?').all(albumId, coupleId);
    for (const photo of photos) {
      db.prepare('DELETE FROM photo_comments WHERE photo_id = ?').run(photo.id);
    }
    db.prepare('DELETE FROM album_photos WHERE album_id = ? AND couple_id = ?').run(albumId, coupleId);
    db.prepare('DELETE FROM albums WHERE id = ? AND couple_id = ?').run(albumId, coupleId);
    return { id: albumId, deleted: true };
  });

  return transaction();
}

function listAlbumPhotos(db, { albumId, coupleId, currentUserId }) {
  const trimmedAlbumId = normalizeRequired(albumId, 'albumId');
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  ensureAlbumAccessible(db, trimmedAlbumId, trimmedCoupleId, trimmedCurrentUserId);

  const rows = db
    .prepare(
      `
        SELECT p.id, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
               p.caption, p.taken_at, p.created_at, p.updated_at,
               a.title AS album_title,
               COUNT(c.id) AS comment_count
        FROM album_photos p
        INNER JOIN albums a ON a.id = p.album_id
        LEFT JOIN photo_comments c ON c.photo_id = p.id
        WHERE p.album_id = ? AND p.couple_id = ?
        GROUP BY p.id
        ORDER BY p.created_at DESC, p.id DESC
      `,
    )
    .all(trimmedAlbumId, trimmedCoupleId);
  return rows.map(mapPhotoRow);
}

function uploadAlbumPhoto(db, payload, publicBaseUrl) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const albumId = normalizeRequired(payload.albumId, 'albumId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = String(payload.id || '').trim() || newLocalPhotoId();
  const caption = String(payload.caption || '').trim();
  const takenAt = payload.takenAt
    ? normalizeIso(payload.takenAt, 'takenAt', { allowNull: true })
    : null;
  const now = new Date().toISOString();
  const createdAt = payload.createdAt ? normalizeIso(payload.createdAt, 'createdAt') : now;
  const updatedAt = payload.updatedAt
    ? normalizeIso(payload.updatedAt, 'updatedAt')
    : now;
  const file = payload.file;
  if (!file || !file.filename) {
    throw new AppError('invalid_request', 'file is required');
  }

  const transaction = db.transaction(() => {
    ensureAlbumAccessible(db, albumId, coupleId, currentUserId);
    const existing = db.prepare('SELECT id FROM album_photos WHERE id = ? AND couple_id = ?').get(id, coupleId);
    if (existing) {
      throw new AppError('photo_already_exists', 'Photo already exists', 409);
    }
    const imageUrl = buildPublicMediaUrl(publicBaseUrl, `/media/album/${file.filename}`);
    db.prepare(
      `
        INSERT INTO album_photos (
          id, album_id, couple_id, uploader_user_id, image_url, local_path,
          caption, taken_at, created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
    ).run(
      id,
      albumId,
      coupleId,
      currentUserId,
      imageUrl,
      normalizeOptional(payload.localPath),
      caption,
      takenAt,
      createdAt,
      updatedAt,
    );
    db.prepare('UPDATE albums SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      updatedAt,
      albumId,
      coupleId,
    );
    return db
      .prepare(
        `
          SELECT p.id, p.album_id, p.couple_id, p.uploader_user_id, p.image_url, p.local_path,
                 p.caption, p.taken_at, p.created_at, p.updated_at,
                 a.title AS album_title, 0 AS comment_count
          FROM album_photos p
          INNER JOIN albums a ON a.id = p.album_id
          WHERE p.id = ? AND p.couple_id = ?
        `,
      )
      .get(id, coupleId);
  });

  return mapPhotoRow(transaction());
}

function updateAlbumPhoto(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = normalizeRequired(payload.photoId || payload.id, 'photoId');
  const caption = String(payload.caption || '').trim();
  const updatedAt = new Date().toISOString();

  const transaction = db.transaction(() => {
    const existing = ensurePhotoAccessible(db, id, coupleId, currentUserId);
    if (existing.uploader_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only uploader can update this photo', 403);
    }
    db.prepare(
      `
        UPDATE album_photos
        SET caption = ?, updated_at = ?
        WHERE id = ? AND couple_id = ?
      `,
    ).run(caption, updatedAt, id, coupleId);
    db.prepare('UPDATE albums SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      updatedAt,
      existing.album_id,
      coupleId,
    );
    return db
      .prepare(
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
          WHERE p.id = ? AND p.couple_id = ?
        `,
      )
      .get(id, coupleId);
  });

  return mapPhotoRow(transaction());
}

function deleteAlbumPhoto(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const photoId = normalizeRequired(payload.photoId, 'photoId');

  const transaction = db.transaction(() => {
    const photo = ensurePhotoAccessible(db, photoId, coupleId, currentUserId);
    if (photo.uploader_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only uploader can delete this photo', 403);
    }
    db.prepare('DELETE FROM photo_comments WHERE photo_id = ?').run(photoId);
    db.prepare('DELETE FROM album_photos WHERE id = ? AND couple_id = ?').run(photoId, coupleId);
    db.prepare('UPDATE albums SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      new Date().toISOString(),
      photo.album_id,
      coupleId,
    );
    return { id: photoId, deleted: true };
  });

  return transaction();
}

function listPhotoComments(db, { photoId, coupleId, currentUserId }) {
  const trimmedPhotoId = normalizeRequired(photoId, 'photoId');
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  ensurePhotoAccessible(db, trimmedPhotoId, trimmedCoupleId, trimmedCurrentUserId);

  const rows = db
    .prepare(
      `
        SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        FROM photo_comments
        WHERE photo_id = ? AND couple_id = ?
        ORDER BY created_at ASC, id ASC
      `,
    )
    .all(trimmedPhotoId, trimmedCoupleId);
  return rows.map(mapCommentRow);
}

function createPhotoComment(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const photoId = normalizeRequired(payload.photoId, 'photoId');
  const id = String(payload.id || '').trim() || newLocalCommentId();
  const content = normalizeRequired(payload.content, 'content');
  const now = new Date().toISOString();
  const createdAt = payload.createdAt ? normalizeIso(payload.createdAt, 'createdAt') : now;
  const updatedAt = payload.updatedAt
    ? normalizeIso(payload.updatedAt, 'updatedAt')
    : now;

  const transaction = db.transaction(() => {
    const photo = ensurePhotoAccessible(db, photoId, coupleId, currentUserId);
    const existing = db.prepare('SELECT id FROM photo_comments WHERE id = ? AND couple_id = ?').get(id, coupleId);
    if (existing) {
      throw new AppError('comment_already_exists', 'Comment already exists', 409);
    }
    db.prepare(
      `
        INSERT INTO photo_comments (
          id, photo_id, couple_id, author_user_id, content, created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `,
    ).run(id, photoId, coupleId, currentUserId, content, createdAt, updatedAt);
    db.prepare('UPDATE album_photos SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      updatedAt,
      photoId,
      coupleId,
    );
    db.prepare('UPDATE albums SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      updatedAt,
      photo.album_id,
      coupleId,
    );
    return db
      .prepare(
        `
          SELECT id, photo_id, couple_id, author_user_id, content, created_at, updated_at
          FROM photo_comments
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(id, coupleId);
  });

  return mapCommentRow(transaction());
}

function deletePhotoComment(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const commentId = normalizeRequired(payload.commentId, 'commentId');

  const transaction = db.transaction(() => {
    const comment = ensureCommentAccessible(db, commentId, coupleId, currentUserId);
    if (comment.author_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only author can delete this comment', 403);
    }
    const photo = ensurePhotoAccessible(db, comment.photo_id, coupleId, currentUserId);
    db.prepare('DELETE FROM photo_comments WHERE id = ? AND couple_id = ?').run(commentId, coupleId);
    const now = new Date().toISOString();
    db.prepare('UPDATE album_photos SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      now,
      comment.photo_id,
      coupleId,
    );
    db.prepare('UPDATE albums SET updated_at = ? WHERE id = ? AND couple_id = ?').run(
      now,
      photo.album_id,
      coupleId,
    );
    return { id: commentId, deleted: true };
  });

  return transaction();
}

module.exports = {
  listAlbums,
  createAlbum,
  updateAlbum,
  deleteAlbum,
  listAlbumPhotos,
  uploadAlbumPhoto,
  updateAlbumPhoto,
  deleteAlbumPhoto,
  listPhotoComments,
  createPhotoComment,
  deletePhotoComment,
};

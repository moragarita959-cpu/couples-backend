const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

async function ensureCouplePg(client, coupleId) {
  const result = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return result.rows[0];
}

function ensureMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function parseStyleTags(raw) {
  if (!raw || !String(raw).trim()) {
    return [];
  }
  try {
    const decoded = JSON.parse(raw);
    if (Array.isArray(decoded)) {
      return decoded.filter((item) => typeof item === 'string' && item.trim());
    }
  } catch (_) {
    return [];
  }
  return [];
}

async function listPlaylistSongsPg(pool, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = String(currentUserId || '').trim();
  const client = await pool.connect();
  try {
    await ensureCouplePg(client, trimmedCoupleId);
  } finally {
    client.release();
  }

  const rows = await pool.query(
    `
      SELECT id, couple_id, name, artist, genre, recommender_user_id,
             created_at, updated_at, preference, is_deleted
      FROM playlist_songs
      WHERE couple_id = $1 AND is_deleted = false
      ORDER BY created_at DESC, id DESC
    `,
    [trimmedCoupleId],
  );

  return rows.rows.map((row) => ({
    id: row.id,
    name: row.name,
    artist: row.artist,
    genre: row.genre || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at || row.created_at,
    preference: row.preference,
    recommender:
      trimmedCurrentUserId && row.recommender_user_id === trimmedCurrentUserId ? 'me' : 'partner',
    isDeleted: row.is_deleted === true,
  }));
}

async function upsertPlaylistSongPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = normalizeRequired(payload.id, 'id');
  const name = normalizeRequired(payload.name, 'name');
  const artist = normalizeRequired(payload.artist, 'artist');
  const genre = String(payload.genre || '').trim();
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = String(payload.updatedAt || createdAt).trim() || createdAt;
  const preference = String(payload.preference || 'none').trim() || 'none';
  const isDeleted = payload.isDeleted === true;

  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouplePg(client, coupleId);
    ensureMember(couple, currentUserId);

    const existing = await client.query(
      'SELECT id FROM playlist_songs WHERE id = $1 AND couple_id = $2',
      [id, coupleId],
    );

    if (existing.rowCount === 0 && !isDeleted) {
      const duplicate = await client.query(
        `
          SELECT id
          FROM playlist_songs
          WHERE couple_id = $1
            AND is_deleted = false
            AND LOWER(TRIM(name)) = LOWER(TRIM($2))
            AND LOWER(TRIM(artist)) = LOWER(TRIM($3))
          LIMIT 1
        `,
        [coupleId, name, artist],
      );
      if (duplicate.rowCount > 0) {
        throw new AppError('duplicate_playlist_song', 'Song already exists', 409);
      }
    }

    if (existing.rowCount > 0) {
      await client.query(
        `
          UPDATE playlist_songs
          SET name = $1, artist = $2, genre = $3, created_at = $4, updated_at = $5,
              preference = $6, is_deleted = $7
          WHERE id = $8 AND couple_id = $9
        `,
        [name, artist, genre, createdAt, updatedAt, preference, isDeleted, id, coupleId],
      );
    } else {
      await client.query(
        `
          INSERT INTO playlist_songs (
            id, couple_id, name, artist, genre, recommender_user_id,
            created_at, updated_at, preference, is_deleted
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        `,
        [id, coupleId, name, artist, genre, currentUserId, createdAt, updatedAt, preference, isDeleted],
      );
    }

    await client.query('COMMIT');
    return {
      id,
      name,
      artist,
      genre,
      createdAt,
      updatedAt,
      preference,
      recommender: 'me',
      isDeleted,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deletePlaylistSongPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const songId = normalizeRequired(payload.songId, 'songId');
  const updatedAt = normalizeRequired(payload.updatedAt, 'updatedAt');
  if (Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouplePg(client, coupleId);
    ensureMember(couple, currentUserId);

    const existing = await client.query(
      'SELECT id FROM playlist_songs WHERE id = $1 AND couple_id = $2',
      [songId, coupleId],
    );
    if (existing.rowCount === 0) {
      throw new AppError('song_not_found', 'Song not found', 404);
    }
    await client.query(
      `
        UPDATE playlist_songs
        SET is_deleted = true, updated_at = $1
        WHERE id = $2 AND couple_id = $3
      `,
      [updatedAt, songId, coupleId],
    );
    await client.query('COMMIT');
    return { id: songId, updatedAt, isDeleted: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function listPlaylistReviewsPg(pool, { coupleId, songId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedSongId = normalizeRequired(songId, 'songId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const client = await pool.connect();
  try {
    const couple = await ensureCouplePg(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
  } finally {
    client.release();
  }

  const rows = await pool.query(
    `
      SELECT id, couple_id, song_id, author_user_id, content, style_tags,
             atmosphere_score, resonance_score, share_score, created_at
      FROM playlist_reviews
      WHERE couple_id = $1 AND song_id = $2
      ORDER BY created_at DESC, id DESC
    `,
    [trimmedCoupleId, trimmedSongId],
  );

  return rows.rows.map((row) => ({
    id: row.id,
    songId: row.song_id,
    author: row.author_user_id === trimmedCurrentUserId ? 'me' : 'partner',
    content: row.content,
    styleTags: parseStyleTags(row.style_tags),
    atmosphereScore: Number(row.atmosphere_score) || 0,
    resonanceScore: Number(row.resonance_score) || 0,
    shareScore: Number(row.share_score) || 0,
    createdAt: row.created_at,
  }));
}

async function upsertPlaylistReviewPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const songId = normalizeRequired(payload.songId, 'songId');
  const content = String(payload.content || '').trim();
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const styleTags = Array.isArray(payload.styleTags) ? payload.styleTags : [];
  const atmosphereScore = Number(payload.atmosphereScore || 0);
  const resonanceScore = Number(payload.resonanceScore || 0);
  const shareScore = Number(payload.shareScore || 0);

  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouplePg(client, coupleId);
    ensureMember(couple, currentUserId);

    const existing = await client.query(
      `
        SELECT id
        FROM playlist_reviews
        WHERE couple_id = $1 AND song_id = $2 AND author_user_id = $3
      `,
      [coupleId, songId, currentUserId],
    );

    const id = existing.rows[0]?.id || String(payload.id || '').trim() || `review-${Date.now()}`;
    if (existing.rowCount > 0) {
      await client.query(
        `
          UPDATE playlist_reviews
          SET content = $1, style_tags = $2, atmosphere_score = $3, resonance_score = $4,
              share_score = $5, created_at = $6
          WHERE id = $7 AND couple_id = $8
        `,
        [
          content,
          JSON.stringify(styleTags),
          atmosphereScore,
          resonanceScore,
          shareScore,
          createdAt,
          id,
          coupleId,
        ],
      );
    } else {
      await client.query(
        `
          INSERT INTO playlist_reviews (
            id, couple_id, song_id, author_user_id, content, style_tags,
            atmosphere_score, resonance_score, share_score, created_at
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        `,
        [
          id,
          coupleId,
          songId,
          currentUserId,
          content,
          JSON.stringify(styleTags),
          atmosphereScore,
          resonanceScore,
          shareScore,
          createdAt,
        ],
      );
    }

    await client.query('COMMIT');
    return {
      id,
      songId,
      author: 'me',
      content,
      styleTags,
      atmosphereScore,
      resonanceScore,
      shareScore,
      createdAt,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listPlaylistSongsPg,
  upsertPlaylistSongPg,
  deletePlaylistSongPg,
  listPlaylistReviewsPg,
  upsertPlaylistReviewPg,
};

const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

function ensureCouple(db, coupleId) {
  const couple = db
    .prepare('SELECT id, user1_id, user2_id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');
  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return couple;
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

function listPlaylistSongs(db, { coupleId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  ensureCouple(db, trimmedCoupleId);
  const rows = db
    .prepare(
      `
        SELECT id, couple_id, name, artist, created_at, preference
        FROM playlist_songs
        WHERE couple_id = ?
        ORDER BY created_at DESC, id DESC
      `,
    )
    .all(trimmedCoupleId);

  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    artist: row.artist,
    createdAt: row.created_at,
    preference: row.preference,
  }));
}

function upsertPlaylistSong(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const id = normalizeRequired(payload.id, 'id');
  const name = normalizeRequired(payload.name, 'name');
  const artist = normalizeRequired(payload.artist, 'artist');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const preference = String(payload.preference || 'none').trim() || 'none';

  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }

  const transaction = db.transaction(() => {
    ensureCouple(db, coupleId);
    const existing = db
      .prepare('SELECT id FROM playlist_songs WHERE id = ? AND couple_id = ?')
      .get(id, coupleId);

    if (existing) {
      db.prepare(
        `
          UPDATE playlist_songs
          SET name = ?, artist = ?, created_at = ?, preference = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(name, artist, createdAt, preference, id, coupleId);
    } else {
      db.prepare(
        `
          INSERT INTO playlist_songs (id, couple_id, name, artist, created_at, preference)
          VALUES (?, ?, ?, ?, ?, ?)
        `,
      ).run(id, coupleId, name, artist, createdAt, preference);
    }

    return {
      id,
      name,
      artist,
      createdAt,
      preference,
    };
  });

  return transaction();
}

function listPlaylistReviews(db, { coupleId, songId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedSongId = normalizeRequired(songId, 'songId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const couple = ensureCouple(db, trimmedCoupleId);
  ensureMember(couple, trimmedCurrentUserId);

  const rows = db
    .prepare(
      `
        SELECT id, couple_id, song_id, author_user_id, content, style_tags,
               atmosphere_score, resonance_score, share_score, created_at
        FROM playlist_reviews
        WHERE couple_id = ? AND song_id = ?
        ORDER BY created_at DESC, id DESC
      `,
    )
    .all(trimmedCoupleId, trimmedSongId);

  return rows.map((row) => ({
    id: row.id,
    songId: row.song_id,
    author: row.author_user_id === trimmedCurrentUserId ? 'me' : 'partner',
    content: row.content,
    styleTags: parseStyleTags(row.style_tags),
    atmosphereScore: row.atmosphere_score,
    resonanceScore: row.resonance_score,
    shareScore: row.share_score,
    createdAt: row.created_at,
  }));
}

function upsertPlaylistReview(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const songId = normalizeRequired(payload.songId, 'songId');
  const content = normalizeRequired(payload.content, 'content');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const styleTags = Array.isArray(payload.styleTags) ? payload.styleTags : [];
  const atmosphereScore = Number(payload.atmosphereScore || 0);
  const resonanceScore = Number(payload.resonanceScore || 0);
  const shareScore = Number(payload.shareScore || 0);

  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }

  const transaction = db.transaction(() => {
    const couple = ensureCouple(db, coupleId);
    ensureMember(couple, currentUserId);

    const existing = db
      .prepare(
        `
          SELECT id
          FROM playlist_reviews
          WHERE couple_id = ? AND song_id = ? AND author_user_id = ?
        `,
      )
      .get(coupleId, songId, currentUserId);

    const id = existing?.id || String(payload.id || '').trim() || `review-${Date.now()}`;

    if (existing) {
      db.prepare(
        `
          UPDATE playlist_reviews
          SET content = ?, style_tags = ?, atmosphere_score = ?, resonance_score = ?,
              share_score = ?, created_at = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(
        content,
        JSON.stringify(styleTags),
        atmosphereScore,
        resonanceScore,
        shareScore,
        createdAt,
        id,
        coupleId,
      );
    } else {
      db.prepare(
        `
          INSERT INTO playlist_reviews (
            id, couple_id, song_id, author_user_id, content, style_tags,
            atmosphere_score, resonance_score, share_score, created_at
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
      ).run(
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
      );
    }

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
  });

  return transaction();
}

module.exports = {
  listPlaylistSongs,
  upsertPlaylistSong,
  listPlaylistReviews,
  upsertPlaylistReview,
};

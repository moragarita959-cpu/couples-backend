const fs = require('fs');
const { Pool } = require('pg');

const config = require('./config');

fs.mkdirSync(config.chatMediaDir, { recursive: true });
fs.mkdirSync(config.albumMediaDir, { recursive: true });

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

  await pool.query(`
    CREATE TABLE IF NOT EXISTS bill_records (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      owner_user_id TEXT NOT NULL DEFAULT '',
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      amount DOUBLE PRECISION NOT NULL,
      note TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      is_deleted BOOLEAN NOT NULL DEFAULT FALSE
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_bill_records_couple_updated
      ON bill_records(couple_id, updated_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS playlist_songs (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      name TEXT NOT NULL,
      artist TEXT NOT NULL,
      genre TEXT NOT NULL DEFAULT '',
      recommender_user_id TEXT NOT NULL DEFAULT '',
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      preference TEXT NOT NULL DEFAULT 'none',
      is_deleted BOOLEAN NOT NULL DEFAULT FALSE
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_playlist_songs_couple_created
      ON playlist_songs(couple_id, created_at, id);
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_playlist_songs_couple_name_artist
      ON playlist_songs(couple_id, name, artist, is_deleted);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS playlist_reviews (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      song_id TEXT NOT NULL,
      author_user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      style_tags TEXT NOT NULL DEFAULT '[]',
      atmosphere_score INTEGER NOT NULL DEFAULT 0,
      resonance_score INTEGER NOT NULL DEFAULT 0,
      share_score INTEGER NOT NULL DEFAULT 0,
      created_at TIMESTAMPTZ NOT NULL,
      UNIQUE(couple_id, song_id, author_user_id)
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_playlist_reviews_couple_song_created
      ON playlist_reviews(couple_id, song_id, created_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS todo_items (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      due_at TIMESTAMPTZ NULL,
      owner_type TEXT NOT NULL,
      owner_user_id TEXT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
      done_user_ids TEXT NOT NULL DEFAULT '[]'
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_todo_items_couple_updated
      ON todo_items(couple_id, updated_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS countdown_events (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      name TEXT NOT NULL,
      date TIMESTAMPTZ NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL,
      is_deleted BOOLEAN NOT NULL DEFAULT FALSE
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_countdown_events_couple_updated
      ON countdown_events(couple_id, updated_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS poke_events (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      sender_user_id TEXT NOT NULL,
      message TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_poke_events_couple_created
      ON poke_events(couple_id, created_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS albums (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NULL,
      cover_photo_url TEXT NULL,
      created_by_user_id TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_albums_couple_id
      ON albums(couple_id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS album_photos (
      id TEXT PRIMARY KEY,
      album_id TEXT NOT NULL,
      couple_id TEXT NOT NULL,
      uploader_user_id TEXT NOT NULL,
      image_url TEXT NOT NULL,
      local_path TEXT NULL,
      caption TEXT NULL,
      taken_at TIMESTAMPTZ NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_album_photos_album_id
      ON album_photos(album_id);
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_album_photos_couple_id
      ON album_photos(couple_id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS photo_comments (
      id TEXT PRIMARY KEY,
      photo_id TEXT NOT NULL,
      couple_id TEXT NOT NULL,
      author_user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_photo_comments_photo_id
      ON photo_comments(photo_id);
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_photo_comments_couple_id
      ON photo_comments(couple_id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS schedule_courses (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      title TEXT NOT NULL,
      weekday INTEGER NOT NULL,
      start_minute INTEGER NOT NULL,
      end_minute INTEGER NOT NULL,
      start_week INTEGER NOT NULL,
      end_week INTEGER NOT NULL,
      repeat_weekly BOOLEAN NOT NULL DEFAULT TRUE,
      start_period INTEGER NOT NULL,
      end_period INTEGER NOT NULL,
      location TEXT NOT NULL,
      teacher TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      owner_user_id TEXT NOT NULL,
      color_hex TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_schedule_courses_couple_updated
      ON schedule_courses(couple_id, updated_at, id);
  `);

  // Thoughts redesign reset: drop legacy tables so we can recreate with the new
  // multi-tag + sticker schema. Other modules' tables remain untouched.
  await pool.query('DROP TABLE IF EXISTS thought_comments');
  await pool.query('DROP TABLE IF EXISTS idea_notes');
  await pool.query('DROP TABLE IF EXISTS excerpt_notes');

  await pool.query(`
    CREATE TABLE IF NOT EXISTS idea_notes (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      author_user_id TEXT NOT NULL,
      type TEXT NOT NULL,
      title TEXT NULL,
      content TEXT NOT NULL,
      mood_tags TEXT NULL,
      color_style TEXT NULL,
      layout_style TEXT NULL,
      sticker_style TEXT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_idea_notes_couple_updated
      ON idea_notes(couple_id, updated_at DESC, id DESC);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS excerpt_notes (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      author_user_id TEXT NOT NULL,
      category TEXT NOT NULL,
      quote_text TEXT NOT NULL,
      source_title TEXT NULL,
      source_author TEXT NULL,
      source_detail TEXT NULL,
      personal_note TEXT NULL,
      card_style TEXT NULL,
      color_style TEXT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_excerpt_notes_couple_updated
      ON excerpt_notes(couple_id, updated_at DESC, id DESC);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS thought_comments (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      target_type TEXT NOT NULL,
      target_id TEXT NOT NULL,
      author_user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_thought_comments_target_created
      ON thought_comments(target_type, target_id, created_at, id);
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_thought_comments_couple_target
      ON thought_comments(couple_id, target_type, target_id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS feed_events (
      id TEXT PRIMARY KEY,
      couple_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      actor_user_id TEXT NOT NULL,
      target_type TEXT NOT NULL,
      target_id TEXT NOT NULL,
      summary_text TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      is_read BOOLEAN NOT NULL DEFAULT FALSE
    );
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_feed_events_couple_created
      ON feed_events(couple_id, created_at, id);
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS distance_locations (
      couple_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      latitude DOUBLE PRECISION NOT NULL,
      longitude DOUBLE PRECISION NOT NULL,
      is_visible BOOLEAN NOT NULL DEFAULT TRUE,
      location_label TEXT NOT NULL DEFAULT '',
      updated_at TIMESTAMPTZ NOT NULL,
      PRIMARY KEY (couple_id, user_id)
    );
  `);
  await pool.query(`
    ALTER TABLE distance_locations
    ADD COLUMN IF NOT EXISTS is_visible BOOLEAN NOT NULL DEFAULT TRUE;
  `);
  await pool.query(`
    ALTER TABLE distance_locations
    ADD COLUMN IF NOT EXISTS location_label TEXT NOT NULL DEFAULT '';
  `);
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_distance_locations_couple_updated
      ON distance_locations(couple_id, updated_at);
  `);

  await migrateAlbumPostgresSchema(pool);
}

/**
 * 为已有环境补齐外键与 ON DELETE CASCADE；新环境 CREATE TABLE 后也会执行，幂等。
 */
async function migrateAlbumPostgresSchema(pool) {
  await pool.query(`
    DO $migration$
    BEGIN
      -- 清孤儿，避免加约束失败
      DELETE FROM photo_comments pc
      WHERE NOT EXISTS (SELECT 1 FROM album_photos ap WHERE ap.id = pc.photo_id);

      DELETE FROM album_photos p
      WHERE NOT EXISTS (SELECT 1 FROM albums a WHERE a.id = p.album_id);

      IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'public'
          AND table_name = 'album_photos'
          AND constraint_name = 'fk_album_photos_album'
      ) THEN
        ALTER TABLE album_photos
          ADD CONSTRAINT fk_album_photos_album
          FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE;
      END IF;

      IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_schema = 'public'
          AND table_name = 'photo_comments'
          AND constraint_name = 'fk_photo_comments_photo'
      ) THEN
        ALTER TABLE photo_comments
          ADD CONSTRAINT fk_photo_comments_photo
          FOREIGN KEY (photo_id) REFERENCES album_photos(id) ON DELETE CASCADE;
      END IF;
    END
    $migration$;
  `);
}

module.exports = {
  pool,
  initPostgresSchema,
};

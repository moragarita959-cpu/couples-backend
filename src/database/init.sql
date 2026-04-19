PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  nickname TEXT NOT NULL,
  pair_code TEXT NOT NULL UNIQUE,
  couple_id TEXT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_couple_id ON users(couple_id);

CREATE TABLE IF NOT EXISTS couples (
  id TEXT PRIMARY KEY,
  user1_id TEXT NOT NULL,
  user2_id TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(user1_id, user2_id)
);

CREATE INDEX IF NOT EXISTS idx_couples_user1_id ON couples(user1_id);
CREATE INDEX IF NOT EXISTS idx_couples_user2_id ON couples(user2_id);

CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  sender_user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  client_message_id TEXT NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'text',
  media_url TEXT NULL,
  media_duration_ms INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  UNIQUE(couple_id, client_message_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_couple_created
  ON chat_messages(couple_id, created_at, id);

CREATE TABLE IF NOT EXISTS bill_records (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  note TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_bill_records_couple_updated
  ON bill_records(couple_id, updated_at, id);

CREATE TABLE IF NOT EXISTS todo_items (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  due_at TEXT NULL,
  owner_type TEXT NOT NULL,
  owner_user_id TEXT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  done_user_ids TEXT NOT NULL DEFAULT '[]'
);

CREATE INDEX IF NOT EXISTS idx_todo_items_couple_updated
  ON todo_items(couple_id, updated_at, id);

CREATE TABLE IF NOT EXISTS countdown_events (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  name TEXT NOT NULL,
  date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_countdown_events_couple_updated
  ON countdown_events(couple_id, updated_at, id);

CREATE TABLE IF NOT EXISTS poke_events (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  sender_user_id TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_poke_events_couple_created
  ON poke_events(couple_id, created_at, id);

CREATE TABLE IF NOT EXISTS playlist_songs (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  name TEXT NOT NULL,
  artist TEXT NOT NULL,
  created_at TEXT NOT NULL,
  preference TEXT NOT NULL DEFAULT 'none'
);

CREATE INDEX IF NOT EXISTS idx_playlist_songs_couple_created
  ON playlist_songs(couple_id, created_at, id);

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
  created_at TEXT NOT NULL,
  UNIQUE(couple_id, song_id, author_user_id)
);

CREATE INDEX IF NOT EXISTS idx_playlist_reviews_couple_song_created
  ON playlist_reviews(couple_id, song_id, created_at, id);

CREATE TABLE IF NOT EXISTS schedule_courses (
  id TEXT PRIMARY KEY,
  couple_id TEXT NOT NULL,
  title TEXT NOT NULL,
  weekday INTEGER NOT NULL,
  start_minute INTEGER NOT NULL,
  end_minute INTEGER NOT NULL,
  start_week INTEGER NOT NULL,
  end_week INTEGER NOT NULL,
  repeat_weekly INTEGER NOT NULL DEFAULT 1,
  start_period INTEGER NOT NULL,
  end_period INTEGER NOT NULL,
  location TEXT NOT NULL,
  teacher TEXT NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  owner_user_id TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_schedule_courses_couple_updated
  ON schedule_courses(couple_id, updated_at, id);

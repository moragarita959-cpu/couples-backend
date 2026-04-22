ALTER TABLE playlist_songs ADD COLUMN genre TEXT NOT NULL DEFAULT '';
ALTER TABLE playlist_songs ADD COLUMN recommender_user_id TEXT NOT NULL DEFAULT '';
ALTER TABLE playlist_songs ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE playlist_songs ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;

UPDATE playlist_songs
SET updated_at = created_at
WHERE updated_at IS NULL OR TRIM(updated_at) = '';

CREATE INDEX IF NOT EXISTS idx_playlist_songs_couple_name_artist
  ON playlist_songs(couple_id, name, artist, is_deleted);

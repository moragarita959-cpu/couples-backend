-- Optional: 手动在已有 Railway PostgreSQL 上执行时可用（与 initPostgresSchema 中 migrateAlbumPostgresSchema 等效逻辑）。
-- 启动 Node 时也会自动在 database_pg 中执行迁移。

DO $migration$
BEGIN
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

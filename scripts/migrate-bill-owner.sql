-- Run once on existing DBs (Railway/local) before deploying new server code.
ALTER TABLE bill_records ADD COLUMN owner_user_id TEXT NOT NULL DEFAULT '';

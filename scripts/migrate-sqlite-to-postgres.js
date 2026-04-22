#!/usr/bin/env node
const path = require('path');
const { DatabaseSync } = require('node:sqlite');
const { Pool } = require('pg');
require('dotenv').config();

const sqlitePath = String(process.env.DB_PATH || './data/couples.db').trim();
const databaseUrl = String(process.env.DATABASE_URL || '').trim();

if (!databaseUrl) {
  console.error('Missing DATABASE_URL. Please set it in environment or .env');
  process.exit(1);
}

const resolvedSqlitePath = path.resolve(process.cwd(), sqlitePath);
const sqlite = new DatabaseSync(resolvedSqlitePath, { readOnly: true });
const pg = new Pool({
  connectionString: databaseUrl,
  ssl: { rejectUnauthorized: false },
});

function readRows(table) {
  return sqlite.prepare(`SELECT * FROM ${table}`).all();
}

async function migrateBillRecords(client) {
  const rows = readRows('bill_records');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO bill_records (
        id, couple_id, owner_user_id, type, category, amount, note, created_at, updated_at, is_deleted
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        owner_user_id = EXCLUDED.owner_user_id,
        type = EXCLUDED.type,
        category = EXCLUDED.category,
        amount = EXCLUDED.amount,
        note = EXCLUDED.note,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at,
        is_deleted = EXCLUDED.is_deleted
      `,
      [
        row.id,
        row.couple_id,
        row.owner_user_id || '',
        row.type,
        row.category,
        Number(row.amount) || 0,
        row.note || '',
        row.created_at,
        row.updated_at,
        Number(row.is_deleted) === 1,
      ],
    );
  }
  return rows.length;
}

async function migratePlaylistSongs(client) {
  const rows = readRows('playlist_songs');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO playlist_songs (
        id, couple_id, name, artist, genre, recommender_user_id, created_at, updated_at, preference, is_deleted
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        name = EXCLUDED.name,
        artist = EXCLUDED.artist,
        genre = EXCLUDED.genre,
        recommender_user_id = EXCLUDED.recommender_user_id,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at,
        preference = EXCLUDED.preference,
        is_deleted = EXCLUDED.is_deleted
      `,
      [
        row.id,
        row.couple_id,
        row.name,
        row.artist,
        row.genre || '',
        row.recommender_user_id || '',
        row.created_at,
        row.updated_at || row.created_at,
        row.preference || 'none',
        Number(row.is_deleted) === 1,
      ],
    );
  }
  return rows.length;
}

async function migratePlaylistReviews(client) {
  const rows = readRows('playlist_reviews');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO playlist_reviews (
        id, couple_id, song_id, author_user_id, content, style_tags, atmosphere_score, resonance_score, share_score, created_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        song_id = EXCLUDED.song_id,
        author_user_id = EXCLUDED.author_user_id,
        content = EXCLUDED.content,
        style_tags = EXCLUDED.style_tags,
        atmosphere_score = EXCLUDED.atmosphere_score,
        resonance_score = EXCLUDED.resonance_score,
        share_score = EXCLUDED.share_score,
        created_at = EXCLUDED.created_at
      `,
      [
        row.id,
        row.couple_id,
        row.song_id,
        row.author_user_id,
        row.content || '',
        row.style_tags || '[]',
        Number(row.atmosphere_score) || 0,
        Number(row.resonance_score) || 0,
        Number(row.share_score) || 0,
        row.created_at,
      ],
    );
  }
  return rows.length;
}

async function main() {
  const client = await pg.connect();
  try {
    await client.query('BEGIN');
    const billCount = await migrateBillRecords(client);
    const songCount = await migratePlaylistSongs(client);
    const reviewCount = await migratePlaylistReviews(client);
    await client.query('COMMIT');
    console.log(
      `Migration completed. bill_records=${billCount}, playlist_songs=${songCount}, playlist_reviews=${reviewCount}`,
    );
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Migration failed:', error.message);
    process.exitCode = 1;
  } finally {
    client.release();
    await pg.end();
    sqlite.close();
  }
}

main();

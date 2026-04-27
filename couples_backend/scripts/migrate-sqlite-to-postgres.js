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

async function migrateIdeaNotes(client) {
  const rows = readRows('idea_notes');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO idea_notes (
        id, couple_id, author_user_id, type, title, content, mood_tag,
        color_style, layout_style, created_at, updated_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        author_user_id = EXCLUDED.author_user_id,
        type = EXCLUDED.type,
        title = EXCLUDED.title,
        content = EXCLUDED.content,
        mood_tag = EXCLUDED.mood_tag,
        color_style = EXCLUDED.color_style,
        layout_style = EXCLUDED.layout_style,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at
      `,
      [
        row.id,
        row.couple_id,
        row.author_user_id,
        row.type,
        row.title || null,
        row.content,
        row.mood_tag || null,
        row.color_style || null,
        row.layout_style || null,
        row.created_at,
        row.updated_at,
      ],
    );
  }
  return rows.length;
}

async function migrateExcerptNotes(client) {
  const rows = readRows('excerpt_notes');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO excerpt_notes (
        id, couple_id, author_user_id, category, quote_text, source_title,
        source_author, source_detail, personal_note, card_style, color_style,
        created_at, updated_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        author_user_id = EXCLUDED.author_user_id,
        category = EXCLUDED.category,
        quote_text = EXCLUDED.quote_text,
        source_title = EXCLUDED.source_title,
        source_author = EXCLUDED.source_author,
        source_detail = EXCLUDED.source_detail,
        personal_note = EXCLUDED.personal_note,
        card_style = EXCLUDED.card_style,
        color_style = EXCLUDED.color_style,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at
      `,
      [
        row.id,
        row.couple_id,
        row.author_user_id,
        row.category,
        row.quote_text,
        row.source_title || null,
        row.source_author || null,
        row.source_detail || null,
        row.personal_note || null,
        row.card_style || null,
        row.color_style || null,
        row.created_at,
        row.updated_at,
      ],
    );
  }
  return rows.length;
}

async function migrateThoughtComments(client) {
  const rows = readRows('thought_comments');
  for (const row of rows) {
    await client.query(
      `
      INSERT INTO thought_comments (
        id, couple_id, target_type, target_id, author_user_id, content, created_at, updated_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        target_type = EXCLUDED.target_type,
        target_id = EXCLUDED.target_id,
        author_user_id = EXCLUDED.author_user_id,
        content = EXCLUDED.content,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at
      `,
      [
        row.id,
        row.couple_id,
        row.target_type,
        row.target_id,
        row.author_user_id,
        row.content,
        row.created_at,
        row.updated_at,
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
    const ideaCount = await migrateIdeaNotes(client);
    const excerptCount = await migrateExcerptNotes(client);
    const thoughtCommentCount = await migrateThoughtComments(client);
    await client.query('COMMIT');
    console.log(
      `Migration completed. bill_records=${billCount}, playlist_songs=${songCount}, playlist_reviews=${reviewCount}, idea_notes=${ideaCount}, excerpt_notes=${excerptCount}, thought_comments=${thoughtCommentCount}`,
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

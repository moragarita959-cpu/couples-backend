const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) throw new AppError('invalid_request', `${field} is required`);
  return trimmed;
}

async function ensureCouple(client, coupleId) {
  const res = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (res.rowCount === 0) throw new AppError('couple_not_found', 'Couple not found', 404);
  return res.rows[0];
}

function ensureMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function getPartnerUserId(couple, currentUserId) {
  return currentUserId === couple.user1_id ? couple.user2_id : couple.user1_id;
}

function mapCourse(row, currentUserId) {
  return {
    id: row.id,
    title: row.title,
    weekday: row.weekday,
    startMinute: row.start_minute,
    endMinute: row.end_minute,
    startWeek: row.start_week,
    endWeek: row.end_week,
    repeatWeekly: row.repeat_weekly === true,
    startPeriod: row.start_period,
    endPeriod: row.end_period,
    location: row.location,
    teacher: row.teacher,
    note: row.note,
    owner: row.owner_user_id === currentUserId ? 'me' : 'partner',
    colorHex: row.color_hex,
    createdAt: row.created_at,
  };
}

async function listScheduleCoursesPg(pool, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const rows = await client.query(
      `
      SELECT id, title, weekday, start_minute, end_minute, start_week, end_week,
             repeat_weekly, start_period, end_period, location, teacher, note,
             owner_user_id, color_hex, created_at
      FROM schedule_courses
      WHERE couple_id = $1
      ORDER BY weekday ASC, start_minute ASC, id ASC
      `,
      [trimmedCoupleId],
    );
    return rows.rows.map((row) => mapCourse(row, trimmedCurrentUserId));
  } finally {
    client.release();
  }
}

async function upsertScheduleCoursePg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = normalizeRequired(payload.id, 'id');
  const title = normalizeRequired(payload.title, 'title');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = normalizeRequired(payload.updatedAt || payload.createdAt, 'updatedAt');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const partnerUserId = getPartnerUserId(couple, currentUserId);
    const owner = String(payload.owner || 'me').trim() === 'partner' ? partnerUserId : currentUserId;

    const existing = await client.query(
      'SELECT updated_at FROM schedule_courses WHERE id = $1 AND couple_id = $2',
      [id, coupleId],
    );
    if (existing.rowCount > 0 && Date.parse(existing.rows[0].updated_at) > Date.parse(updatedAt)) {
      const latest = await client.query(
        `
        SELECT id, title, weekday, start_minute, end_minute, start_week, end_week,
               repeat_weekly, start_period, end_period, location, teacher, note,
               owner_user_id, color_hex, created_at
        FROM schedule_courses
        WHERE id = $1 AND couple_id = $2
        `,
        [id, coupleId],
      );
      await client.query('COMMIT');
      return mapCourse(latest.rows[0], currentUserId);
    }

    await client.query(
      `
      INSERT INTO schedule_courses (
        id, couple_id, title, weekday, start_minute, end_minute, start_week, end_week,
        repeat_weekly, start_period, end_period, location, teacher, note,
        owner_user_id, color_hex, created_at, updated_at
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
      ON CONFLICT (id) DO UPDATE SET
        couple_id = EXCLUDED.couple_id,
        title = EXCLUDED.title,
        weekday = EXCLUDED.weekday,
        start_minute = EXCLUDED.start_minute,
        end_minute = EXCLUDED.end_minute,
        start_week = EXCLUDED.start_week,
        end_week = EXCLUDED.end_week,
        repeat_weekly = EXCLUDED.repeat_weekly,
        start_period = EXCLUDED.start_period,
        end_period = EXCLUDED.end_period,
        location = EXCLUDED.location,
        teacher = EXCLUDED.teacher,
        note = EXCLUDED.note,
        owner_user_id = EXCLUDED.owner_user_id,
        color_hex = EXCLUDED.color_hex,
        created_at = EXCLUDED.created_at,
        updated_at = EXCLUDED.updated_at
      `,
      [
        id,
        coupleId,
        title,
        Number(payload.weekday),
        Number(payload.startMinute),
        Number(payload.endMinute),
        Number(payload.startWeek),
        Number(payload.endWeek),
        payload.repeatWeekly === false,
        Number(payload.startPeriod),
        Number(payload.endPeriod),
        String(payload.location || '').trim(),
        String(payload.teacher || '').trim(),
        String(payload.note || '').trim(),
        owner,
        String(payload.colorHex || '#E88EA3'),
        createdAt,
        updatedAt,
      ],
    );
    await client.query('COMMIT');
    return mapCourse(
      {
        id,
        title,
        weekday: Number(payload.weekday),
        start_minute: Number(payload.startMinute),
        end_minute: Number(payload.endMinute),
        start_week: Number(payload.startWeek),
        end_week: Number(payload.endWeek),
        repeat_weekly: payload.repeatWeekly === false,
        start_period: Number(payload.startPeriod),
        end_period: Number(payload.endPeriod),
        location: String(payload.location || '').trim(),
        teacher: String(payload.teacher || '').trim(),
        note: String(payload.note || '').trim(),
        owner_user_id: owner,
        color_hex: String(payload.colorHex || '#E88EA3'),
        created_at: createdAt,
      },
      currentUserId,
    );
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteScheduleCoursePg(pool, { coupleId, id }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedId = normalizeRequired(id, 'id');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureCouple(client, trimmedCoupleId);
    await client.query('DELETE FROM schedule_courses WHERE id = $1 AND couple_id = $2', [
      trimmedId,
      trimmedCoupleId,
    ]);
    await client.query('COMMIT');
    return { ok: true };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  listScheduleCoursesPg,
  upsertScheduleCoursePg,
  deleteScheduleCoursePg,
};

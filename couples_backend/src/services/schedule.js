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
    repeatWeekly: row.repeat_weekly === 1,
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

function listScheduleCourses(db, { coupleId, currentUserId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const couple = ensureCouple(db, trimmedCoupleId);
  ensureMember(couple, trimmedCurrentUserId);

  const rows = db
    .prepare(
      `
        SELECT id, title, weekday, start_minute, end_minute, start_week, end_week,
               repeat_weekly, start_period, end_period, location, teacher, note,
               owner_user_id, color_hex, created_at
        FROM schedule_courses
        WHERE couple_id = ?
        ORDER BY weekday ASC, start_minute ASC, id ASC
      `,
    )
    .all(trimmedCoupleId);

  return rows.map((row) => mapCourse(row, trimmedCurrentUserId));
}

function upsertScheduleCourse(db, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const id = normalizeRequired(payload.id, 'id');
  const title = normalizeRequired(payload.title, 'title');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = normalizeRequired(payload.updatedAt || payload.createdAt, 'updatedAt');

  const transaction = db.transaction(() => {
    const couple = ensureCouple(db, coupleId);
    ensureMember(couple, currentUserId);
    const partnerUserId = getPartnerUserId(couple, currentUserId);
    const owner = String(payload.owner || 'me').trim() === 'partner'
      ? partnerUserId
      : currentUserId;

    const existing = db
      .prepare('SELECT updated_at FROM schedule_courses WHERE id = ? AND couple_id = ?')
      .get(id, coupleId);

    if (existing && Date.parse(existing.updated_at) > Date.parse(updatedAt)) {
      const latest = db
        .prepare(
          `
            SELECT id, title, weekday, start_minute, end_minute, start_week, end_week,
                   repeat_weekly, start_period, end_period, location, teacher, note,
                   owner_user_id, color_hex, created_at
            FROM schedule_courses
            WHERE id = ? AND couple_id = ?
          `,
        )
        .get(id, coupleId);
      return mapCourse(latest, currentUserId);
    }

    if (existing) {
      db.prepare(
        `
          UPDATE schedule_courses
          SET title = ?, weekday = ?, start_minute = ?, end_minute = ?, start_week = ?,
              end_week = ?, repeat_weekly = ?, start_period = ?, end_period = ?,
              location = ?, teacher = ?, note = ?, owner_user_id = ?, color_hex = ?,
              created_at = ?, updated_at = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(
        title,
        Number(payload.weekday),
        Number(payload.startMinute),
        Number(payload.endMinute),
        Number(payload.startWeek),
        Number(payload.endWeek),
        payload.repeatWeekly === false ? 0 : 1,
        Number(payload.startPeriod),
        Number(payload.endPeriod),
        String(payload.location || '').trim(),
        String(payload.teacher || '').trim(),
        String(payload.note || '').trim(),
        owner,
        String(payload.colorHex || '#E88EA3'),
        createdAt,
        updatedAt,
        id,
        coupleId,
      );
    } else {
      db.prepare(
        `
          INSERT INTO schedule_courses (
            id, couple_id, title, weekday, start_minute, end_minute, start_week, end_week,
            repeat_weekly, start_period, end_period, location, teacher, note,
            owner_user_id, color_hex, created_at, updated_at
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
      ).run(
        id,
        coupleId,
        title,
        Number(payload.weekday),
        Number(payload.startMinute),
        Number(payload.endMinute),
        Number(payload.startWeek),
        Number(payload.endWeek),
        payload.repeatWeekly === false ? 0 : 1,
        Number(payload.startPeriod),
        Number(payload.endPeriod),
        String(payload.location || '').trim(),
        String(payload.teacher || '').trim(),
        String(payload.note || '').trim(),
        owner,
        String(payload.colorHex || '#E88EA3'),
        createdAt,
        updatedAt,
      );
    }

    return mapCourse(
      {
        id,
        title,
        weekday: Number(payload.weekday),
        start_minute: Number(payload.startMinute),
        end_minute: Number(payload.endMinute),
        start_week: Number(payload.startWeek),
        end_week: Number(payload.endWeek),
        repeat_weekly: payload.repeatWeekly === false ? 0 : 1,
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
  });

  return transaction();
}

function deleteScheduleCourse(db, { coupleId, id }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedId = normalizeRequired(id, 'id');
  const transaction = db.transaction(() => {
    ensureCouple(db, trimmedCoupleId);
    db.prepare('DELETE FROM schedule_courses WHERE id = ? AND couple_id = ?').run(
      trimmedId,
      trimmedCoupleId,
    );
    return { ok: true };
  });
  return transaction();
}

module.exports = {
  listScheduleCourses,
  upsertScheduleCourse,
  deleteScheduleCourse,
};

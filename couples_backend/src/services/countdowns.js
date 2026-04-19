const { AppError } = require('../errors');

function normalizeCoupleId(coupleId) {
  const trimmed = String(coupleId || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', 'coupleId is required');
  }
  return trimmed;
}

function ensureCouple(db, coupleId) {
  const couple = db
    .prepare('SELECT id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');
  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
}

function normalizeSince(since) {
  const value = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (!value) {
    return null;
  }
  if (Number.isNaN(Date.parse(value))) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }
  return value;
}

function listCountdownEvents(db, { coupleId, since }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const sinceValue = normalizeSince(since);
  ensureCouple(db, trimmedCoupleId);

  const rows = sinceValue
    ? db
        .prepare(
          `
            SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
            FROM countdown_events
            WHERE couple_id = ? AND updated_at > ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId, sinceValue)
    : db
        .prepare(
          `
            SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
            FROM countdown_events
            WHERE couple_id = ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(trimmedCoupleId);

  return rows.map((row) => ({
    id: row.id,
    coupleId: row.couple_id,
    name: row.name,
    date: row.date,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    isDeleted: row.is_deleted === 1,
  }));
}

function normalizePayload(payload) {
  const id = String(payload.id || '').trim();
  const coupleId = normalizeCoupleId(payload.coupleId);
  const name = String(payload.name || '').trim();
  const date = String(payload.date || '').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();

  if (!id || !name) {
    throw new AppError('invalid_request', 'id and name are required');
  }
  if (!date || Number.isNaN(Date.parse(date))) {
    throw new AppError('invalid_request', 'date must be a valid ISO timestamp');
  }
  if (!createdAt || Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (!updatedAt || Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  return {
    id,
    coupleId,
    name,
    date,
    createdAt,
    updatedAt,
    isDeleted: payload.isDeleted === true,
  };
}

function upsertCountdownEvent(db, payload) {
  const event = normalizePayload(payload);

  const transaction = db.transaction(() => {
    ensureCouple(db, event.coupleId);
    const existing = db
      .prepare(
        `
          SELECT id, couple_id, name, date, created_at, updated_at, is_deleted
          FROM countdown_events
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(event.id, event.coupleId);

    if (existing && Date.parse(existing.updated_at) > Date.parse(event.updatedAt)) {
      return {
        id: existing.id,
        coupleId: existing.couple_id,
        name: existing.name,
        date: existing.date,
        createdAt: existing.created_at,
        updatedAt: existing.updated_at,
        isDeleted: existing.is_deleted === 1,
      };
    }

    if (existing) {
      db.prepare(
        `
          UPDATE countdown_events
          SET name = ?, date = ?, created_at = ?, updated_at = ?, is_deleted = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(
        event.name,
        event.date,
        event.createdAt,
        event.updatedAt,
        event.isDeleted ? 1 : 0,
        event.id,
        event.coupleId,
      );
    } else {
      db.prepare(
        `
          INSERT INTO countdown_events (
            id, couple_id, name, date, created_at, updated_at, is_deleted
          )
          VALUES (?, ?, ?, ?, ?, ?, ?)
        `,
      ).run(
        event.id,
        event.coupleId,
        event.name,
        event.date,
        event.createdAt,
        event.updatedAt,
        event.isDeleted ? 1 : 0,
      );
    }

    return {
      id: event.id,
      coupleId: event.coupleId,
      name: event.name,
      date: event.date,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      isDeleted: event.isDeleted,
    };
  });

  return transaction();
}

function deleteCountdownEvent(db, { coupleId, id, updatedAt }) {
  const trimmedCoupleId = normalizeCoupleId(coupleId);
  const trimmedId = String(id || '').trim();
  const trimmedUpdatedAt = String(updatedAt || '').trim();
  if (!trimmedId || !trimmedUpdatedAt || Number.isNaN(Date.parse(trimmedUpdatedAt))) {
    throw new AppError('invalid_request', 'id and updatedAt are required');
  }

  const transaction = db.transaction(() => {
    ensureCouple(db, trimmedCoupleId);
    db.prepare(
      `
        UPDATE countdown_events
        SET is_deleted = 1, updated_at = ?
        WHERE id = ? AND couple_id = ?
      `,
    ).run(trimmedUpdatedAt, trimmedId, trimmedCoupleId);
    return { ok: true };
  });

  return transaction();
}

module.exports = {
  listCountdownEvents,
  upsertCountdownEvent,
  deleteCountdownEvent,
};

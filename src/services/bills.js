const { AppError } = require('../errors');

function ensureCoupleExists(db, coupleId) {
  const couple = db
    .prepare('SELECT id FROM couples WHERE id = ? AND status = ?')
    .get(coupleId, 'active');

  if (!couple) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
}

function normalizeCoupleId(coupleId) {
  const trimmedCoupleId = String(coupleId || '').trim();
  if (!trimmedCoupleId) {
    throw new AppError('invalid_request', 'coupleId is required');
  }
  return trimmedCoupleId;
}

function normalizeSince(since) {
  const sinceValue = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (!sinceValue) {
    return null;
  }
  const timestamp = Date.parse(sinceValue);
  if (Number.isNaN(timestamp)) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }
  return sinceValue;
}

function normalizeBillPayload(payload) {
  const id = String(payload.id || '').trim();
  const coupleId = normalizeCoupleId(payload.coupleId);
  const type = String(payload.type || '').trim();
  const category = String(payload.category || 'other').trim() || 'other';
  const note = String(payload.note || '').trim();
  const createdAt = String(payload.createdAt || '').trim();
  const updatedAt = String(payload.updatedAt || '').trim();
  const isDeleted = payload.isDeleted === true;
  const amount = Number(payload.amount);

  if (!id) {
    throw new AppError('invalid_request', 'id is required');
  }
  if (type !== 'income' && type !== 'expense') {
    throw new AppError('invalid_request', 'type must be income or expense');
  }
  if (!Number.isFinite(amount) || amount < 0) {
    throw new AppError('invalid_request', 'amount must be a valid number');
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
    type,
    category,
    amount,
    note,
    createdAt,
    updatedAt,
    isDeleted,
  };
}

function mapBillRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    type: row.type,
    category: row.category,
    amount: row.amount,
    note: row.note,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    isDeleted: row.is_deleted === 1,
  };
}

function listBillRecords(db, { coupleId, since }) {
  const normalizedCoupleId = normalizeCoupleId(coupleId);
  const normalizedSince = normalizeSince(since);

  ensureCoupleExists(db, normalizedCoupleId);

  const rows = normalizedSince
    ? db
        .prepare(
          `
            SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
            FROM bill_records
            WHERE couple_id = ? AND updated_at > ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(normalizedCoupleId, normalizedSince)
    : db
        .prepare(
          `
            SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
            FROM bill_records
            WHERE couple_id = ?
            ORDER BY updated_at ASC, id ASC
          `,
        )
        .all(normalizedCoupleId);

  return rows.map(mapBillRow);
}

function upsertBillRecord(db, payload) {
  const bill = normalizeBillPayload(payload || {});

  const transaction = db.transaction(() => {
    ensureCoupleExists(db, bill.coupleId);

    const existing = db
      .prepare(
        `
          SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(bill.id, bill.coupleId);

    if (existing) {
      if (Date.parse(existing.updated_at) > Date.parse(bill.updatedAt)) {
        return mapBillRow(existing);
      }

      db.prepare(
        `
          UPDATE bill_records
          SET type = ?, category = ?, amount = ?, note = ?, created_at = ?, updated_at = ?, is_deleted = ?
          WHERE id = ? AND couple_id = ?
        `,
      ).run(
        bill.type,
        bill.category,
        bill.amount,
        bill.note,
        bill.createdAt,
        bill.updatedAt,
        bill.isDeleted ? 1 : 0,
        bill.id,
        bill.coupleId,
      );
    } else {
      db.prepare(
        `
          INSERT INTO bill_records (
            id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
      ).run(
        bill.id,
        bill.coupleId,
        bill.type,
        bill.category,
        bill.amount,
        bill.note,
        bill.createdAt,
        bill.updatedAt,
        bill.isDeleted ? 1 : 0,
      );
    }

    const latest = db
      .prepare(
        `
          SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(bill.id, bill.coupleId);

    return mapBillRow(latest);
  });

  return transaction();
}

function deleteBillRecord(db, { coupleId, id, updatedAt }) {
  const normalizedCoupleId = normalizeCoupleId(coupleId);
  const normalizedId = String(id || '').trim();
  const normalizedUpdatedAt = String(updatedAt || '').trim();

  if (!normalizedId) {
    throw new AppError('invalid_request', 'id is required');
  }
  if (!normalizedUpdatedAt || Number.isNaN(Date.parse(normalizedUpdatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }

  const transaction = db.transaction(() => {
    ensureCoupleExists(db, normalizedCoupleId);

    const existing = db
      .prepare(
        `
          SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(normalizedId, normalizedCoupleId);

    if (!existing) {
      return {
        id: normalizedId,
        coupleId: normalizedCoupleId,
        updatedAt: normalizedUpdatedAt,
        isDeleted: true,
      };
    }

    if (Date.parse(existing.updated_at) > Date.parse(normalizedUpdatedAt)) {
      return mapBillRow(existing);
    }

    db.prepare(
      `
        UPDATE bill_records
        SET is_deleted = 1, updated_at = ?
        WHERE id = ? AND couple_id = ?
      `,
    ).run(normalizedUpdatedAt, normalizedId, normalizedCoupleId);

    const latest = db
      .prepare(
        `
          SELECT id, couple_id, type, category, amount, note, created_at, updated_at, is_deleted
          FROM bill_records
          WHERE id = ? AND couple_id = ?
        `,
      )
      .get(normalizedId, normalizedCoupleId);

    return mapBillRow(latest);
  });

  return transaction();
}

module.exports = {
  listBillRecords,
  upsertBillRecord,
  deleteBillRecord,
};

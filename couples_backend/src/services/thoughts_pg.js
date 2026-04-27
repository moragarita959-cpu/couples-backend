const { AppError } = require('../errors');

function normalizeRequired(value, field) {
  const trimmed = String(value || '').trim();
  if (!trimmed) {
    throw new AppError('invalid_request', `${field} is required`);
  }
  return trimmed;
}

function normalizeOptional(value) {
  const trimmed = String(value || '').trim();
  return trimmed || null;
}

function normalizeOptionalIso(value, field) {
  const trimmed = normalizeOptional(value);
  if (trimmed == null) {
    return null;
  }
  if (Number.isNaN(Date.parse(trimmed))) {
    throw new AppError('invalid_request', `${field} must be a valid ISO timestamp`);
  }
  return trimmed;
}

async function ensureCouple(client, coupleId) {
  const result = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (result.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  return result.rows[0];
}

function ensureMember(couple, currentUserId) {
  if (currentUserId !== couple.user1_id && currentUserId !== couple.user2_id) {
    throw new AppError('user_not_in_couple', 'Current user does not belong to couple', 403);
  }
}

function mapIdeaRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    authorUserId: row.author_user_id,
    type: row.type,
    title: row.title || null,
    content: row.content,
    moodTag: row.mood_tag || null,
    colorStyle: row.color_style || null,
    layoutStyle: row.layout_style || null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    commentCount: Number(row.comment_count || 0),
  };
}

function mapExcerptRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    authorUserId: row.author_user_id,
    category: row.category,
    quoteText: row.quote_text,
    sourceTitle: row.source_title || null,
    sourceAuthor: row.source_author || null,
    sourceDetail: row.source_detail || null,
    personalNote: row.personal_note || null,
    cardStyle: row.card_style || null,
    colorStyle: row.color_style || null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    commentCount: Number(row.comment_count || 0),
  };
}

function mapCommentRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    targetType: row.target_type,
    targetId: row.target_id,
    authorUserId: row.author_user_id,
    content: row.content,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

async function assertThoughtTarget(client, targetType, targetId, coupleId) {
  if (targetType === 'idea') {
    const result = await client.query(
      'SELECT id, couple_id FROM idea_notes WHERE id = $1 AND couple_id = $2',
      [targetId, coupleId],
    );
    if (result.rowCount === 0) {
      throw new AppError('idea_not_found', 'Idea not found', 404);
    }
    return result.rows[0];
  }
  if (targetType === 'excerpt') {
    const result = await client.query(
      'SELECT id, couple_id FROM excerpt_notes WHERE id = $1 AND couple_id = $2',
      [targetId, coupleId],
    );
    if (result.rowCount === 0) {
      throw new AppError('excerpt_not_found', 'Excerpt not found', 404);
    }
    return result.rows[0];
  }
  throw new AppError('invalid_request', 'targetType must be idea or excerpt');
}

function normalizeIdeaPayload(payload, coupleId, currentUserId) {
  const id = normalizeRequired(payload.id, 'id');
  const type = normalizeRequired(payload.type, 'type');
  const content = normalizeRequired(payload.content, 'content');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = normalizeRequired(payload.updatedAt, 'updatedAt');
  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }
  return {
    id,
    coupleId,
    authorUserId: currentUserId,
    type,
    title: normalizeOptional(payload.title),
    content,
    moodTag: normalizeOptional(payload.moodTag),
    colorStyle: normalizeOptional(payload.colorStyle),
    layoutStyle: normalizeOptional(payload.layoutStyle),
    createdAt,
    updatedAt,
  };
}

function normalizeExcerptPayload(payload, coupleId, currentUserId) {
  const id = normalizeRequired(payload.id, 'id');
  const category = normalizeRequired(payload.category, 'category');
  const quoteText = normalizeRequired(payload.quoteText, 'quoteText');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = normalizeRequired(payload.updatedAt, 'updatedAt');
  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }
  return {
    id,
    coupleId,
    authorUserId: currentUserId,
    category,
    quoteText,
    sourceTitle: normalizeOptional(payload.sourceTitle),
    sourceAuthor: normalizeOptional(payload.sourceAuthor),
    sourceDetail: normalizeOptional(payload.sourceDetail),
    personalNote: normalizeOptional(payload.personalNote),
    cardStyle: normalizeOptional(payload.cardStyle),
    colorStyle: normalizeOptional(payload.colorStyle),
    createdAt,
    updatedAt,
  };
}

function normalizeCommentPayload(payload, coupleId, currentUserId) {
  const id = normalizeRequired(payload.id, 'id');
  const targetType = normalizeRequired(payload.targetType, 'targetType');
  const targetId = normalizeRequired(payload.targetId, 'targetId');
  const content = normalizeRequired(payload.content, 'content');
  const createdAt = normalizeRequired(payload.createdAt, 'createdAt');
  const updatedAt = normalizeRequired(payload.updatedAt, 'updatedAt');
  if (Number.isNaN(Date.parse(createdAt))) {
    throw new AppError('invalid_request', 'createdAt must be a valid ISO timestamp');
  }
  if (Number.isNaN(Date.parse(updatedAt))) {
    throw new AppError('invalid_request', 'updatedAt must be a valid ISO timestamp');
  }
  return {
    id,
    coupleId,
    targetType,
    targetId,
    authorUserId: currentUserId,
    content,
    createdAt,
    updatedAt,
  };
}

async function listIdeaNotesPg(pool, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const sinceValue = normalizeOptionalIso(since, 'since');
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const result = sinceValue
      ? await client.query(
          `
          SELECT i.id, i.couple_id, i.author_user_id, i.type, i.title, i.content,
                 i.mood_tag, i.color_style, i.layout_style, i.created_at, i.updated_at,
                 COUNT(c.id) AS comment_count
          FROM idea_notes i
          LEFT JOIN thought_comments c
            ON c.target_type = 'idea' AND c.target_id = i.id
          WHERE i.couple_id = $1 AND i.updated_at > $2
          GROUP BY i.id
          ORDER BY i.updated_at DESC, i.id DESC
          `,
          [trimmedCoupleId, sinceValue],
        )
      : await client.query(
          `
          SELECT i.id, i.couple_id, i.author_user_id, i.type, i.title, i.content,
                 i.mood_tag, i.color_style, i.layout_style, i.created_at, i.updated_at,
                 COUNT(c.id) AS comment_count
          FROM idea_notes i
          LEFT JOIN thought_comments c
            ON c.target_type = 'idea' AND c.target_id = i.id
          WHERE i.couple_id = $1
          GROUP BY i.id
          ORDER BY i.updated_at DESC, i.id DESC
          `,
          [trimmedCoupleId],
        );
    return result.rows.map(mapIdeaRow);
  } finally {
    client.release();
  }
}

async function upsertIdeaNotePg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const idea = normalizeIdeaPayload(payload, coupleId, currentUserId);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const existingResult = await client.query(
      `
      SELECT id, couple_id, author_user_id, updated_at
      FROM idea_notes
      WHERE id = $1 AND couple_id = $2
      `,
      [idea.id, coupleId],
    );
    if (existingResult.rowCount > 0) {
      const existing = existingResult.rows[0];
      if (existing.author_user_id !== currentUserId) {
        throw new AppError('forbidden', 'Only author can update this idea note', 403);
      }
      if (Date.parse(existing.updated_at) > Date.parse(idea.updatedAt)) {
        const latest = await client.query(
          `
          SELECT i.id, i.couple_id, i.author_user_id, i.type, i.title, i.content,
                 i.mood_tag, i.color_style, i.layout_style, i.created_at, i.updated_at,
                 COUNT(c.id) AS comment_count
          FROM idea_notes i
          LEFT JOIN thought_comments c
            ON c.target_type = 'idea' AND c.target_id = i.id
          WHERE i.id = $1 AND i.couple_id = $2
          GROUP BY i.id
          `,
          [idea.id, coupleId],
        );
        await client.query('COMMIT');
        return mapIdeaRow(latest.rows[0]);
      }
    }

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
        idea.id,
        idea.coupleId,
        idea.authorUserId,
        idea.type,
        idea.title,
        idea.content,
        idea.moodTag,
        idea.colorStyle,
        idea.layoutStyle,
        idea.createdAt,
        idea.updatedAt,
      ],
    );

    const latest = await client.query(
      `
      SELECT i.id, i.couple_id, i.author_user_id, i.type, i.title, i.content,
             i.mood_tag, i.color_style, i.layout_style, i.created_at, i.updated_at,
             COUNT(c.id) AS comment_count
      FROM idea_notes i
      LEFT JOIN thought_comments c
        ON c.target_type = 'idea' AND c.target_id = i.id
      WHERE i.id = $1 AND i.couple_id = $2
      GROUP BY i.id
      `,
      [idea.id, coupleId],
    );
    await client.query('COMMIT');
    return mapIdeaRow(latest.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteIdeaNotePg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const ideaId = normalizeRequired(payload.ideaId || payload.id, 'ideaId');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const existing = await client.query(
      'SELECT author_user_id FROM idea_notes WHERE id = $1 AND couple_id = $2',
      [ideaId, coupleId],
    );
    if (existing.rowCount === 0) {
      throw new AppError('idea_not_found', 'Idea not found', 404);
    }
    if (existing.rows[0].author_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only author can delete this idea note', 403);
    }
    await client.query(
      'DELETE FROM thought_comments WHERE target_type = $1 AND target_id = $2 AND couple_id = $3',
      ['idea', ideaId, coupleId],
    );
    await client.query('DELETE FROM idea_notes WHERE id = $1 AND couple_id = $2', [
      ideaId,
      coupleId,
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

async function listExcerptNotesPg(pool, { coupleId, currentUserId, since }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const sinceValue = normalizeOptionalIso(since, 'since');
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    const result = sinceValue
      ? await client.query(
          `
          SELECT e.id, e.couple_id, e.author_user_id, e.category, e.quote_text,
                 e.source_title, e.source_author, e.source_detail, e.personal_note,
                 e.card_style, e.color_style, e.created_at, e.updated_at,
                 COUNT(c.id) AS comment_count
          FROM excerpt_notes e
          LEFT JOIN thought_comments c
            ON c.target_type = 'excerpt' AND c.target_id = e.id
          WHERE e.couple_id = $1 AND e.updated_at > $2
          GROUP BY e.id
          ORDER BY e.updated_at DESC, e.id DESC
          `,
          [trimmedCoupleId, sinceValue],
        )
      : await client.query(
          `
          SELECT e.id, e.couple_id, e.author_user_id, e.category, e.quote_text,
                 e.source_title, e.source_author, e.source_detail, e.personal_note,
                 e.card_style, e.color_style, e.created_at, e.updated_at,
                 COUNT(c.id) AS comment_count
          FROM excerpt_notes e
          LEFT JOIN thought_comments c
            ON c.target_type = 'excerpt' AND c.target_id = e.id
          WHERE e.couple_id = $1
          GROUP BY e.id
          ORDER BY e.updated_at DESC, e.id DESC
          `,
          [trimmedCoupleId],
        );
    return result.rows.map(mapExcerptRow);
  } finally {
    client.release();
  }
}

async function upsertExcerptNotePg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const excerpt = normalizeExcerptPayload(payload, coupleId, currentUserId);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const existingResult = await client.query(
      `
      SELECT id, couple_id, author_user_id, updated_at
      FROM excerpt_notes
      WHERE id = $1 AND couple_id = $2
      `,
      [excerpt.id, coupleId],
    );
    if (existingResult.rowCount > 0) {
      const existing = existingResult.rows[0];
      if (existing.author_user_id !== currentUserId) {
        throw new AppError('forbidden', 'Only author can update this excerpt note', 403);
      }
      if (Date.parse(existing.updated_at) > Date.parse(excerpt.updatedAt)) {
        const latest = await client.query(
          `
          SELECT e.id, e.couple_id, e.author_user_id, e.category, e.quote_text,
                 e.source_title, e.source_author, e.source_detail, e.personal_note,
                 e.card_style, e.color_style, e.created_at, e.updated_at,
                 COUNT(c.id) AS comment_count
          FROM excerpt_notes e
          LEFT JOIN thought_comments c
            ON c.target_type = 'excerpt' AND c.target_id = e.id
          WHERE e.id = $1 AND e.couple_id = $2
          GROUP BY e.id
          `,
          [excerpt.id, coupleId],
        );
        await client.query('COMMIT');
        return mapExcerptRow(latest.rows[0]);
      }
    }

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
        excerpt.id,
        excerpt.coupleId,
        excerpt.authorUserId,
        excerpt.category,
        excerpt.quoteText,
        excerpt.sourceTitle,
        excerpt.sourceAuthor,
        excerpt.sourceDetail,
        excerpt.personalNote,
        excerpt.cardStyle,
        excerpt.colorStyle,
        excerpt.createdAt,
        excerpt.updatedAt,
      ],
    );

    const latest = await client.query(
      `
      SELECT e.id, e.couple_id, e.author_user_id, e.category, e.quote_text,
             e.source_title, e.source_author, e.source_detail, e.personal_note,
             e.card_style, e.color_style, e.created_at, e.updated_at,
             COUNT(c.id) AS comment_count
      FROM excerpt_notes e
      LEFT JOIN thought_comments c
        ON c.target_type = 'excerpt' AND c.target_id = e.id
      WHERE e.id = $1 AND e.couple_id = $2
      GROUP BY e.id
      `,
      [excerpt.id, coupleId],
    );
    await client.query('COMMIT');
    return mapExcerptRow(latest.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteExcerptNotePg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const excerptId = normalizeRequired(payload.excerptId || payload.id, 'excerptId');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const existing = await client.query(
      'SELECT author_user_id FROM excerpt_notes WHERE id = $1 AND couple_id = $2',
      [excerptId, coupleId],
    );
    if (existing.rowCount === 0) {
      throw new AppError('excerpt_not_found', 'Excerpt not found', 404);
    }
    if (existing.rows[0].author_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only author can delete this excerpt note', 403);
    }
    await client.query(
      'DELETE FROM thought_comments WHERE target_type = $1 AND target_id = $2 AND couple_id = $3',
      ['excerpt', excerptId, coupleId],
    );
    await client.query('DELETE FROM excerpt_notes WHERE id = $1 AND couple_id = $2', [
      excerptId,
      coupleId,
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

async function listThoughtCommentsPg(pool, { coupleId, currentUserId, targetType, targetId }) {
  const trimmedCoupleId = normalizeRequired(coupleId, 'coupleId');
  const trimmedCurrentUserId = normalizeRequired(currentUserId, 'currentUserId');
  const trimmedTargetType = normalizeRequired(targetType, 'targetType');
  const trimmedTargetId = normalizeRequired(targetId, 'targetId');
  const client = await pool.connect();
  try {
    const couple = await ensureCouple(client, trimmedCoupleId);
    ensureMember(couple, trimmedCurrentUserId);
    await assertThoughtTarget(client, trimmedTargetType, trimmedTargetId, trimmedCoupleId);
    const result = await client.query(
      `
      SELECT id, couple_id, target_type, target_id, author_user_id, content, created_at, updated_at
      FROM thought_comments
      WHERE couple_id = $1 AND target_type = $2 AND target_id = $3
      ORDER BY created_at ASC, id ASC
      `,
      [trimmedCoupleId, trimmedTargetType, trimmedTargetId],
    );
    return result.rows.map(mapCommentRow);
  } finally {
    client.release();
  }
}

async function upsertThoughtCommentPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const comment = normalizeCommentPayload(payload, coupleId, currentUserId);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    await assertThoughtTarget(client, comment.targetType, comment.targetId, coupleId);
    const existing = await client.query(
      `
      SELECT author_user_id, updated_at
      FROM thought_comments
      WHERE id = $1 AND couple_id = $2
      `,
      [comment.id, coupleId],
    );
    if (existing.rowCount > 0) {
      if (existing.rows[0].author_user_id !== currentUserId) {
        throw new AppError('forbidden', 'Only author can update this comment', 403);
      }
      if (Date.parse(existing.rows[0].updated_at) > Date.parse(comment.updatedAt)) {
        const latest = await client.query(
          `
          SELECT id, couple_id, target_type, target_id, author_user_id, content, created_at, updated_at
          FROM thought_comments
          WHERE id = $1 AND couple_id = $2
          `,
          [comment.id, coupleId],
        );
        await client.query('COMMIT');
        return mapCommentRow(latest.rows[0]);
      }
    }

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
        comment.id,
        comment.coupleId,
        comment.targetType,
        comment.targetId,
        comment.authorUserId,
        comment.content,
        comment.createdAt,
        comment.updatedAt,
      ],
    );
    const latest = await client.query(
      `
      SELECT id, couple_id, target_type, target_id, author_user_id, content, created_at, updated_at
      FROM thought_comments
      WHERE id = $1 AND couple_id = $2
      `,
      [comment.id, coupleId],
    );
    await client.query('COMMIT');
    return mapCommentRow(latest.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function deleteThoughtCommentPg(pool, payload) {
  const coupleId = normalizeRequired(payload.coupleId, 'coupleId');
  const currentUserId = normalizeRequired(payload.currentUserId, 'currentUserId');
  const commentId = normalizeRequired(payload.commentId || payload.id, 'commentId');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const couple = await ensureCouple(client, coupleId);
    ensureMember(couple, currentUserId);
    const existing = await client.query(
      `
      SELECT id, author_user_id
      FROM thought_comments
      WHERE id = $1 AND couple_id = $2
      `,
      [commentId, coupleId],
    );
    if (existing.rowCount === 0) {
      throw new AppError('comment_not_found', 'Comment not found', 404);
    }
    if (existing.rows[0].author_user_id !== currentUserId) {
      throw new AppError('forbidden', 'Only author can delete this comment', 403);
    }
    await client.query('DELETE FROM thought_comments WHERE id = $1 AND couple_id = $2', [
      commentId,
      coupleId,
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
  listIdeaNotesPg,
  upsertIdeaNotePg,
  deleteIdeaNotePg,
  listExcerptNotesPg,
  upsertExcerptNotePg,
  deleteExcerptNotePg,
  listThoughtCommentsPg,
  upsertThoughtCommentPg,
  deleteThoughtCommentPg,
};

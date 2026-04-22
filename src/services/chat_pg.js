const fs = require('fs');
const path = require('path');

const config = require('../config');
const { AppError } = require('../errors');
const { normalizeUserPair } = require('./couples');

function validateTextContent(content, { allowEmpty = false } = {}) {
  const trimmedContent = String(content || '').trim();
  if (!allowEmpty && !trimmedContent) {
    throw new AppError('invalid_request', 'content must not be empty');
  }
  if (trimmedContent.length > config.messageMaxLength) {
    throw new AppError('content_too_long', `content exceeds max length ${config.messageMaxLength}`);
  }
  return trimmedContent;
}

async function ensureSenderInCouplePg(client, { coupleId, senderUserId }) {
  const coupleResult = await client.query(
    'SELECT id, user1_id, user2_id FROM couples WHERE id = $1 AND status = $2',
    [coupleId, 'active'],
  );
  if (coupleResult.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }
  const couple = coupleResult.rows[0];
  const [user1Id, user2Id] = normalizeUserPair(couple.user1_id, couple.user2_id);
  if (user1Id !== couple.user1_id || user2Id !== couple.user2_id) {
    throw new AppError('couple_data_invalid', 'Couple data invalid', 500);
  }
  if (senderUserId !== couple.user1_id && senderUserId !== couple.user2_id) {
    throw new AppError('sender_not_in_couple', 'Sender does not belong to couple', 403);
  }
}

function sanitizeSegment(value) {
  return String(value || '').trim().replace(/[^a-zA-Z0-9_-]/g, '_');
}

function normalizeMessageType(messageType) {
  const raw = String(messageType || 'text').trim().toLowerCase();
  if (raw === 'text' || raw === 'image' || raw === 'voice') {
    return raw;
  }
  throw new AppError('invalid_request', 'messageType must be one of text, image or voice');
}

function normalizeMediaDurationMs(mediaDurationMs) {
  if (mediaDurationMs == null || mediaDurationMs === '') {
    return 0;
  }
  const parsed = Number(mediaDurationMs);
  if (!Number.isFinite(parsed) || parsed < 0) {
    throw new AppError('invalid_request', 'mediaDurationMs must be a valid integer');
  }
  return Math.floor(parsed);
}

function normalizeFileExtension(fileName, fallbackExtension) {
  const extension = path.extname(String(fileName || '').trim()).toLowerCase();
  if (extension && extension.length <= 8) {
    return extension;
  }
  return fallbackExtension;
}

function buildPublicMediaUrl(publicBaseUrl, relativePath) {
  const base = String(publicBaseUrl || '').replace(/\/+$/, '');
  const relative = relativePath.replace(/\\/g, '/');
  return `${base}${relative.startsWith('/') ? relative : `/${relative}`}`;
}

function mapChatRow(row) {
  return {
    id: row.id,
    coupleId: row.couple_id,
    senderUserId: row.sender_user_id,
    content: row.content,
    clientMessageId: row.client_message_id,
    messageType: row.message_type || 'text',
    mediaUrl: row.media_url,
    mediaDurationMs: row.media_duration_ms || 0,
    createdAt: row.created_at,
  };
}

async function uploadChatMediaPg(pool, body, publicBaseUrl) {
  const { coupleId, senderUserId, fileName, fileBytesBase64, mediaKind } = body;
  const trimmedCoupleId = String(coupleId || '').trim();
  const trimmedSenderUserId = String(senderUserId || '').trim();
  const trimmedFileName = String(fileName || '').trim();
  const trimmedBase64 = String(fileBytesBase64 || '').trim();
  const normalizedMediaKind = mediaKind === 'voice' ? 'voice' : 'image';

  if (!trimmedCoupleId || !trimmedSenderUserId || !trimmedBase64) {
    throw new AppError('invalid_request', 'coupleId, senderUserId and fileBytesBase64 are required');
  }

  const client = await pool.connect();
  try {
    await ensureSenderInCouplePg(client, { coupleId: trimmedCoupleId, senderUserId: trimmedSenderUserId });
  } finally {
    client.release();
  }

  let fileBuffer;
  try {
    fileBuffer = Buffer.from(trimmedBase64, 'base64');
  } catch (_) {
    throw new AppError('invalid_request', 'fileBytesBase64 is invalid');
  }
  if (!fileBuffer || fileBuffer.length === 0) {
    throw new AppError('invalid_request', 'uploaded file must not be empty');
  }

  const safeCoupleDir = sanitizeSegment(trimmedCoupleId);
  const safeSenderDir = sanitizeSegment(trimmedSenderUserId);
  const extension = normalizeFileExtension(trimmedFileName, normalizedMediaKind === 'image' ? '.jpg' : '.m4a');
  const generatedName = `${normalizedMediaKind}-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}${extension}`;
  const relativeDir = path.join(safeCoupleDir, normalizedMediaKind, safeSenderDir);
  const absoluteDir = path.join(config.chatMediaDir, relativeDir);
  fs.mkdirSync(absoluteDir, { recursive: true });
  fs.writeFileSync(path.join(absoluteDir, generatedName), fileBuffer);

  const relativeUrlPath = `/media/chat/${relativeDir.replace(/\\/g, '/')}/${generatedName}`;
  const mediaUrl = buildPublicMediaUrl(publicBaseUrl, relativeUrlPath);
  return { url: mediaUrl, mediaUrl };
}

async function sendChatMessagePg(pool, body) {
  const { coupleId, senderUserId, content, clientMessageId, messageType, mediaUrl, mediaDurationMs } = body;
  const trimmedCoupleId = String(coupleId || '').trim();
  const trimmedSenderUserId = String(senderUserId || '').trim();
  const trimmedClientMessageId = String(clientMessageId || '').trim();
  const normalizedMessageType = normalizeMessageType(messageType);
  const trimmedMediaUrl = String(mediaUrl || '').trim();
  const normalizedMediaDurationMs = normalizeMediaDurationMs(mediaDurationMs);
  const trimmedContent = validateTextContent(content, { allowEmpty: normalizedMessageType !== 'text' });

  if (!trimmedCoupleId || !trimmedSenderUserId || !trimmedClientMessageId) {
    throw new AppError('invalid_request', 'coupleId, senderUserId and clientMessageId are required');
  }
  if (normalizedMessageType !== 'text' && !trimmedMediaUrl) {
    throw new AppError('invalid_request', 'mediaUrl is required for image or voice messages');
  }
  if (normalizedMessageType === 'voice' && normalizedMediaDurationMs <= 0) {
    throw new AppError('invalid_request', 'mediaDurationMs must be greater than 0 for voice messages');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await ensureSenderInCouplePg(client, { coupleId: trimmedCoupleId, senderUserId: trimmedSenderUserId });

    const existing = await client.query(
      `
      SELECT id, couple_id, sender_user_id, content, client_message_id, message_type, media_url, media_duration_ms, created_at
      FROM chat_messages
      WHERE couple_id = $1 AND client_message_id = $2
      `,
      [trimmedCoupleId, trimmedClientMessageId],
    );
    if (existing.rowCount > 0) {
      await client.query('COMMIT');
      return mapChatRow(existing.rows[0]);
    }

    const now = new Date().toISOString();
    const id = `msg-${Date.now()}-${Math.floor(Math.random() * 9000) + 1000}`;
    await client.query(
      `
      INSERT INTO chat_messages (
        id, couple_id, sender_user_id, content, client_message_id,
        message_type, media_url, media_duration_ms, created_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `,
      [
        id,
        trimmedCoupleId,
        trimmedSenderUserId,
        trimmedContent,
        trimmedClientMessageId,
        normalizedMessageType,
        trimmedMediaUrl || null,
        normalizedMediaDurationMs,
        now,
      ],
    );
    await client.query('COMMIT');
    return {
      id,
      coupleId: trimmedCoupleId,
      senderUserId: trimmedSenderUserId,
      content: trimmedContent,
      clientMessageId: trimmedClientMessageId,
      messageType: normalizedMessageType,
      mediaUrl: trimmedMediaUrl || null,
      mediaDurationMs: normalizedMediaDurationMs,
      createdAt: now,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function listChatMessagesPg(pool, { coupleId, since }) {
  const trimmedCoupleId = String(coupleId || '').trim();
  if (!trimmedCoupleId) {
    throw new AppError('invalid_request', 'coupleId is required');
  }
  const sinceValue = typeof since === 'string' && since.trim() ? since.trim() : null;
  if (sinceValue && Number.isNaN(Date.parse(sinceValue))) {
    throw new AppError('invalid_request', 'since must be a valid ISO timestamp');
  }

  const coupleResult = await pool.query('SELECT id FROM couples WHERE id = $1 AND status = $2', [
    trimmedCoupleId,
    'active',
  ]);
  if (coupleResult.rowCount === 0) {
    throw new AppError('couple_not_found', 'Couple not found', 404);
  }

  const rows = sinceValue
    ? await pool.query(
        `
        SELECT id, couple_id, sender_user_id, content, client_message_id, message_type, media_url, media_duration_ms, created_at
        FROM chat_messages
        WHERE couple_id = $1 AND created_at > $2
        ORDER BY created_at ASC, id ASC
        `,
        [trimmedCoupleId, sinceValue],
      )
    : await pool.query(
        `
        SELECT id, couple_id, sender_user_id, content, client_message_id, message_type, media_url, media_duration_ms, created_at
        FROM chat_messages
        WHERE couple_id = $1
        ORDER BY created_at ASC, id ASC
        `,
        [trimmedCoupleId],
      );
  return rows.rows.map(mapChatRow);
}

module.exports = {
  uploadChatMediaPg,
  sendChatMessagePg,
  listChatMessagesPg,
};

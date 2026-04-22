const https = require('https');
const { randomUUID } = require('crypto');

const config = require('../config');
const { AppError } = require('../errors');

function registerChatPushToken(db, { coupleId, userId, token, platform }) {
  const trimmedCoupleId = String(coupleId || '').trim();
  const trimmedUserId = String(userId || '').trim();
  const trimmedToken = String(token || '').trim();
  const normalizedPlatform = String(platform || '').trim().toLowerCase() || 'android';

  if (!trimmedCoupleId || !trimmedUserId || !trimmedToken) {
    throw new AppError('invalid_request', 'coupleId, userId and token are required');
  }

  const now = new Date().toISOString();
  const existing = db
    .prepare(
      `
        SELECT id
        FROM chat_push_tokens
        WHERE couple_id = ? AND user_id = ? AND token = ?
      `,
    )
    .get(trimmedCoupleId, trimmedUserId, trimmedToken);

  if (existing) {
    db.prepare(
      `
        UPDATE chat_push_tokens
        SET platform = ?, updated_at = ?
        WHERE id = ?
      `,
    ).run(normalizedPlatform, now, existing.id);
    return { ok: true };
  }

  db.prepare(
    `
      INSERT INTO chat_push_tokens (
        id,
        couple_id,
        user_id,
        token,
        platform,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
  ).run(randomUUID(), trimmedCoupleId, trimmedUserId, trimmedToken, normalizedPlatform, now, now);

  return { ok: true };
}

async function notifyPartnerOnChatMessage(db, message) {
  if (!config.fcmServerKey) {
    return;
  }
  const coupleId = message.coupleId;
  const senderUserId = message.senderUserId;

  const tokens = db
    .prepare(
      `
        SELECT token
        FROM chat_push_tokens
        WHERE couple_id = ? AND user_id <> ?
      `,
    )
    .all(coupleId, senderUserId)
    .map((row) => row.token)
    .filter(Boolean);

  if (tokens.length === 0) {
    return;
  }

  const title = 'TA 发来新消息';
  const body =
    message.messageType === 'text'
      ? message.content || '收到一条消息'
      : message.messageType === 'image'
      ? '[图片]'
      : '[语音]';

  for (const token of tokens) {
    try {
      await _sendFcmLegacy(token, {
        title,
        body,
        channel_id: 'chat_messages_channel',
        sound: 'chat_partner_pop',
      });
    } catch (_) {
      // 单个 token 失败不影响整体发送链路。
    }
  }
}

function _sendFcmLegacy(toToken, notification) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      to: toToken,
      priority: 'high',
      notification,
      data: {
        type: 'chat_message',
      },
    });

    const req = https.request(
      {
        method: 'POST',
        hostname: 'fcm.googleapis.com',
        path: '/fcm/send',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `key=${config.fcmServerKey}`,
          'Content-Length': Buffer.byteLength(payload),
        },
      },
      (res) => {
        const chunks = [];
        res.on('data', (d) => chunks.push(d));
        res.on('end', () => {
          if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
            resolve();
            return;
          }
          reject(new Error(`fcm_http_${res.statusCode || 500}`));
        });
      },
    );
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

module.exports = {
  registerChatPushToken,
  notifyPartnerOnChatMessage,
};

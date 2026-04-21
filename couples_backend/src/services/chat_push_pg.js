const https = require('https');
const { randomUUID } = require('crypto');

const config = require('../config');
const { AppError } = require('../errors');

async function registerChatPushTokenPg(pool, { coupleId, userId, token, platform }) {
  const trimmedCoupleId = String(coupleId || '').trim();
  const trimmedUserId = String(userId || '').trim();
  const trimmedToken = String(token || '').trim();
  const normalizedPlatform = String(platform || '').trim().toLowerCase() || 'android';
  if (!trimmedCoupleId || !trimmedUserId || !trimmedToken) {
    throw new AppError('invalid_request', 'coupleId, userId and token are required');
  }
  const now = new Date().toISOString();
  const existing = await pool.query(
    'SELECT id FROM chat_push_tokens WHERE couple_id = $1 AND user_id = $2 AND token = $3',
    [trimmedCoupleId, trimmedUserId, trimmedToken],
  );
  if (existing.rowCount > 0) {
    await pool.query('UPDATE chat_push_tokens SET platform = $1, updated_at = $2 WHERE id = $3', [
      normalizedPlatform,
      now,
      existing.rows[0].id,
    ]);
    return { ok: true };
  }
  await pool.query(
    `
    INSERT INTO chat_push_tokens (id, couple_id, user_id, token, platform, created_at, updated_at)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    `,
    [randomUUID(), trimmedCoupleId, trimmedUserId, trimmedToken, normalizedPlatform, now, now],
  );
  return { ok: true };
}

async function notifyPartnerOnChatMessagePg(pool, message) {
  if (!config.fcmServerKey) {
    return;
  }
  const rows = await pool.query(
    'SELECT token FROM chat_push_tokens WHERE couple_id = $1 AND user_id <> $2',
    [message.coupleId, message.senderUserId],
  );
  const tokens = rows.rows.map((r) => r.token).filter(Boolean);
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
      await sendFcmLegacy(token, {
        title,
        body,
        channel_id: 'chat_messages_channel',
        sound: 'chat_partner_pop',
      });
    } catch (_) {
      // ignore single-token failure
    }
  }
}

function sendFcmLegacy(toToken, notification) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      to: toToken,
      priority: 'high',
      notification,
      data: { type: 'chat_message' },
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
  registerChatPushTokenPg,
  notifyPartnerOnChatMessagePg,
};

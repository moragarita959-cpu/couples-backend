const express = require('express');

const config = require('./config');
const db = require('./database');
const { pool, initPostgresSchema } = require('./database_pg');
const { isAppError } = require('./errors');
const { bootstrapUser } = require('./services/users');
const { bindCoupleByPairCode, getPartnerUserId } = require('./services/couples');
const {
  listChatMessages,
  sendChatMessage,
  uploadChatMedia,
} = require('./services/chat');
const {
  listChatMessagesPg,
  sendChatMessagePg,
  uploadChatMediaPg,
} = require('./services/chat_pg');
const {
  registerChatPushToken,
  notifyPartnerOnChatMessage,
} = require('./services/chat_push');
const {
  registerChatPushTokenPg,
  notifyPartnerOnChatMessagePg,
} = require('./services/chat_push_pg');
const { bootstrapUserPg } = require('./services/users_pg');
const { bindCoupleByPairCodePg, getPartnerUserIdPg } = require('./services/couples_pg');
const {
  listBillRecords,
  upsertBillRecord,
  deleteBillRecord,
} = require('./services/bills');
const {
  listBillRecordsPg,
  upsertBillRecordPg,
  deleteBillRecordPg,
} = require('./services/bills_pg');
const {
  listTodoItems,
  upsertTodoItem,
  deleteTodoItem,
} = require('./services/todos');
const {
  listTodoItemsPg,
  upsertTodoItemPg,
  deleteTodoItemPg,
} = require('./services/todos_pg');
const {
  listCountdownEvents,
  upsertCountdownEvent,
  deleteCountdownEvent,
} = require('./services/countdowns');
const {
  listCountdownEventsPg,
  upsertCountdownEventPg,
  deleteCountdownEventPg,
} = require('./services/countdowns_pg');
const { listPokeEvents, sendPoke } = require('./services/poke');
const { listPokeEventsPg, sendPokePg } = require('./services/poke_pg');
const {
  listPlaylistSongs,
  upsertPlaylistSong,
  deletePlaylistSong,
  listPlaylistReviews,
  upsertPlaylistReview,
} = require('./services/playlist');
const {
  listPlaylistSongsPg,
  upsertPlaylistSongPg,
  deletePlaylistSongPg,
  listPlaylistReviewsPg,
  upsertPlaylistReviewPg,
} = require('./services/playlist_pg');
const {
  listScheduleCourses,
  upsertScheduleCourse,
  deleteScheduleCourse,
} = require('./services/schedule');
const {
  listScheduleCoursesPg,
  upsertScheduleCoursePg,
  deleteScheduleCoursePg,
} = require('./services/schedule_pg');
const { listFeedEventsPg, addFeedEventPg } = require('./services/feed_pg');
const {
  updateDistanceLocationPg,
  setDistanceVisibilityPg,
  getDistanceInfoPg,
} = require('./services/distance_pg');

const app = express();

app.set('trust proxy', true);
app.use(express.json({ limit: '20mb' }));
app.use('/media/chat', express.static(config.chatMediaDir));

function resolvePublicBaseUrl(req) {
  if (config.publicBaseUrl) {
    return config.publicBaseUrl;
  }
  const forwardedProto = req.get('x-forwarded-proto');
  const protocol = forwardedProto ? forwardedProto.split(',')[0].trim() : req.protocol;
  return `${protocol}://${req.get('host')}`;
}

app.get('/health', (_req, res) => {
  res.json({
    data: {
      ok: true,
      timestamp: new Date().toISOString(),
    },
  });
});

app.post('/bootstrap-user', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await bootstrapUserPg(pool, req.body || {})
      : bootstrapUser(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/bind-couple-by-pair-code', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await bindCoupleByPairCodePg(pool, req.body || {})
      : bindCoupleByPairCode(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/couple/partner-id', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await getPartnerUserIdPg(pool, req.body || {})
      : getPartnerUserId(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/chat/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listChatMessagesPg(pool, req.body || {})
      : listChatMessages(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/chat/send', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await sendChatMessagePg(pool, req.body || {})
      : sendChatMessage(db, req.body || {});
    const notify = config.usePostgres
      ? notifyPartnerOnChatMessagePg(pool, data)
      : notifyPartnerOnChatMessage(db, data);
    notify.catch(() => {
      // 推送失败不阻断聊天发送。
    });
    res.json({ data });
  })().catch(next);
});

app.post('/chat/upload-image', (req, res, next) => {
  (async () => {
    const payload = {
      ...(req.body || {}),
      mediaKind: 'image',
    };
    const data = config.usePostgres
      ? await uploadChatMediaPg(pool, payload, resolvePublicBaseUrl(req))
      : uploadChatMedia(db, payload, resolvePublicBaseUrl(req));
    res.json({ data });
  })().catch(next);
});

app.post('/chat/upload-voice', (req, res, next) => {
  (async () => {
    const payload = {
      ...(req.body || {}),
      mediaKind: 'voice',
    };
    const data = config.usePostgres
      ? await uploadChatMediaPg(pool, payload, resolvePublicBaseUrl(req))
      : uploadChatMedia(db, payload, resolvePublicBaseUrl(req));
    res.json({ data });
  })().catch(next);
});

app.post('/chat/push/register-token', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await registerChatPushTokenPg(pool, req.body || {})
      : registerChatPushToken(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/bill/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listBillRecordsPg(pool, req.body || {})
      : listBillRecords(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/bill/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertBillRecordPg(pool, req.body || {})
      : upsertBillRecord(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/bill/delete', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await deleteBillRecordPg(pool, req.body || {})
      : deleteBillRecord(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/todo/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listTodoItemsPg(pool, req.body || {})
      : listTodoItems(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/todo/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertTodoItemPg(pool, req.body || {})
      : upsertTodoItem(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/todo/delete', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await deleteTodoItemPg(pool, req.body || {})
      : deleteTodoItem(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/countdown/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listCountdownEventsPg(pool, req.body || {})
      : listCountdownEvents(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/countdown/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertCountdownEventPg(pool, req.body || {})
      : upsertCountdownEvent(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/countdown/delete', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await deleteCountdownEventPg(pool, req.body || {})
      : deleteCountdownEvent(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/poke/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listPokeEventsPg(pool, req.body || {})
      : listPokeEvents(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/poke/send', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await sendPokePg(pool, req.body || {})
      : sendPoke(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/playlist/songs/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listPlaylistSongsPg(pool, req.body || {})
      : listPlaylistSongs(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/playlist/songs/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertPlaylistSongPg(pool, req.body || {})
      : upsertPlaylistSong(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/playlist/songs/delete', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await deletePlaylistSongPg(pool, req.body || {})
      : deletePlaylistSong(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/playlist/reviews/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listPlaylistReviewsPg(pool, req.body || {})
      : listPlaylistReviews(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/playlist/reviews/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertPlaylistReviewPg(pool, req.body || {})
      : upsertPlaylistReview(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/schedule/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listScheduleCoursesPg(pool, req.body || {})
      : listScheduleCourses(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/schedule/upsert', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await upsertScheduleCoursePg(pool, req.body || {})
      : upsertScheduleCourse(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/schedule/delete', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await deleteScheduleCoursePg(pool, req.body || {})
      : deleteScheduleCourse(db, req.body || {});
    res.json({ data });
  })().catch(next);
});

app.post('/feed/list', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await listFeedEventsPg(pool, req.body || {})
      : [];
    res.json({ data });
  })().catch(next);
});

app.post('/feed/add', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await addFeedEventPg(pool, req.body || {})
      : null;
    res.json({ data });
  })().catch(next);
});

app.post('/distance/update-location', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await updateDistanceLocationPg(pool, req.body || {})
      : { ok: false };
    res.json({ data });
  })().catch(next);
});

app.post('/distance/get-info', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await getDistanceInfoPg(pool, req.body || {})
      : { distanceKm: null };
    res.json({ data });
  })().catch(next);
});

app.post('/distance/set-visibility', (req, res, next) => {
  (async () => {
    const data = config.usePostgres
      ? await setDistanceVisibilityPg(pool, req.body || {})
      : { ok: false };
    res.json({ data });
  })().catch(next);
});

app.use((error, _req, res, _next) => {
  if (isAppError(error)) {
    res.status(error.status).json({
      error: {
        code: error.code,
        message: error.message,
      },
    });
    return;
  }

  console.error(error);
  res.status(500).json({
    error: {
      code: 'internal_error',
      message: 'Internal server error',
    },
  });
});

async function start() {
  if (config.usePostgres) {
    await initPostgresSchema();
  }
  app.listen(config.port, () => {
    console.log(`Couples backend listening on http://0.0.0.0:${config.port}`);
    if (config.usePostgres) {
      console.log('Database mode: postgres');
    } else {
      console.log(`Database path: ${config.dbPath}`);
    }
  });
}

start().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});

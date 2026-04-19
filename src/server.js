const express = require('express');

const config = require('./config');
const db = require('./database');
const { isAppError } = require('./errors');
const { bootstrapUser } = require('./services/users');
const { bindCoupleByPairCode } = require('./services/couples');
const {
  listChatMessages,
  sendChatMessage,
  uploadChatMedia,
} = require('./services/chat');
const {
  listBillRecords,
  upsertBillRecord,
  deleteBillRecord,
} = require('./services/bills');
const {
  listTodoItems,
  upsertTodoItem,
  deleteTodoItem,
} = require('./services/todos');
const {
  listCountdownEvents,
  upsertCountdownEvent,
  deleteCountdownEvent,
} = require('./services/countdowns');
const { listPokeEvents, sendPoke } = require('./services/poke');
const {
  listPlaylistSongs,
  upsertPlaylistSong,
  listPlaylistReviews,
  upsertPlaylistReview,
} = require('./services/playlist');
const {
  listScheduleCourses,
  upsertScheduleCourse,
  deleteScheduleCourse,
} = require('./services/schedule');

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
  try {
    const data = bootstrapUser(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/bind-couple-by-pair-code', (req, res, next) => {
  try {
    const data = bindCoupleByPairCode(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/chat/list', (req, res, next) => {
  try {
    const data = listChatMessages(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/chat/send', (req, res, next) => {
  try {
    const data = sendChatMessage(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/chat/upload-image', (req, res, next) => {
  try {
    const data = uploadChatMedia(
      db,
      {
        ...(req.body || {}),
        mediaKind: 'image',
      },
      resolvePublicBaseUrl(req),
    );
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/chat/upload-voice', (req, res, next) => {
  try {
    const data = uploadChatMedia(
      db,
      {
        ...(req.body || {}),
        mediaKind: 'voice',
      },
      resolvePublicBaseUrl(req),
    );
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/bill/list', (req, res, next) => {
  try {
    const data = listBillRecords(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/bill/upsert', (req, res, next) => {
  try {
    const data = upsertBillRecord(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/bill/delete', (req, res, next) => {
  try {
    const data = deleteBillRecord(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/todo/list', (req, res, next) => {
  try {
    const data = listTodoItems(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/todo/upsert', (req, res, next) => {
  try {
    const data = upsertTodoItem(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/todo/delete', (req, res, next) => {
  try {
    const data = deleteTodoItem(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/countdown/list', (req, res, next) => {
  try {
    const data = listCountdownEvents(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/countdown/upsert', (req, res, next) => {
  try {
    const data = upsertCountdownEvent(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/countdown/delete', (req, res, next) => {
  try {
    const data = deleteCountdownEvent(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/poke/list', (req, res, next) => {
  try {
    const data = listPokeEvents(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/poke/send', (req, res, next) => {
  try {
    const data = sendPoke(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/playlist/songs/list', (req, res, next) => {
  try {
    const data = listPlaylistSongs(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/playlist/songs/upsert', (req, res, next) => {
  try {
    const data = upsertPlaylistSong(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/playlist/reviews/list', (req, res, next) => {
  try {
    const data = listPlaylistReviews(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/playlist/reviews/upsert', (req, res, next) => {
  try {
    const data = upsertPlaylistReview(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/schedule/list', (req, res, next) => {
  try {
    const data = listScheduleCourses(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/schedule/upsert', (req, res, next) => {
  try {
    const data = upsertScheduleCourse(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
});

app.post('/schedule/delete', (req, res, next) => {
  try {
    const data = deleteScheduleCourse(db, req.body || {});
    res.json({ data });
  } catch (error) {
    next(error);
  }
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

app.listen(config.port, () => {
  console.log(`Couples backend listening on http://0.0.0.0:${config.port}`);
  console.log(`Database path: ${config.dbPath}`);
});

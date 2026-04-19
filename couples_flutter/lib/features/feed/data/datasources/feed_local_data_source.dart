import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/feed_event.dart';
import '../models/feed_event_model.dart';

class FeedLocalDataSource {
  FeedLocalDataSource(this._db);

  final AppDatabase _db;
  bool _seedChecked = false;

  Stream<List<FeedEventModel>> watchEvents({int? limit}) async* {
    await _ensureSeeded();
    final query = _db.select(_db.feedEventsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    yield* query.watch().map((rows) => rows.map(_rowToModel).toList());
  }

  Future<void> addEvent({
    required FeedEventType eventType,
    required FeedActorSide actorSide,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.feedEventsTable).insert(
          FeedEventsTableCompanion.insert(
            id: 'feed-${now.microsecondsSinceEpoch}',
            eventType: _eventTypeToDbValue(eventType),
            actorSide: _actorSideToDbValue(actorSide),
            targetType: _targetTypeToDbValue(targetType),
            targetId: targetId,
            summaryText: summaryText.trim(),
            createdAt: now,
          ),
        );
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) {
      return;
    }
    _seedChecked = true;

    final countExpr = _db.feedEventsTable.id.count();
    final countQuery = _db.selectOnly(_db.feedEventsTable)..addColumns([countExpr]);
    final total = await countQuery.map((row) => row.read(countExpr) ?? 0).getSingle();
    if (total > 0) {
      return;
    }

    final now = DateTime.now();
    final seed = <FeedEventsTableCompanion>[
      FeedEventsTableCompanion.insert(
        id: 'feed-seed-1',
        eventType: _eventTypeToDbValue(FeedEventType.songReviewAdded),
        actorSide: _actorSideToDbValue(FeedActorSide.partner),
        targetType: _targetTypeToDbValue(FeedTargetType.song),
        targetId: 'song-seed',
        summaryText: 'TA 给《晴天》写了新的评分',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      FeedEventsTableCompanion.insert(
        id: 'feed-seed-2',
        eventType: _eventTypeToDbValue(FeedEventType.todoCompleted),
        actorSide: _actorSideToDbValue(FeedActorSide.me),
        targetType: _targetTypeToDbValue(FeedTargetType.todo),
        targetId: 'todo-seed',
        summaryText: '你完成了待办：晚安电话',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    await _db.batch((batch) {
      batch.insertAll(_db.feedEventsTable, seed);
    });
  }

  FeedEventModel _rowToModel(FeedEventsTableData row) {
    return FeedEventModel(
      id: row.id,
      eventType: _eventTypeFromDbValue(row.eventType),
      actorSide: _actorSideFromDbValue(row.actorSide),
      targetType: _targetTypeFromDbValue(row.targetType),
      targetId: row.targetId,
      summaryText: row.summaryText,
      createdAt: row.createdAt,
      isRead: row.isRead,
    );
  }

  String _eventTypeToDbValue(FeedEventType eventType) {
    switch (eventType) {
      case FeedEventType.todoCreated:
        return 'todo_created';
      case FeedEventType.todoCompleted:
        return 'todo_completed';
      case FeedEventType.todoDeleted:
        return 'todo_deleted';
      case FeedEventType.billCreated:
        return 'bill_created';
      case FeedEventType.billUpdated:
        return 'bill_updated';
      case FeedEventType.billDeleted:
        return 'bill_deleted';
      case FeedEventType.countdownCreated:
        return 'countdown_created';
      case FeedEventType.countdownUpdated:
        return 'countdown_updated';
      case FeedEventType.countdownDeleted:
        return 'countdown_deleted';
      case FeedEventType.songAdded:
        return 'song_added';
      case FeedEventType.songReviewAdded:
        return 'song_review_added';
      case FeedEventType.songReviewUpdated:
        return 'song_review_updated';
      case FeedEventType.courseCreated:
        return 'course_created';
      case FeedEventType.courseUpdated:
        return 'course_updated';
      case FeedEventType.courseDeleted:
        return 'course_deleted';
    }
  }

  FeedEventType _eventTypeFromDbValue(String raw) {
    switch (raw) {
      case 'todo_created':
        return FeedEventType.todoCreated;
      case 'todo_completed':
        return FeedEventType.todoCompleted;
      case 'todo_deleted':
        return FeedEventType.todoDeleted;
      case 'bill_created':
        return FeedEventType.billCreated;
      case 'bill_updated':
        return FeedEventType.billUpdated;
      case 'bill_deleted':
        return FeedEventType.billDeleted;
      case 'countdown_created':
        return FeedEventType.countdownCreated;
      case 'countdown_updated':
        return FeedEventType.countdownUpdated;
      case 'countdown_deleted':
        return FeedEventType.countdownDeleted;
      case 'song_added':
        return FeedEventType.songAdded;
      case 'song_review_added':
        return FeedEventType.songReviewAdded;
      case 'song_review_updated':
        return FeedEventType.songReviewUpdated;
      case 'course_created':
        return FeedEventType.courseCreated;
      case 'course_updated':
        return FeedEventType.courseUpdated;
      case 'course_deleted':
        return FeedEventType.courseDeleted;
      default:
        return FeedEventType.todoCreated;
    }
  }

  String _actorSideToDbValue(FeedActorSide side) {
    return side == FeedActorSide.partner ? 'partner' : 'me';
  }

  FeedActorSide _actorSideFromDbValue(String raw) {
    return raw == 'partner' ? FeedActorSide.partner : FeedActorSide.me;
  }

  String _targetTypeToDbValue(FeedTargetType targetType) {
    switch (targetType) {
      case FeedTargetType.todo:
        return 'todo';
      case FeedTargetType.bill:
        return 'bill';
      case FeedTargetType.countdown:
        return 'countdown';
      case FeedTargetType.song:
        return 'song';
      case FeedTargetType.course:
        return 'course';
    }
  }

  FeedTargetType _targetTypeFromDbValue(String raw) {
    switch (raw) {
      case 'bill':
        return FeedTargetType.bill;
      case 'countdown':
        return FeedTargetType.countdown;
      case 'song':
        return FeedTargetType.song;
      case 'course':
        return FeedTargetType.course;
      default:
        return FeedTargetType.todo;
    }
  }
}

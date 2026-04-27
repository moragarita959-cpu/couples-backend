import '../../../../core/network/api_client.dart';
import '../models/feed_event_model.dart';
import '../../domain/entities/feed_event.dart';

class FeedCloudDataSource {
  const FeedCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<FeedEventModel>> listEvents({
    required String coupleId,
    required String currentUserId,
    int limit = 100,
  }) async {
    final payload = await _apiClient.listFeedEvents(
      coupleId: coupleId,
      currentUserId: currentUserId,
      limit: limit,
    );
    return payload
        .map(
          (item) => FeedEventModel(
            id: item['id'] as String,
            eventType: _eventTypeFromDbValue((item['eventType'] as String?) ?? 'todo_created'),
            actorSide: (item['actorUserId'] as String?) == currentUserId
                ? FeedActorSide.me
                : FeedActorSide.partner,
            targetType: _targetTypeFromDbValue((item['targetType'] as String?) ?? 'todo'),
            targetId: (item['targetId'] as String?) ?? '',
            summaryText: (item['summaryText'] as String?) ?? '',
            createdAt: DateTime.tryParse((item['createdAt'] as String?) ?? '') ?? DateTime.now(),
            isRead: item['isRead'] == true,
          ),
        )
        .toList();
  }

  Future<void> addEvent({
    required String coupleId,
    required String currentUserId,
    required FeedEventType eventType,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  }) async {
    await _apiClient.addFeedEvent(
      coupleId: coupleId,
      currentUserId: currentUserId,
      eventType: _eventTypeToDbValue(eventType),
      targetType: _targetTypeToDbValue(targetType),
      targetId: targetId,
      summaryText: summaryText,
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

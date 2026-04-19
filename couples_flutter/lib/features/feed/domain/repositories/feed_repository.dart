import '../entities/feed_event.dart';

abstract class FeedRepository {
  Stream<List<FeedEvent>> watchEvents({int? limit});

  Future<void> addEvent({
    required FeedEventType eventType,
    required FeedActorSide actorSide,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  });
}

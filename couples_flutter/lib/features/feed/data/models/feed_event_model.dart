import '../../domain/entities/feed_event.dart';

class FeedEventModel extends FeedEvent {
  const FeedEventModel({
    required super.id,
    required super.eventType,
    required super.actorSide,
    required super.targetType,
    required super.targetId,
    required super.summaryText,
    required super.createdAt,
    required super.isRead,
  });
}

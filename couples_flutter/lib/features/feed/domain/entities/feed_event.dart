enum FeedEventType {
  todoCreated,
  todoCompleted,
  todoDeleted,
  billCreated,
  billUpdated,
  billDeleted,
  countdownCreated,
  countdownUpdated,
  countdownDeleted,
  songAdded,
  songReviewAdded,
  songReviewUpdated,
  courseCreated,
  courseUpdated,
  courseDeleted,
}

enum FeedActorSide { me, partner }

enum FeedTargetType { todo, bill, countdown, song, course }

class FeedEvent {
  const FeedEvent({
    required this.id,
    required this.eventType,
    required this.actorSide,
    required this.targetType,
    required this.targetId,
    required this.summaryText,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final FeedEventType eventType;
  final FeedActorSide actorSide;
  final FeedTargetType targetType;
  final String targetId;
  final String summaryText;
  final DateTime createdAt;
  final bool isRead;
}

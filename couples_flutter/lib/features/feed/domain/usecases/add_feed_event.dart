import '../entities/feed_event.dart';
import '../repositories/feed_repository.dart';

class AddFeedEvent {
  const AddFeedEvent(this._repository);

  final FeedRepository _repository;

  Future<void> call({
    required FeedEventType eventType,
    required FeedActorSide actorSide,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  }) {
    return _repository.addEvent(
      eventType: eventType,
      actorSide: actorSide,
      targetType: targetType,
      targetId: targetId,
      summaryText: summaryText,
    );
  }
}

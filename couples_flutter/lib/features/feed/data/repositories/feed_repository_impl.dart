import '../../domain/entities/feed_event.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl(this._dataSource);

  final FeedLocalDataSource _dataSource;

  @override
  Stream<List<FeedEvent>> watchEvents({int? limit}) {
    return _dataSource.watchEvents(limit: limit);
  }

  @override
  Future<void> addEvent({
    required FeedEventType eventType,
    required FeedActorSide actorSide,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  }) {
    return _dataSource.addEvent(
      eventType: eventType,
      actorSide: actorSide,
      targetType: targetType,
      targetId: targetId,
      summaryText: summaryText,
    );
  }
}

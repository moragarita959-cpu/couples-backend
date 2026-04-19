import '../entities/feed_event.dart';
import '../repositories/feed_repository.dart';

class WatchFeedEvents {
  const WatchFeedEvents(this._repository);

  final FeedRepository _repository;

  Stream<List<FeedEvent>> call({int? limit}) {
    return _repository.watchEvents(limit: limit);
  }
}

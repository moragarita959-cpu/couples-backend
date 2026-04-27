import '../entities/thought_comment.dart';
import '../repositories/thoughts_repository.dart';

class WatchThoughtComments {
  const WatchThoughtComments(this._repository);

  final ThoughtsRepository _repository;

  Stream<List<ThoughtComment>> call(String targetType, String targetId) {
    return _repository.watchThoughtComments(targetType, targetId);
  }
}

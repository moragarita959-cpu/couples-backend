import '../entities/thought_comment.dart';
import '../repositories/thoughts_repository.dart';

class RefreshThoughtComments {
  const RefreshThoughtComments(this._repository);

  final ThoughtsRepository _repository;

  Future<List<ThoughtComment>> call(String targetType, String targetId) {
    return _repository.refreshThoughtComments(targetType, targetId);
  }
}

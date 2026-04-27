import '../entities/thought_comment.dart';
import '../repositories/thoughts_repository.dart';

class AddThoughtComment {
  const AddThoughtComment(this._repository);

  final ThoughtsRepository _repository;

  Future<ThoughtComment> call(ThoughtComment comment) {
    return _repository.saveThoughtComment(comment);
  }
}

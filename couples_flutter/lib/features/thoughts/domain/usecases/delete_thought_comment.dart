import '../repositories/thoughts_repository.dart';

class DeleteThoughtComment {
  const DeleteThoughtComment(this._repository);

  final ThoughtsRepository _repository;

  Future<void> call(String commentId) => _repository.deleteThoughtComment(commentId);
}

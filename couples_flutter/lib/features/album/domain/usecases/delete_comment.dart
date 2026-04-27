import '../repositories/album_repository.dart';

class DeleteComment {
  const DeleteComment(this._repository);

  final AlbumRepository _repository;

  Future<void> call(String commentId) => _repository.deleteComment(commentId);
}

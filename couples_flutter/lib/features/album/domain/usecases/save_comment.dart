import '../entities/photo_comment.dart';
import '../repositories/album_repository.dart';

class SaveComment {
  const SaveComment(this._repository);

  final AlbumRepository _repository;

  Future<PhotoComment> call(PhotoComment comment) => _repository.saveComment(comment);
}

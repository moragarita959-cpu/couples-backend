import '../entities/photo_comment.dart';
import '../repositories/album_repository.dart';

class RefreshComments {
  const RefreshComments(this._repository);

  final AlbumRepository _repository;

  Future<List<PhotoComment>> call(String photoId) => _repository.refreshComments(photoId);
}

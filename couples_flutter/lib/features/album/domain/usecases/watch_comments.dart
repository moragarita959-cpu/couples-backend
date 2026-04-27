import '../entities/photo_comment.dart';
import '../repositories/album_repository.dart';

class WatchComments {
  const WatchComments(this._repository);

  final AlbumRepository _repository;

  Stream<List<PhotoComment>> call(String photoId) => _repository.watchComments(photoId);
}

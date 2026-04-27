import '../entities/album_photo.dart';
import '../repositories/album_repository.dart';

class WatchPhotos {
  const WatchPhotos(this._repository);

  final AlbumRepository _repository;

  Stream<List<AlbumPhoto>> call(String albumId) => _repository.watchPhotos(albumId);
}

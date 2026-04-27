import '../entities/album_photo.dart';
import '../repositories/album_repository.dart';

class RefreshPhotos {
  const RefreshPhotos(this._repository);

  final AlbumRepository _repository;

  Future<List<AlbumPhoto>> call(String albumId) => _repository.refreshPhotos(albumId);
}

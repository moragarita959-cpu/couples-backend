import '../entities/album_photo.dart';
import '../repositories/album_repository.dart';

class WatchPhoto {
  const WatchPhoto(this._repository);

  final AlbumRepository _repository;

  Stream<AlbumPhoto?> call(String photoId) => _repository.watchPhoto(photoId);
}

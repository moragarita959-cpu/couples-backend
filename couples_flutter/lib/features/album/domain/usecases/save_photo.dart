import '../entities/album_photo.dart';
import '../repositories/album_repository.dart';

class SavePhoto {
  const SavePhoto(this._repository);

  final AlbumRepository _repository;

  Future<AlbumPhoto> call(AlbumPhoto photo) => _repository.savePhoto(photo);
}

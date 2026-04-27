import '../repositories/album_repository.dart';

class DeletePhoto {
  const DeletePhoto(this._repository);

  final AlbumRepository _repository;

  Future<void> call(String photoId) => _repository.deletePhoto(photoId);
}

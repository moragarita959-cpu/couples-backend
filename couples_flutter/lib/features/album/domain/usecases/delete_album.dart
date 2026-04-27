import '../repositories/album_repository.dart';

class DeleteAlbum {
  const DeleteAlbum(this._repository);

  final AlbumRepository _repository;

  Future<void> call(String albumId) => _repository.deleteAlbum(albumId);
}

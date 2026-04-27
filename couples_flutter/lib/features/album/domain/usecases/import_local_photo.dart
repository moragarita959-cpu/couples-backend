import '../repositories/album_repository.dart';

class ImportLocalPhoto {
  const ImportLocalPhoto(this._repository);

  final AlbumRepository _repository;

  Future<String> call({
    required String albumId,
    required String sourcePath,
  }) {
    return _repository.importPhotoToLocalStorage(
      albumId: albumId,
      sourcePath: sourcePath,
    );
  }
}

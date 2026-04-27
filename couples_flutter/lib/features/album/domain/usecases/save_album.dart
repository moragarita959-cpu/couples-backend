import '../entities/album.dart';
import '../repositories/album_repository.dart';

class SaveAlbum {
  const SaveAlbum(this._repository);

  final AlbumRepository _repository;

  Future<Album> call(Album album) => _repository.saveAlbum(album);
}

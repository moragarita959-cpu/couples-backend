import '../entities/album.dart';
import '../repositories/album_repository.dart';

class RefreshAlbums {
  const RefreshAlbums(this._repository);

  final AlbumRepository _repository;

  Future<List<Album>> call() => _repository.refreshAlbums();
}

import '../entities/album.dart';
import '../repositories/album_repository.dart';

class WatchAlbums {
  const WatchAlbums(this._repository);

  final AlbumRepository _repository;

  Stream<List<Album>> call(String coupleId) => _repository.watchAlbums(coupleId);
}

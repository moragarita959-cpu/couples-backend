import '../entities/album.dart';
import '../repositories/album_repository.dart';

class WatchAlbum {
  const WatchAlbum(this._repository);

  final AlbumRepository _repository;

  Stream<Album?> call(String albumId) => _repository.watchAlbum(albumId);
}

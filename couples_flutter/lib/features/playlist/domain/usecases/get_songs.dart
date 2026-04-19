import '../entities/song.dart';
import '../repositories/playlist_repository.dart';

class GetSongs {
  const GetSongs(this._repository);

  final PlaylistRepository _repository;

  Future<List<Song>> call() {
    return _repository.getSongs();
  }
}

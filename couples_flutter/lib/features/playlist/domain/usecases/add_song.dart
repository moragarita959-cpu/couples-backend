import '../entities/song.dart';
import '../repositories/playlist_repository.dart';

class AddSong {
  const AddSong(this._repository);

  final PlaylistRepository _repository;

  Future<Song> call(String name, String artist) {
    return _repository.addSong(name, artist);
  }
}

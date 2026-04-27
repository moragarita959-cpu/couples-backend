import '../entities/song.dart';
import '../repositories/playlist_repository.dart';

class AddSong {
  const AddSong(this._repository);

  final PlaylistRepository _repository;

  Future<Song> call({
    required String name,
    required String artist,
    required String genre,
  }) {
    return _repository.addSong(name: name, artist: artist, genre: genre);
  }
}

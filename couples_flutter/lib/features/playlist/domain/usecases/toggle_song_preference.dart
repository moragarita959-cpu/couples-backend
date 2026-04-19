import '../entities/song.dart';
import '../repositories/playlist_repository.dart';

class ToggleSongPreference {
  const ToggleSongPreference(this._repository);

  final PlaylistRepository _repository;

  Future<void> call(String songId, SongPreference value) {
    return _repository.toggleSongPreference(songId, value);
  }
}

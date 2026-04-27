import '../repositories/playlist_repository.dart';

class DeleteSong {
  const DeleteSong(this._repository);

  final PlaylistRepository _repository;

  Future<void> call(String songId) {
    return _repository.deleteSong(songId);
  }
}

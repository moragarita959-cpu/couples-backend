import '../entities/song_review.dart';
import '../repositories/playlist_repository.dart';

class GetReviews {
  const GetReviews(this._repository);

  final PlaylistRepository _repository;

  Future<List<SongReview>> call(String songId) {
    return _repository.getReviews(songId);
  }
}

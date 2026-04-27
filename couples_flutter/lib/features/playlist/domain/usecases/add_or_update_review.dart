import '../entities/song_review.dart';
import '../repositories/playlist_repository.dart';

class AddOrUpdateReview {
  const AddOrUpdateReview(this._repository);

  final PlaylistRepository _repository;

  Future<SongReview> call(
    String songId,
    String content,
    List<String> styleTags,
    double singleScore,
    ReviewAuthor author,
  ) {
    return _repository.addOrUpdateReview(
      songId,
      content,
      styleTags,
      singleScore,
      author,
    );
  }
}

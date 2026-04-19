import '../entities/song_review.dart';
import '../repositories/playlist_repository.dart';

class AddOrUpdateReview {
  const AddOrUpdateReview(this._repository);

  final PlaylistRepository _repository;

  Future<SongReview> call(
    String songId,
    String content,
    List<String> styleTags,
    int atmosphereScore,
    int resonanceScore,
    int shareScore,
    ReviewAuthor author,
  ) {
    return _repository.addOrUpdateReview(
      songId,
      content,
      styleTags,
      atmosphereScore,
      resonanceScore,
      shareScore,
      author,
    );
  }
}

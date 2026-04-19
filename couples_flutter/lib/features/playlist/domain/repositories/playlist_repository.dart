import '../entities/song.dart';
import '../entities/song_review.dart';

abstract class PlaylistRepository {
  Future<Song> addSong(String name, String artist);

  Future<List<Song>> getSongs();

  Future<void> toggleSongPreference(String songId, SongPreference value);

  Future<SongReview> addOrUpdateReview(
    String songId,
    String content,
    List<String> styleTags,
    int atmosphereScore,
    int resonanceScore,
    int shareScore,
    ReviewAuthor author,
  );

  Future<List<SongReview>> getReviews(String songId);
}

import '../entities/song.dart';
import '../entities/song_review.dart';

abstract class PlaylistRepository {
  Future<Song> addSong({
    required String name,
    required String artist,
    required String genre,
  });

  Future<List<Song>> getSongs();

  Future<void> toggleSongPreference(String songId, SongPreference value);

  Future<void> deleteSong(String songId);

  Future<SongReview> addOrUpdateReview(
    String songId,
    String content,
    List<String> styleTags,
    double singleScore,
    ReviewAuthor author,
  );

  Future<List<SongReview>> getReviews(String songId);
}

class DuplicatePlaylistSongException implements Exception {
  const DuplicatePlaylistSongException();
}

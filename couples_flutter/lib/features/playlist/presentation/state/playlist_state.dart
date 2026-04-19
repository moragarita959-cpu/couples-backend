import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';

class PlaylistState {
  const PlaylistState({
    this.songs = const <Song>[],
    this.selectedSongId,
    this.reviewsBySongId = const <String, List<SongReview>>{},
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final List<Song> songs;
  final String? selectedSongId;
  final Map<String, List<SongReview>> reviewsBySongId;
  final String? errorMessage;

  PlaylistState copyWith({
    List<Song>? songs,
    Object? selectedSongId = _noChange,
    Map<String, List<SongReview>>? reviewsBySongId,
    Object? errorMessage = _noChange,
  }) {
    return PlaylistState(
      songs: songs ?? this.songs,
      selectedSongId: identical(selectedSongId, _noChange)
          ? this.selectedSongId
          : selectedSongId as String?,
      reviewsBySongId: reviewsBySongId ?? this.reviewsBySongId,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

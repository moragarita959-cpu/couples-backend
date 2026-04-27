import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';

enum PlaylistSortMode {
  time,
  score,
  alphabet,
}

enum PlaylistRankingPeriod {
  week,
  month,
  year,
}

enum PlaylistRankingScope {
  total,
  me,
  partner,
}

class PlaylistRankingEntry {
  const PlaylistRankingEntry({
    required this.song,
    required this.rank,
    required this.myScore,
    required this.partnerScore,
    required this.totalScore,
    required this.lastRatedAt,
  });

  final Song song;
  final int rank;
  final double myScore;
  final double partnerScore;
  final double totalScore;
  final DateTime lastRatedAt;

  /// Combined (我+TA) total in ranking period ≥ 28 → Greek / 炫彩 tier.
  bool get hasEliteCombinedScore => totalScore >= 28.0;
}

class PlaylistState {
  const PlaylistState({
    this.songs = const <Song>[],
    this.selectedSongId,
    this.reviewsBySongId = const <String, List<SongReview>>{},
    this.errorMessage,
    this.sortMode = PlaylistSortMode.time,
    this.rankingPeriod = PlaylistRankingPeriod.week,
    this.rankingScope = PlaylistRankingScope.total,
    this.uploadingSongKeys = const <String>{},
    this.expandedCommentSongIds = const <String>{},
  });

  static const Object _noChange = Object();

  final List<Song> songs;
  final String? selectedSongId;
  final Map<String, List<SongReview>> reviewsBySongId;
  final String? errorMessage;
  final PlaylistSortMode sortMode;
  final PlaylistRankingPeriod rankingPeriod;
  final PlaylistRankingScope rankingScope;
  final Set<String> uploadingSongKeys;
  final Set<String> expandedCommentSongIds;

  bool get isSubmittingSong => uploadingSongKeys.isNotEmpty;

  PlaylistState copyWith({
    List<Song>? songs,
    Object? selectedSongId = _noChange,
    Map<String, List<SongReview>>? reviewsBySongId,
    Object? errorMessage = _noChange,
    PlaylistSortMode? sortMode,
    PlaylistRankingPeriod? rankingPeriod,
    PlaylistRankingScope? rankingScope,
    Set<String>? uploadingSongKeys,
    Set<String>? expandedCommentSongIds,
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
      sortMode: sortMode ?? this.sortMode,
      rankingPeriod: rankingPeriod ?? this.rankingPeriod,
      rankingScope: rankingScope ?? this.rankingScope,
      uploadingSongKeys: uploadingSongKeys ?? this.uploadingSongKeys,
      expandedCommentSongIds:
          expandedCommentSongIds ?? this.expandedCommentSongIds,
    );
  }
}

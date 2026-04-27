import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/add_or_update_review.dart';
import '../../domain/usecases/add_song.dart';
import '../../domain/usecases/delete_song.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/get_songs.dart';
import '../../domain/usecases/toggle_song_preference.dart';
import 'playlist_state.dart';

class PlaylistController extends StateNotifier<PlaylistState> {
  PlaylistController(
    this._addSong,
    this._getSongs,
    this._toggleSongPreference,
    this._deleteSong,
    this._addOrUpdateReview,
    this._getReviews,
    this._addFeedEvent,
  ) : super(const PlaylistState()) {
    load();
  }

  final AddSong _addSong;
  final GetSongs _getSongs;
  final ToggleSongPreference _toggleSongPreference;
  final DeleteSong _deleteSong;
  final AddOrUpdateReview _addOrUpdateReview;
  final GetReviews _getReviews;
  final AddFeedEvent _addFeedEvent;

  Future<void> load() async {
    final songs = await _getSongs();
    final reviewsBySongId = <String, List<SongReview>>{};
    for (final song in songs) {
      reviewsBySongId[song.id] = await _getReviews(song.id);
    }
    state = state.copyWith(
      songs: songs.where((song) => !song.isDeleted).toList(),
      reviewsBySongId: reviewsBySongId,
      errorMessage: null,
    );
  }

  void selectSong(String? songId) {
    state = state.copyWith(selectedSongId: songId);
  }

  void setSortMode(PlaylistSortMode sortMode) {
    state = state.copyWith(sortMode: sortMode);
  }

  void setRankingPeriod(PlaylistRankingPeriod period) {
    state = state.copyWith(rankingPeriod: period);
  }

  void setRankingScope(PlaylistRankingScope scope) {
    state = state.copyWith(rankingScope: scope);
  }

  void toggleComments(String songId) {
    final next = Set<String>.from(state.expandedCommentSongIds);
    if (!next.add(songId)) {
      next.remove(songId);
    }
    state = state.copyWith(expandedCommentSongIds: next);
  }

  List<Song> sortedSongs() {
    final songs = state.songs.where((song) => !song.isDeleted).toList();
    switch (state.sortMode) {
      case PlaylistSortMode.time:
        songs.sort((a, b) {
          final byTime = b.createdAt.compareTo(a.createdAt);
          return byTime != 0 ? byTime : b.id.compareTo(a.id);
        });
      case PlaylistSortMode.score:
        songs.sort((a, b) {
          final byScore = totalScoreFor(b.id).compareTo(totalScoreFor(a.id));
          if (byScore != 0) {
            return byScore;
          }
          final byRatedAt = _lastRatedAtFor(b.id).compareTo(_lastRatedAtFor(a.id));
          if (byRatedAt != 0) {
            return byRatedAt;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
      case PlaylistSortMode.alphabet:
        songs.sort((a, b) {
          final byName = a.name.trim().toLowerCase().compareTo(
                b.name.trim().toLowerCase(),
              );
          if (byName != 0) {
            return byName;
          }
          return a.artist.trim().toLowerCase().compareTo(
                b.artist.trim().toLowerCase(),
              );
        });
    }
    return songs;
  }

  Future<bool> addSong({
    required String name,
    required String artist,
    required String genre,
  }) async {
    final trimmedName = name.trim();
    final trimmedArtist = artist.trim();
    final trimmedGenre = genre.trim();
    if (trimmedName.isEmpty || trimmedArtist.isEmpty) {
      state = state.copyWith(errorMessage: '歌名和歌手都不能为空');
      return false;
    }

    final key = _songKey(trimmedName, trimmedArtist);
    if (state.uploadingSongKeys.contains(key)) {
      state = state.copyWith(errorMessage: '这首歌正在上传中，请稍等一下');
      return false;
    }
    final exists = state.songs.any(
      (song) => _songKey(song.name, song.artist) == key && !song.isDeleted,
    );
    if (exists) {
      state = state.copyWith(errorMessage: '这首歌已经在歌单里了');
      return false;
    }

    state = state.copyWith(
      uploadingSongKeys: <String>{...state.uploadingSongKeys, key},
      errorMessage: null,
    );

    try {
      final created = await _addSong(
        name: trimmedName,
        artist: trimmedArtist,
        genre: trimmedGenre,
      );
      await _addFeedEvent(
        eventType: FeedEventType.songAdded,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.song,
        targetId: created.id,
        summaryText: FeedSummaryBuilder.songAdded(songName: created.name),
      );
      await load();
      return true;
    } on DuplicatePlaylistSongException {
      state = state.copyWith(errorMessage: '这首歌已经在歌单里了');
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: '上传歌曲失败，请稍后再试');
      return false;
    } finally {
      final next = Set<String>.from(state.uploadingSongKeys)..remove(key);
      state = state.copyWith(uploadingSongKeys: next);
    }
  }

  Future<void> togglePreference(String songId, SongPreference value) async {
    try {
      await _toggleSongPreference(songId, value);
      await load();
    } catch (_) {
      state = state.copyWith(errorMessage: '更新歌曲状态失败');
    }
  }

  Future<void> deleteSong(Song song) async {
    final nextSongs = state.songs.where((item) => item.id != song.id).toList();
    final nextReviews = Map<String, List<SongReview>>.from(state.reviewsBySongId)
      ..remove(song.id);
    state = state.copyWith(
      songs: nextSongs,
      reviewsBySongId: nextReviews,
      selectedSongId:
          state.selectedSongId == song.id ? null : state.selectedSongId,
      errorMessage: null,
    );

    try {
      await _deleteSong(song.id);
    } catch (_) {
      state = state.copyWith(errorMessage: '已从本地移除，云端删除会稍后同步');
    }
  }

  Future<void> loadReviews(String songId) async {
    final reviews = await _getReviews(songId);
    final nextMap = Map<String, List<SongReview>>.from(state.reviewsBySongId);
    nextMap[songId] = reviews;
    state = state.copyWith(reviewsBySongId: nextMap, errorMessage: null);
  }

  Future<bool> addOrUpdateReview({
    required String songId,
    required String content,
    required List<String> styleTags,
    required double singleScore,
  }) async {
    final trimmed = content.trim();
    if (singleScore < -15 || singleScore > 15) {
      state = state.copyWith(errorMessage: '评分必须在 -15 到 15 之间');
      return false;
    }

    try {
      final existingReviews = await _getReviews(songId);
      final hadMyReview = existingReviews.any(
        (review) => review.author == ReviewAuthor.me,
      );

      await _addOrUpdateReview(
        songId,
        trimmed,
        styleTags,
        singleScore,
        ReviewAuthor.me,
      );

      final songName = state.songs
          .firstWhere(
            (song) => song.id == songId,
            orElse: () => Song(
              id: songId,
              name: '这首歌',
              artist: '',
              createdAt: DateTime.now(),
              preference: SongPreference.none,
            ),
          )
          .name;

      await _addFeedEvent(
        eventType: hadMyReview
            ? FeedEventType.songReviewUpdated
            : FeedEventType.songReviewAdded,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.song,
        targetId: songId,
        summaryText: hadMyReview
            ? FeedSummaryBuilder.songReviewUpdated(songName: songName)
            : FeedSummaryBuilder.songReviewAdded(songName: songName),
      );

      await loadReviews(songId);
      state = state.copyWith(errorMessage: null);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '保存曲评失败');
      return false;
    }
  }

  SongReview? reviewByAuthor(String songId, ReviewAuthor author) {
    final reviews = state.reviewsBySongId[songId] ?? const <SongReview>[];
    for (final review in reviews) {
      if (review.author == author) {
        return review;
      }
    }
    return null;
  }

  double totalScoreFor(String songId) {
    final myScore = reviewByAuthor(songId, ReviewAuthor.me)?.totalScore ?? 0;
    final partnerScore =
        reviewByAuthor(songId, ReviewAuthor.partner)?.totalScore ?? 0;
    return myScore + partnerScore;
  }

  /// Upload order 1..N by [Song.createdAt] ascending (non-deleted only).
  Map<String, int> uploadOrdinalBySongId() {
    final list = state.songs.where((s) => !s.isDeleted).toList()
      ..sort((a, b) {
        final byTime = a.createdAt.compareTo(b.createdAt);
        if (byTime != 0) {
          return byTime;
        }
        return a.id.compareTo(b.id);
      });
    final map = <String, int>{};
    for (var i = 0; i < list.length; i++) {
      map[list[i].id] = i + 1;
    }
    return map;
  }

  /// Among songs with full combined score ≥ 28, order by upload time; returns 0-based Greek index or null.
  int? greekBadgeIndexForSong(String songId) {
    if (totalScoreFor(songId) < 28) {
      return null;
    }
    final list = state.songs.where((s) => !s.isDeleted).toList()
      ..sort((a, b) {
        final byTime = a.createdAt.compareTo(b.createdAt);
        if (byTime != 0) {
          return byTime;
        }
        return a.id.compareTo(b.id);
      });
    var index = 0;
    for (final song in list) {
      if (totalScoreFor(song.id) >= 28) {
        if (song.id == songId) {
          return index;
        }
        index++;
      }
    }
    return null;
  }

  List<PlaylistRankingEntry> rankingsFor(
    PlaylistRankingPeriod period, {
    PlaylistRankingScope scope = PlaylistRankingScope.total,
  }) {
    final start = _periodStart(period);
    final entries = <PlaylistRankingEntry>[];
    for (final song in state.songs.where((item) => !item.isDeleted)) {
      final reviews = state.reviewsBySongId[song.id] ?? const <SongReview>[];
      var myScore = 0.0;
      var partnerScore = 0.0;
      DateTime? lastRatedAt;
      for (final review in reviews) {
        if (review.createdAt.isBefore(start)) {
          continue;
        }
        if (review.author == ReviewAuthor.me) {
          myScore = review.totalScore;
        } else {
          partnerScore = review.totalScore;
        }
        if (lastRatedAt == null || review.createdAt.isAfter(lastRatedAt)) {
          lastRatedAt = review.createdAt;
        }
      }
      final total = myScore + partnerScore;
      final scopedScore = switch (scope) {
        PlaylistRankingScope.total => total,
        PlaylistRankingScope.me => myScore,
        PlaylistRankingScope.partner => partnerScore,
      };
      if (scopedScore <= 0) {
        continue;
      }
      entries.add(
        PlaylistRankingEntry(
          song: song,
          rank: 0,
          myScore: myScore,
          partnerScore: partnerScore,
          totalScore: total,
          lastRatedAt: lastRatedAt ?? song.createdAt,
        ),
      );
    }

    entries.sort((a, b) {
      final aScore = switch (scope) {
        PlaylistRankingScope.total => a.totalScore,
        PlaylistRankingScope.me => a.myScore,
        PlaylistRankingScope.partner => a.partnerScore,
      };
      final bScore = switch (scope) {
        PlaylistRankingScope.total => b.totalScore,
        PlaylistRankingScope.me => b.myScore,
        PlaylistRankingScope.partner => b.partnerScore,
      };
      final byScore = bScore.compareTo(aScore);
      if (byScore != 0) {
        return byScore;
      }
      final byRatedAt = b.lastRatedAt.compareTo(a.lastRatedAt);
      if (byRatedAt != 0) {
        return byRatedAt;
      }
      return b.song.createdAt.compareTo(a.song.createdAt);
    });

    return <PlaylistRankingEntry>[
      for (var i = 0; i < entries.length && i < 10; i++)
        PlaylistRankingEntry(
          song: entries[i].song,
          rank: i + 1,
          myScore: entries[i].myScore,
          partnerScore: entries[i].partnerScore,
          totalScore: entries[i].totalScore,
          lastRatedAt: entries[i].lastRatedAt,
        ),
    ];
  }

  DateTime _lastRatedAtFor(String songId) {
    final reviews = state.reviewsBySongId[songId] ?? const <SongReview>[];
    DateTime? latest;
    for (final review in reviews) {
      if (latest == null || review.createdAt.isAfter(latest)) {
        latest = review.createdAt;
      }
    }
    return latest ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime _periodStart(PlaylistRankingPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case PlaylistRankingPeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        return today.subtract(Duration(days: now.weekday - DateTime.monday));
      case PlaylistRankingPeriod.month:
        return DateTime(now.year, now.month);
      case PlaylistRankingPeriod.year:
        return DateTime(now.year);
    }
  }

  List<String> allKnownTags() {
    final tags = <String>{};
    for (final reviews in state.reviewsBySongId.values) {
      for (final review in reviews) {
        for (final tag in review.styleTags) {
          final trimmed = tag.trim();
          if (trimmed.isNotEmpty) {
            tags.add(trimmed);
          }
        }
      }
    }
    final sorted = tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  List<Song> songsByTagQuery(String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return const <Song>[];
    }
    final result = <Song>[];
    for (final song in state.songs.where((item) => !item.isDeleted)) {
      final reviews = state.reviewsBySongId[song.id] ?? const <SongReview>[];
      final matched = reviews.any(
        (review) => review.styleTags.any(
          (tag) => tag.trim().toLowerCase().contains(keyword),
        ),
      );
      if (matched) {
        result.add(song);
      }
    }
    return result;
  }

  String _songKey(String name, String artist) {
    return '${name.trim().toLowerCase()}::${artist.trim().toLowerCase()}';
  }
}

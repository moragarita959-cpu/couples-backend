import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/usecases/add_or_update_review.dart';
import '../../domain/usecases/add_song.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/get_songs.dart';
import '../../domain/usecases/toggle_song_preference.dart';
import 'playlist_state.dart';

class PlaylistController extends StateNotifier<PlaylistState> {
  PlaylistController(
    this._addSong,
    this._getSongs,
    this._toggleSongPreference,
    this._addOrUpdateReview,
    this._getReviews,
    this._addFeedEvent,
  ) : super(const PlaylistState()) {
    load();
  }

  final AddSong _addSong;
  final GetSongs _getSongs;
  final ToggleSongPreference _toggleSongPreference;
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
      songs: songs,
      reviewsBySongId: reviewsBySongId,
      errorMessage: null,
    );
  }

  void selectSong(String? songId) {
    state = state.copyWith(selectedSongId: songId);
  }

  Future<bool> addSong({required String name, required String artist}) async {
    final trimmedName = name.trim();
    final trimmedArtist = artist.trim();
    if (trimmedName.isEmpty || trimmedArtist.isEmpty) {
      state = state.copyWith(errorMessage: '歌名和歌手都不能为空');
      return false;
    }

    try {
      final created = await _addSong(trimmedName, trimmedArtist);
      await _addFeedEvent(
        eventType: FeedEventType.songAdded,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.song,
        targetId: created.id,
        summaryText: FeedSummaryBuilder.songAdded(songName: created.name),
      );
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '新增歌曲失败');
      return false;
    }
  }

  Future<void> togglePreference(String songId, SongPreference value) async {
    try {
      await _toggleSongPreference(songId, value);
      await load();
    } catch (_) {
      state = state.copyWith(errorMessage: '更新歌曲偏好失败');
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
    required int atmosphereScore,
    required int resonanceScore,
    required int shareScore,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: '请输入乐评内容');
      return false;
    }
    if (atmosphereScore < 0 ||
        resonanceScore < 0 ||
        shareScore < 0 ||
        atmosphereScore > 5 ||
        resonanceScore > 5 ||
        shareScore > 5) {
      state = state.copyWith(errorMessage: '每项评分都必须在 0 到 5 之间');
      return false;
    }

    try {
      final existingReviews = await _getReviews(songId);
      final hadMyReview = existingReviews.any((review) => review.author == ReviewAuthor.me);

      await _addOrUpdateReview(
        songId,
        trimmed,
        styleTags,
        atmosphereScore,
        resonanceScore,
        shareScore,
        ReviewAuthor.me,
      );

      String songName = '这首歌';
      for (final song in state.songs) {
        if (song.id == songId) {
          songName = song.name;
          break;
        }
      }

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
      state = state.copyWith(errorMessage: '保存乐评失败');
      return false;
    }
  }
}

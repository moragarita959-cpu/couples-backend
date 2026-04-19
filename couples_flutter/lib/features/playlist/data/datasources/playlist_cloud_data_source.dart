import '../../../../core/network/api_client.dart';
import '../models/song_model.dart';
import '../models/song_review_model.dart';

class PlaylistCloudDataSource {
  const PlaylistCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SongModel>> listSongs({required String coupleId}) async {
    final payload = await _apiClient.listPlaylistSongs(coupleId: coupleId);
    return payload.map(SongModel.fromCloudJson).toList();
  }

  Future<SongModel> upsertSong({
    required SongModel song,
    required String coupleId,
  }) async {
    final payload = await _apiClient.upsertPlaylistSong(song.toCloudJson(coupleId: coupleId));
    return SongModel.fromCloudJson(payload);
  }

  Future<List<SongReviewModel>> listReviews({
    required String coupleId,
    required String songId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listPlaylistReviews(
      coupleId: coupleId,
      songId: songId,
      currentUserId: currentUserId,
    );
    return payload.map(SongReviewModel.fromCloudJson).toList();
  }

  Future<SongReviewModel> upsertReview({
    required SongReviewModel review,
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.upsertPlaylistReview(
      review.toCloudJson(coupleId: coupleId, currentUserId: currentUserId),
    );
    return SongReviewModel.fromCloudJson(payload);
  }
}

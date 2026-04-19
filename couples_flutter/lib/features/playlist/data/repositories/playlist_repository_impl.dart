import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_cloud_data_source.dart';
import '../datasources/playlist_local_data_source.dart';
import '../models/song_model.dart';
import '../models/song_review_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  const PlaylistRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
  );

  final PlaylistLocalDataSource _localDataSource;
  final PlaylistCloudDataSource _cloudDataSource;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;

  @override
  Future<Song> addSong(String name, String artist) async {
    final now = DateTime.now();
    final draft = SongModel(
      id: 'song-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      artist: artist.trim(),
      createdAt: now,
      preference: SongPreference.none,
    );
    await _localDataSource.upsertSong(draft);

    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return draft;
    }

    final saved = await _cloudDataSource.upsertSong(song: draft, coupleId: coupleId);
    await _localDataSource.upsertSong(saved);
    return saved;
  }

  @override
  Future<List<Song>> getSongs() async {
    final coupleId = _resolveCoupleId();
    if (coupleId != null && coupleId.isNotEmpty) {
      final remote = await _cloudDataSource.listSongs(coupleId: coupleId);
      await _localDataSource.replaceSongs(remote);
    }
    return _localDataSource.getSongs();
  }

  @override
  Future<void> toggleSongPreference(String songId, SongPreference value) async {
    final current = await _localDataSource.getSongById(songId);
    if (current == null) {
      throw Exception('Song not found');
    }
    final next = current.preference == value ? SongPreference.none : value;
    final updated = current.copyWith(preference: next);
    await _localDataSource.upsertSong(updated);

    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }

    final saved = await _cloudDataSource.upsertSong(song: updated, coupleId: coupleId);
    await _localDataSource.upsertSong(saved);
  }

  @override
  Future<SongReview> addOrUpdateReview(
    String songId,
    String content,
    List<String> styleTags,
    int atmosphereScore,
    int resonanceScore,
    int shareScore,
    ReviewAuthor author,
  ) async {
    final now = DateTime.now();
    final existing = await _localDataSource.getReviews(songId);
    final existingMine = existing.cast<SongReview?>().firstWhere(
      (review) => review?.author == author,
      orElse: () => null,
    );

    final draft = SongReviewModel(
      id: existingMine?.id ?? 'review-${now.microsecondsSinceEpoch}',
      songId: songId,
      author: author,
      content: content.trim(),
      styleTags: styleTags,
      atmosphereScore: atmosphereScore,
      resonanceScore: resonanceScore,
      shareScore: shareScore,
      createdAt: now,
    );

    await _localDataSource.upsertReview(draft);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return draft;
    }

    final saved = await _cloudDataSource.upsertReview(
      review: draft,
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    await _localDataSource.upsertReview(saved);
    return saved;
  }

  @override
  Future<List<SongReview>> getReviews(String songId) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId != null &&
        coupleId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      final remote = await _cloudDataSource.listReviews(
        coupleId: coupleId,
        songId: songId,
        currentUserId: currentUserId,
      );
      await _localDataSource.replaceReviews(songId, remote);
    }
    return _localDataSource.getReviews(songId);
  }
}

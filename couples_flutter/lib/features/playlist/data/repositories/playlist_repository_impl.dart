import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../../../core/network/api_client.dart';
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
  Future<Song> addSong({
    required String name,
    required String artist,
    required String genre,
  }) async {
    final existing = await _localDataSource.findActiveSongByTitleArtist(
      name: name,
      artist: artist,
    );
    if (existing != null) {
      throw const DuplicatePlaylistSongException();
    }

    final now = DateTime.now();
    final draft = SongModel(
      id: 'song-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      artist: artist.trim(),
      genre: genre.trim(),
      createdAt: now,
      updatedAt: now,
      preference: SongPreference.none,
      recommender: SongRecommender.me,
      pendingSync: true,
    );
    await _localDataSource.upsertSong(draft);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return draft;
    }

    late final SongModel saved;
    try {
      saved = await _cloudDataSource.upsertSong(
        song: draft,
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
    } on ApiClientException catch (error) {
      if (error.code == 'duplicate_playlist_song') {
        await _localDataSource.markSongDeleted(id: draft.id, updatedAt: now);
        throw const DuplicatePlaylistSongException();
      }
      return draft;
    } catch (_) {
      return draft;
    }
    await _localDataSource.upsertSong(saved);
    return saved;
  }

  @override
  Future<List<Song>> getSongs() async {
    await _localDataSource.restorePendingDeletedSongs();
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId != null &&
        coupleId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      try {
        await _syncPendingSongs(coupleId: coupleId, currentUserId: currentUserId);
        final remote = await _cloudDataSource.listSongs(
          coupleId: coupleId,
          currentUserId: currentUserId,
        );
        await _localDataSource.mergeSongs(remote);
      } catch (_) {
        // Keep local playlist available when cloud sync is temporarily broken.
      }
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
    final updated = current.copyWith(
      preference: next,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    await _localDataSource.upsertSong(updated);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return;
    }

    try {
      final saved = await _cloudDataSource.upsertSong(
        song: updated,
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
      await _localDataSource.upsertSong(saved);
    } catch (_) {
      // Local preference is already saved and will retry on the next sync.
    }
  }

  @override
  Future<void> deleteSong(String songId) async {
    final current = await _localDataSource.getSongById(songId);
    if (current == null) {
      throw Exception('Song not found');
    }
    final updatedAt = DateTime.now();
    await _localDataSource.markSongDeleted(id: songId, updatedAt: updatedAt);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return;
    }

    try {
      await _cloudDataSource.deleteSong(
        coupleId: coupleId,
        currentUserId: currentUserId,
        songId: songId,
        updatedAt: updatedAt,
      );
      await _localDataSource.upsertSong(
        current.copyWith(
          updatedAt: updatedAt,
          isDeleted: true,
          pendingSync: false,
        ),
      );
    } catch (_) {
      // Keep the local tombstone pending without breaking the UI.
    }
  }

  @override
  Future<SongReview> addOrUpdateReview(
    String songId,
    String content,
    List<String> styleTags,
    double singleScore,
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
      atmosphereScore: (singleScore.clamp(-15.0, 15.0) * 10).round(),
      resonanceScore: 0,
      shareScore: 0,
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

    try {
      final saved = await _cloudDataSource.upsertReview(
        review: draft,
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
      await _localDataSource.upsertReview(saved);
      return saved;
    } catch (_) {
      return draft;
    }
  }

  @override
  Future<List<SongReview>> getReviews(String songId) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId != null &&
        coupleId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      try {
        final remote = await _cloudDataSource.listReviews(
          coupleId: coupleId,
          songId: songId,
          currentUserId: currentUserId,
        );
        await _localDataSource.mergeReviews(remote);
      } catch (_) {
        // Reviews remain available from local cache.
      }
    }
    return _localDataSource.getReviews(songId);
  }

  Future<void> _syncPendingSongs({
    required String coupleId,
    required String currentUserId,
  }) async {
    final pending = await _localDataSource.getPendingSyncSongs();
    for (final song in pending) {
      try {
        if (song.isDeleted) {
          await _cloudDataSource.deleteSong(
            coupleId: coupleId,
            currentUserId: currentUserId,
            songId: song.id,
            updatedAt: song.updatedAt,
          );
          await _localDataSource.upsertSong(song.copyWith(pendingSync: false));
          continue;
        }

        final saved = await _cloudDataSource.upsertSong(
          song: song,
          coupleId: coupleId,
          currentUserId: currentUserId,
        );
        await _localDataSource.upsertSong(saved);
      } catch (_) {
        continue;
      }
    }
  }
}

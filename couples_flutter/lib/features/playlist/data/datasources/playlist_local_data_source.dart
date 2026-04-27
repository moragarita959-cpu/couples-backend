import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/song_model.dart';
import '../models/song_review_model.dart';

class PlaylistLocalDataSource {
  PlaylistLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<SongModel>> getSongs() async {
    final rows = await (_db.select(
      _db.songsTable,
    )
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(SongModel.fromRow).toList();
  }

  Future<void> restorePendingDeletedSongs() async {
    await (_db.update(_db.songsTable)
          ..where(
            (t) => t.isDeleted.equals(true) & t.pendingSync.equals(true),
          ))
        .write(
      const SongsTableCompanion(
        isDeleted: Value<bool>(false),
        pendingSync: Value<bool>(true),
      ),
    );
  }

  Future<List<SongModel>> getPendingSyncSongs() async {
    final rows = await (_db.select(
      _db.songsTable,
    )..where((t) => t.pendingSync.equals(true))).get();
    return rows.map(SongModel.fromRow).toList();
  }

  Future<void> replaceSongs(List<SongModel> songs) async {
    await _db.transaction(() async {
      await _db.delete(_db.songsTable).go();
      if (songs.isEmpty) {
        return;
      }
      await _db.batch((batch) {
        batch.insertAll(_db.songsTable, songs.map((item) => item.toCompanion()).toList());
      });
    });
  }

  Future<void> mergeSongs(List<SongModel> songs) async {
    if (songs.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      for (final song in songs) {
        final current = await getSongById(song.id);
        if (current == null || !current.updatedAt.isAfter(song.updatedAt)) {
          await upsertSong(song);
        }
      }
    });
  }

  Future<void> upsertSong(SongModel song) async {
    await _db.into(_db.songsTable).insertOnConflictUpdate(song.toCompanion());
  }

  Future<SongModel?> getSongById(String id) async {
    final row = await (_db.select(_db.songsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : SongModel.fromRow(row);
  }

  Future<SongModel?> findActiveSongByTitleArtist({
    required String name,
    required String artist,
  }) async {
    final normalizedName = name.trim().toLowerCase();
    final normalizedArtist = artist.trim().toLowerCase();
    if (normalizedName.isEmpty || normalizedArtist.isEmpty) {
      return null;
    }
    final songs = await getSongs();
    for (final song in songs) {
      if (song.name.trim().toLowerCase() == normalizedName &&
          song.artist.trim().toLowerCase() == normalizedArtist) {
        return song;
      }
    }
    return null;
  }

  Future<void> markSongDeleted({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.songsTable)..where((t) => t.id.equals(id))).write(
      SongsTableCompanion(
        updatedAt: Value<DateTime>(updatedAt),
        isDeleted: const Value<bool>(true),
        pendingSync: const Value<bool>(true),
      ),
    );
  }

  Future<List<SongReviewModel>> getReviews(String songId) async {
    final rows =
        await (_db.select(_db.songReviewsTable)
              ..where((t) => t.songId.equals(songId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(SongReviewModel.fromRow).toList();
  }

  Future<void> replaceReviews(String songId, List<SongReviewModel> reviews) async {
    await _db.transaction(() async {
      await (_db.delete(_db.songReviewsTable)..where((t) => t.songId.equals(songId))).go();
      if (reviews.isEmpty) {
        return;
      }
      await _db.batch((batch) {
        batch.insertAll(
          _db.songReviewsTable,
          reviews.map((item) => item.toCompanion()).toList(),
        );
      });
    });
  }

  Future<void> mergeReviews(List<SongReviewModel> reviews) async {
    if (reviews.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.songReviewsTable,
        reviews.map((item) => item.toCompanion()).toList(),
      );
    });
  }

  Future<void> upsertReview(SongReviewModel review) async {
    await _db.into(_db.songReviewsTable).insertOnConflictUpdate(review.toCompanion());
  }
}

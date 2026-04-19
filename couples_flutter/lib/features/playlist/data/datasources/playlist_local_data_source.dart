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
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
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

  Future<void> upsertSong(SongModel song) async {
    await _db.into(_db.songsTable).insertOnConflictUpdate(song.toCompanion());
  }

  Future<SongModel?> getSongById(String id) async {
    final row = await (_db.select(_db.songsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : SongModel.fromRow(row);
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

  Future<void> upsertReview(SongReviewModel review) async {
    await _db.into(_db.songReviewsTable).insertOnConflictUpdate(review.toCompanion());
  }
}

import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/album_model.dart';
import '../models/album_photo_model.dart';
import '../models/photo_comment_model.dart';

class AlbumLocalDataSource {
  const AlbumLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<AlbumModel>> watchAlbums(String coupleId) {
    final query = _db.select(_db.albumsTable)
      ..where((t) => t.coupleId.equals(coupleId))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      return Future.wait(rows.map(_hydrateAlbum));
    });
  }

  Stream<AlbumModel?> watchAlbum(String albumId) {
    final query = _db.select(_db.albumsTable)
      ..where((t) => t.id.equals(albumId))
      ..limit(1);
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) {
        return null;
      }
      return _hydrateAlbum(row);
    });
  }

  Future<AlbumModel> upsertAlbum(AlbumModel album) async {
    await _db.into(_db.albumsTable).insertOnConflictUpdate(album.toCompanion());
    return (await getAlbum(album.id))!;
  }

  Future<void> replaceAlbums(String coupleId, List<AlbumModel> albums) async {
    if (albums.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      // 全量按云端结果替换：先清该 couple 下评论与照片，再清相册，避免 Drift 无 FK 时孤儿行。
      final existingPhotos = await (_db.select(
        _db.albumPhotosTable,
      )..where((t) => t.coupleId.equals(coupleId))).get();
      final photoIds = existingPhotos.map((e) => e.id).toList();
      if (photoIds.isNotEmpty) {
        await (_db.delete(
          _db.photoCommentsTable,
        )..where((t) => t.photoId.isIn(photoIds))).go();
      }
      await (_db.delete(
        _db.albumPhotosTable,
      )..where((t) => t.coupleId.equals(coupleId))).go();
      await (_db.delete(
        _db.albumsTable,
      )..where((t) => t.coupleId.equals(coupleId))).go();
      if (albums.isEmpty) {
        return;
      }
      await _db.batch((batch) {
        batch.insertAll(
          _db.albumsTable,
          albums.map((album) => album.toCompanion()).toList(),
        );
      });
    });
  }

  Future<void> deleteAlbum(String albumId) async {
    await _db.transaction(() async {
      final photoRows = await (_db.select(
        _db.albumPhotosTable,
      )..where((t) => t.albumId.equals(albumId))).get();
      final photoIds = photoRows.map((item) => item.id).toList();
      if (photoIds.isNotEmpty) {
        await (_db.delete(
          _db.photoCommentsTable,
        )..where((t) => t.photoId.isIn(photoIds))).go();
      }
      await (_db.delete(
        _db.albumPhotosTable,
      )..where((t) => t.albumId.equals(albumId))).go();
      await (_db.delete(
        _db.albumsTable,
      )..where((t) => t.id.equals(albumId))).go();
    });
  }

  Stream<List<AlbumPhotoModel>> watchPhotos(String albumId) {
    final query = _db.select(_db.albumPhotosTable)
      ..where((t) => t.albumId.equals(albumId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.takenAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().asyncMap((rows) async {
      return Future.wait(rows.map(_hydratePhoto));
    });
  }

  Stream<AlbumPhotoModel?> watchPhoto(String photoId) {
    final query = _db.select(_db.albumPhotosTable)
      ..where((t) => t.id.equals(photoId))
      ..limit(1);
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) {
        return null;
      }
      return _hydratePhoto(row);
    });
  }

  Future<AlbumPhotoModel> upsertPhoto(AlbumPhotoModel photo) async {
    await _db.transaction(() async {
      await _db
          .into(_db.albumPhotosTable)
          .insertOnConflictUpdate(photo.toCompanion());
      await (_db.update(
        _db.albumsTable,
      )..where((t) => t.id.equals(photo.albumId))).write(
        AlbumsTableCompanion(updatedAt: Value<DateTime>(photo.updatedAt)),
      );
    });
    return (await getPhoto(photo.id))!;
  }

  Future<void> replacePhotos(
    String albumId,
    List<AlbumPhotoModel> photos,
  ) async {
    if (photos.isEmpty) {
      return;
    }
    final existing = await (_db.select(
      _db.albumPhotosTable,
    )..where((t) => t.albumId.equals(albumId))).get();
    final existingById = <String, AlbumPhotosTableData>{
      for (final item in existing) item.id: item,
    };

    await _db.transaction(() async {
      // Cloud photo list can be partial during transient server issues.
      // Only upsert remote items and never delete local items from list responses.
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.albumPhotosTable,
          photos.map((photo) {
            final current = existingById[photo.id];
            final imageUrl = (photo.imageUrl ?? '').trim().isNotEmpty
                ? photo.imageUrl
                : current?.imageUrl;
            return AlbumPhotoModel(
              id: photo.id,
              albumId: photo.albumId,
              coupleId: photo.coupleId,
              uploaderUserId: photo.uploaderUserId,
              imageUrl: imageUrl,
              localPath: photo.localPath ?? current?.localPath,
              caption: photo.caption,
              takenAt: photo.takenAt,
              createdAt: photo.createdAt,
              updatedAt: photo.updatedAt,
            ).toCompanion();
          }).toList(),
        );
      });
    });
  }

  Future<void> deletePhoto(String photoId) async {
    await _db.transaction(() async {
      final row =
          await (_db.select(_db.albumPhotosTable)
                ..where((t) => t.id.equals(photoId))
                ..limit(1))
              .getSingleOrNull();
      if (row == null) {
        return;
      }
      await (_db.delete(
        _db.photoCommentsTable,
      )..where((t) => t.photoId.equals(photoId))).go();
      await (_db.delete(
        _db.albumPhotosTable,
      )..where((t) => t.id.equals(photoId))).go();
      await (_db.update(
        _db.albumsTable,
      )..where((t) => t.id.equals(row.albumId))).write(
        AlbumsTableCompanion(updatedAt: Value<DateTime>(DateTime.now())),
      );
    });
  }

  Stream<List<PhotoCommentModel>> watchComments(String photoId) {
    final query = _db.select(_db.photoCommentsTable)
      ..where((t) => t.photoId.equals(photoId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map(
      (rows) => rows.map(PhotoCommentModel.fromRow).toList(),
    );
  }

  Future<PhotoCommentModel> upsertComment(PhotoCommentModel comment) async {
    await _db.transaction(() async {
      await _db
          .into(_db.photoCommentsTable)
          .insertOnConflictUpdate(comment.toCompanion());
      final photoRow =
          await (_db.select(_db.albumPhotosTable)
                ..where((t) => t.id.equals(comment.photoId))
                ..limit(1))
              .getSingleOrNull();
      if (photoRow != null) {
        await (_db.update(
          _db.albumPhotosTable,
        )..where((t) => t.id.equals(comment.photoId))).write(
          AlbumPhotosTableCompanion(
            updatedAt: Value<DateTime>(comment.updatedAt),
          ),
        );
        await (_db.update(
          _db.albumsTable,
        )..where((t) => t.id.equals(photoRow.albumId))).write(
          AlbumsTableCompanion(updatedAt: Value<DateTime>(comment.updatedAt)),
        );
      }
    });
    return (await getComment(comment.id))!;
  }

  Future<void> replaceComments(
    String photoId,
    List<PhotoCommentModel> comments,
  ) async {
    if (comments.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.photoCommentsTable,
          comments.map((comment) => comment.toCompanion()).toList(),
        );
      });
    });
  }

  Future<void> deleteComment(String commentId) async {
    await (_db.delete(
      _db.photoCommentsTable,
    )..where((t) => t.id.equals(commentId))).go();
  }

  Future<AlbumModel?> getAlbum(String albumId) async {
    final row =
        await (_db.select(_db.albumsTable)
              ..where((t) => t.id.equals(albumId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrateAlbum(row);
  }

  Future<AlbumPhotoModel?> getPhoto(String photoId) async {
    final row =
        await (_db.select(_db.albumPhotosTable)
              ..where((t) => t.id.equals(photoId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydratePhoto(row);
  }

  Future<PhotoCommentModel?> getComment(String commentId) async {
    final row =
        await (_db.select(_db.photoCommentsTable)
              ..where((t) => t.id.equals(commentId))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : PhotoCommentModel.fromRow(row);
  }

  Future<AlbumModel> _hydrateAlbum(AlbumsTableData album) async {
    final countExp = _db.albumPhotosTable.id.count();
    final maxUpdatedExp = _db.albumPhotosTable.updatedAt.max();
    final statsRow =
        await (_db.selectOnly(_db.albumPhotosTable)
              ..addColumns([countExp, maxUpdatedExp])
              ..where(_db.albumPhotosTable.albumId.equals(album.id)))
            .getSingle();
    final photoCount = statsRow.read(countExp) ?? 0;
    final lastPhotoAt = statsRow.read(maxUpdatedExp);
    final coverPhoto =
        await (_db.select(_db.albumPhotosTable)
              ..where((t) => t.albumId.equals(album.id))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();

    return AlbumModel(
      id: album.id,
      coupleId: album.coupleId,
      title: album.title,
      description: album.description,
      coverPhotoUrl: (album.coverPhotoUrl ?? '').trim().isNotEmpty
          ? album.coverPhotoUrl
          : coverPhoto?.imageUrl,
      coverLocalPath: coverPhoto?.localPath,
      createdByUserId: album.createdByUserId,
      createdAt: album.createdAt,
      updatedAt: album.updatedAt,
      photoCount: photoCount,
      lastPhotoAt: lastPhotoAt,
    );
  }

  Future<AlbumPhotoModel> _hydratePhoto(AlbumPhotosTableData photo) async {
    final album =
        await (_db.select(_db.albumsTable)
              ..where((t) => t.id.equals(photo.albumId))
              ..limit(1))
            .getSingleOrNull();
    final countExp = _db.photoCommentsTable.id.count();
    final commentRow =
        await (_db.selectOnly(_db.photoCommentsTable)
              ..addColumns([countExp])
              ..where(_db.photoCommentsTable.photoId.equals(photo.id)))
            .getSingle();
    final commentCount = commentRow.read(countExp) ?? 0;
    return AlbumPhotoModel(
      id: photo.id,
      albumId: photo.albumId,
      coupleId: photo.coupleId,
      uploaderUserId: photo.uploaderUserId,
      imageUrl: photo.imageUrl,
      localPath: photo.localPath,
      caption: photo.caption,
      takenAt: photo.takenAt,
      createdAt: photo.createdAt,
      updatedAt: photo.updatedAt,
      commentCount: commentCount,
      albumTitle: album?.title,
    );
  }
}

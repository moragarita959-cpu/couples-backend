import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/album_photo.dart';

class AlbumPhotoModel extends AlbumPhoto {
  const AlbumPhotoModel({
    required super.id,
    required super.albumId,
    required super.coupleId,
    required super.uploaderUserId,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
    super.localPath,
    super.caption,
    super.takenAt,
    super.commentCount,
    super.albumTitle,
  });

  factory AlbumPhotoModel.fromRow(AlbumPhotosTableData row) {
    return AlbumPhotoModel(
      id: row.id,
      albumId: row.albumId,
      coupleId: row.coupleId,
      uploaderUserId: row.uploaderUserId,
      imageUrl: row.imageUrl,
      localPath: row.localPath,
      caption: row.caption,
      takenAt: row.takenAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory AlbumPhotoModel.fromEntity(AlbumPhoto photo) {
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
      commentCount: photo.commentCount,
      albumTitle: photo.albumTitle,
    );
  }

  factory AlbumPhotoModel.fromCloudJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
    return AlbumPhotoModel(
      id: json['id'] as String,
      albumId: json['albumId'] as String,
      coupleId: json['coupleId'] as String,
      uploaderUserId: json['uploaderUserId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      localPath: json['localPath'] as String?,
      caption: json['caption'] as String? ?? '',
      takenAt: DateTime.tryParse(json['takenAt'] as String? ?? '')?.toLocal(),
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          createdAt,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      albumTitle: json['albumTitle'] as String?,
    );
  }

  Map<String, dynamic> toCloudUpdateJson({
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'caption': caption,
      'takenAt': takenAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  AlbumPhotosTableCompanion toCompanion() {
    return AlbumPhotosTableCompanion.insert(
      id: id,
      albumId: albumId,
      coupleId: coupleId,
      uploaderUserId: uploaderUserId,
      imageUrl: Value<String?>(imageUrl),
      localPath: Value<String?>(localPath),
      caption: Value<String>(caption),
      takenAt: Value<DateTime?>(takenAt),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

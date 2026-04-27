import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/album.dart';

class AlbumModel extends Album {
  const AlbumModel({
    required super.id,
    required super.coupleId,
    required super.title,
    required super.description,
    required super.createdByUserId,
    required super.createdAt,
    required super.updatedAt,
    super.coverPhotoUrl,
    super.coverLocalPath,
    super.photoCount,
    super.lastPhotoAt,
  });

  factory AlbumModel.fromRow(AlbumsTableData row) {
    return AlbumModel(
      id: row.id,
      coupleId: row.coupleId,
      title: row.title,
      description: row.description,
      coverPhotoUrl: row.coverPhotoUrl,
      createdByUserId: row.createdByUserId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory AlbumModel.fromEntity(Album album) {
    return AlbumModel(
      id: album.id,
      coupleId: album.coupleId,
      title: album.title,
      description: album.description,
      coverPhotoUrl: album.coverPhotoUrl,
      coverLocalPath: album.coverLocalPath,
      createdByUserId: album.createdByUserId,
      createdAt: album.createdAt,
      updatedAt: album.updatedAt,
      photoCount: album.photoCount,
      lastPhotoAt: album.lastPhotoAt,
    );
  }

  factory AlbumModel.fromCloudJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
    return AlbumModel(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      createdByUserId: (json['createdByUserId'] ?? json['created_by_user_id'])?.toString() ?? '',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          createdAt,
      photoCount: (json['photoCount'] as num?)?.toInt() ?? 0,
      lastPhotoAt: DateTime.tryParse(json['lastPhotoAt'] as String? ?? '')
          ?.toLocal(),
    );
  }

  Map<String, dynamic> toCloudCreateJson({
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'title': title,
      'description': description,
      'coverPhotoUrl': coverPhotoUrl,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toCloudUpdateJson({
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'title': title,
      'description': description,
      'coverPhotoUrl': coverPhotoUrl,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  AlbumsTableCompanion toCompanion() {
    return AlbumsTableCompanion.insert(
      id: id,
      coupleId: coupleId,
      title: title,
      description: Value<String>(description),
      coverPhotoUrl: Value<String?>(coverPhotoUrl),
      createdByUserId: createdByUserId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

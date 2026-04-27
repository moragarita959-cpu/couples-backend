import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/photo_comment.dart';

class PhotoCommentModel extends PhotoComment {
  const PhotoCommentModel({
    required super.id,
    required super.photoId,
    required super.coupleId,
    required super.authorUserId,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PhotoCommentModel.fromRow(PhotoCommentsTableData row) {
    return PhotoCommentModel(
      id: row.id,
      photoId: row.photoId,
      coupleId: row.coupleId,
      authorUserId: row.authorUserId,
      content: row.content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory PhotoCommentModel.fromEntity(PhotoComment comment) {
    return PhotoCommentModel(
      id: comment.id,
      photoId: comment.photoId,
      coupleId: comment.coupleId,
      authorUserId: comment.authorUserId,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
    );
  }

  factory PhotoCommentModel.fromCloudJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
    return PhotoCommentModel(
      id: json['id'] as String,
      photoId: json['photoId'] as String,
      coupleId: json['coupleId'] as String,
      authorUserId: json['authorUserId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          createdAt,
    );
  }

  Map<String, dynamic> toCloudJson({
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'photoId': photoId,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  PhotoCommentsTableCompanion toCompanion() {
    return PhotoCommentsTableCompanion.insert(
      id: id,
      photoId: photoId,
      coupleId: coupleId,
      authorUserId: authorUserId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

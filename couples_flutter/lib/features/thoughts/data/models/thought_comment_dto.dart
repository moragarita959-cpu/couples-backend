import 'package:drift/drift.dart' as drift;

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/thought_comment.dart';

class ThoughtCommentDto extends ThoughtComment {
  const ThoughtCommentDto({
    required super.id,
    required super.coupleId,
    required super.targetType,
    required super.targetId,
    required super.authorUserId,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ThoughtCommentDto.fromEntity(ThoughtComment entity) {
    return ThoughtCommentDto(
      id: entity.id,
      coupleId: entity.coupleId,
      targetType: entity.targetType,
      targetId: entity.targetId,
      authorUserId: entity.authorUserId,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory ThoughtCommentDto.fromRow(ThoughtCommentsTableData row) {
    return ThoughtCommentDto(
      id: row.id,
      coupleId: row.coupleId,
      targetType: row.targetType,
      targetId: row.targetId,
      authorUserId: row.authorUserId,
      content: row.content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ThoughtCommentsTableCompanion toCompanion() {
    return ThoughtCommentsTableCompanion(
      id: drift.Value<String>(id),
      coupleId: drift.Value<String>(coupleId),
      targetType: drift.Value<String>(targetType),
      targetId: drift.Value<String>(targetId),
      authorUserId: drift.Value<String>(authorUserId),
      content: drift.Value<String>(content),
      createdAt: drift.Value<DateTime>(createdAt),
      updatedAt: drift.Value<DateTime>(updatedAt),
    );
  }

  factory ThoughtCommentDto.fromCloudJson(Map<String, dynamic> json) {
    return ThoughtCommentDto(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      targetType: json['targetType'] as String? ?? ThoughtComment.targetTypeIdea,
      targetId: json['targetId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'targetType': targetType,
      'targetId': targetId,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}

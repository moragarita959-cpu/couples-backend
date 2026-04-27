import 'package:drift/drift.dart' as drift;

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/idea_note.dart';

class IdeaNoteDto extends IdeaNote {
  const IdeaNoteDto({
    required super.id,
    required super.coupleId,
    required super.authorUserId,
    required super.type,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.title,
    super.moodTag,
    super.colorStyle,
    super.layoutStyle,
    super.commentCount,
  });

  factory IdeaNoteDto.fromEntity(IdeaNote entity) {
    return IdeaNoteDto(
      id: entity.id,
      coupleId: entity.coupleId,
      authorUserId: entity.authorUserId,
      type: entity.type,
      title: entity.title,
      content: entity.content,
      moodTag: entity.moodTag,
      colorStyle: entity.colorStyle,
      layoutStyle: entity.layoutStyle,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      commentCount: entity.commentCount,
    );
  }

  factory IdeaNoteDto.fromRow(
    IdeaNotesTableData row, {
    required int commentCount,
  }) {
    return IdeaNoteDto(
      id: row.id,
      coupleId: row.coupleId,
      authorUserId: row.authorUserId,
      type: row.type,
      title: row.title,
      content: row.content,
      moodTag: row.moodTag,
      colorStyle: row.colorStyle,
      layoutStyle: row.layoutStyle,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      commentCount: commentCount,
    );
  }

  IdeaNotesTableCompanion toCompanion() {
    return IdeaNotesTableCompanion(
      id: drift.Value<String>(id),
      coupleId: drift.Value<String>(coupleId),
      authorUserId: drift.Value<String>(authorUserId),
      type: drift.Value<String>(type),
      title: drift.Value<String?>(title),
      content: drift.Value<String>(content),
      moodTag: drift.Value<String?>(moodTag),
      colorStyle: drift.Value<String?>(colorStyle),
      layoutStyle: drift.Value<String?>(layoutStyle),
      createdAt: drift.Value<DateTime>(createdAt),
      updatedAt: drift.Value<DateTime>(updatedAt),
    );
  }

  factory IdeaNoteDto.fromCloudJson(Map<String, dynamic> json) {
    return IdeaNoteDto(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      type: json['type'] as String? ?? IdeaNote.typeIdea,
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      moodTag: json['moodTag'] as String?,
      colorStyle: json['colorStyle'] as String?,
      layoutStyle: json['layoutStyle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'type': type,
      'title': title,
      'content': content,
      'moodTag': moodTag,
      'colorStyle': colorStyle,
      'layoutStyle': layoutStyle,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}

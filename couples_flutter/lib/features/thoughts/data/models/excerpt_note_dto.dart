import 'package:drift/drift.dart' as drift;

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/excerpt_note.dart';

class ExcerptNoteDto extends ExcerptNote {
  const ExcerptNoteDto({
    required super.id,
    required super.coupleId,
    required super.authorUserId,
    required super.category,
    required super.quoteText,
    required super.createdAt,
    required super.updatedAt,
    super.sourceTitle,
    super.sourceAuthor,
    super.sourceDetail,
    super.personalNote,
    super.cardStyle,
    super.colorStyle,
    super.commentCount,
  });

  factory ExcerptNoteDto.fromEntity(ExcerptNote entity) {
    return ExcerptNoteDto(
      id: entity.id,
      coupleId: entity.coupleId,
      authorUserId: entity.authorUserId,
      category: entity.category,
      quoteText: entity.quoteText,
      sourceTitle: entity.sourceTitle,
      sourceAuthor: entity.sourceAuthor,
      sourceDetail: entity.sourceDetail,
      personalNote: entity.personalNote,
      cardStyle: entity.cardStyle,
      colorStyle: entity.colorStyle,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      commentCount: entity.commentCount,
    );
  }

  factory ExcerptNoteDto.fromRow(
    ExcerptNotesTableData row, {
    required int commentCount,
  }) {
    return ExcerptNoteDto(
      id: row.id,
      coupleId: row.coupleId,
      authorUserId: row.authorUserId,
      category: row.category,
      quoteText: row.quoteText,
      sourceTitle: row.sourceTitle,
      sourceAuthor: row.sourceAuthor,
      sourceDetail: row.sourceDetail,
      personalNote: row.personalNote,
      cardStyle: row.cardStyle,
      colorStyle: row.colorStyle,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      commentCount: commentCount,
    );
  }

  ExcerptNotesTableCompanion toCompanion() {
    return ExcerptNotesTableCompanion(
      id: drift.Value<String>(id),
      coupleId: drift.Value<String>(coupleId),
      authorUserId: drift.Value<String>(authorUserId),
      category: drift.Value<String>(category),
      quoteText: drift.Value<String>(quoteText),
      sourceTitle: drift.Value<String?>(sourceTitle),
      sourceAuthor: drift.Value<String?>(sourceAuthor),
      sourceDetail: drift.Value<String?>(sourceDetail),
      personalNote: drift.Value<String?>(personalNote),
      cardStyle: drift.Value<String?>(cardStyle),
      colorStyle: drift.Value<String?>(colorStyle),
      createdAt: drift.Value<DateTime>(createdAt),
      updatedAt: drift.Value<DateTime>(updatedAt),
    );
  }

  factory ExcerptNoteDto.fromCloudJson(Map<String, dynamic> json) {
    return ExcerptNoteDto(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      category: json['category'] as String? ?? ExcerptNote.categoryCustom,
      quoteText: json['quoteText'] as String? ?? '',
      sourceTitle: json['sourceTitle'] as String?,
      sourceAuthor: json['sourceAuthor'] as String?,
      sourceDetail: json['sourceDetail'] as String?,
      personalNote: json['personalNote'] as String?,
      cardStyle: json['cardStyle'] as String?,
      colorStyle: json['colorStyle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'category': category,
      'quoteText': quoteText,
      'sourceTitle': sourceTitle,
      'sourceAuthor': sourceAuthor,
      'sourceDetail': sourceDetail,
      'personalNote': personalNote,
      'cardStyle': cardStyle,
      'colorStyle': colorStyle,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}

import 'dart:convert';

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
    super.moodTags = const <String>[],
    super.colorStyle,
    super.layoutStyle,
    super.stickerStyle,
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
      moodTags: entity.moodTags,
      colorStyle: entity.colorStyle,
      layoutStyle: entity.layoutStyle,
      stickerStyle: entity.stickerStyle,
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
      moodTags: _decodeMoodTags(row.moodTagsJson),
      colorStyle: row.colorStyle,
      layoutStyle: row.layoutStyle,
      stickerStyle: row.stickerStyle,
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
      moodTagsJson: drift.Value<String?>(_encodeMoodTags(moodTags)),
      colorStyle: drift.Value<String?>(colorStyle),
      layoutStyle: drift.Value<String?>(layoutStyle),
      stickerStyle: drift.Value<String?>(stickerStyle),
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
      moodTags: _decodeCloudMoodTags(json['moodTags']),
      colorStyle: json['colorStyle'] as String?,
      layoutStyle: json['layoutStyle'] as String?,
      stickerStyle: json['stickerStyle'] as String?,
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
      'moodTags': moodTags,
      'colorStyle': colorStyle,
      'layoutStyle': layoutStyle,
      'stickerStyle': stickerStyle,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  static String? _encodeMoodTags(List<String> tags) {
    if (tags.isEmpty) {
      return null;
    }
    return jsonEncode(tags);
  }

  static List<String> _decodeMoodTags(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => (item ?? '').toString().trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // Fallthrough: legacy strings or malformed JSON.
    }
    final fallback = raw.trim();
    return fallback.isEmpty ? const <String>[] : <String>[fallback];
  }

  static List<String> _decodeCloudMoodTags(Object? raw) {
    if (raw == null) {
      return const <String>[];
    }
    if (raw is List) {
      return raw
          .map((item) => (item ?? '').toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }
    if (raw is String) {
      return _decodeMoodTags(raw);
    }
    return const <String>[];
  }
}

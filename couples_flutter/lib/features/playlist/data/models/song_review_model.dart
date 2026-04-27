import 'dart:convert';

import '../../domain/entities/song_review.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class SongReviewModel extends SongReview {
  const SongReviewModel({
    required super.id,
    required super.songId,
    required super.author,
    required super.content,
    required super.styleTags,
    required super.atmosphereScore,
    required super.resonanceScore,
    required super.shareScore,
    required super.createdAt,
  });

  SongReviewModel copyWith({
    String? id,
    String? songId,
    ReviewAuthor? author,
    String? content,
    List<String>? styleTags,
    int? atmosphereScore,
    int? resonanceScore,
    int? shareScore,
    DateTime? createdAt,
  }) {
    return SongReviewModel(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      author: author ?? this.author,
      content: content ?? this.content,
      styleTags: styleTags ?? this.styleTags,
      atmosphereScore: atmosphereScore ?? this.atmosphereScore,
      resonanceScore: resonanceScore ?? this.resonanceScore,
      shareScore: shareScore ?? this.shareScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SongReviewModel.fromRow(SongReviewsTableData row) {
    return SongReviewModel(
      id: row.id,
      songId: row.songId,
      author: row.author == 'partner' ? ReviewAuthor.partner : ReviewAuthor.me,
      content: row.content,
      styleTags: _decodeStyleTags(row.styleTags),
      atmosphereScore: row.atmosphereScore,
      resonanceScore: row.resonanceScore,
      shareScore: row.shareScore,
      createdAt: row.createdAt,
    );
  }

  factory SongReviewModel.fromCloudJson(Map<String, dynamic> json) {
    final singleScore = _toDouble(json['singleScore']);
    final encodedSingle =
        singleScore == null ? null : _encodeSingleScore(singleScore);
    return SongReviewModel(
      id: json['id'] as String,
      songId: json['songId'] as String,
      author: (json['author'] as String? ?? 'me') == 'partner'
          ? ReviewAuthor.partner
          : ReviewAuthor.me,
      content: json['content'] as String? ?? '',
      styleTags: (json['styleTags'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      atmosphereScore:
          encodedSingle ?? (json['atmosphereScore'] as num?)?.round() ?? 0,
      resonanceScore: encodedSingle == null
          ? (json['resonanceScore'] as num?)?.round() ?? 0
          : 0,
      shareScore:
          encodedSingle == null ? (json['shareScore'] as num?)?.round() ?? 0 : 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  SongReviewsTableCompanion toCompanion() {
    return SongReviewsTableCompanion.insert(
      id: id,
      songId: songId,
      author: author == ReviewAuthor.partner ? 'partner' : 'me',
      content: content,
      styleTags: Value<String>(_encodeStyleTags(styleTags)),
      atmosphereScore: Value<int>(atmosphereScore),
      resonanceScore: Value<int>(resonanceScore),
      shareScore: Value<int>(shareScore),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toCloudJson({
    required String coupleId,
    required String currentUserId,
  }) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'songId': songId,
      'content': content,
      'styleTags': styleTags,
      'atmosphereScore': atmosphereScore,
      'resonanceScore': resonanceScore,
      'shareScore': shareScore,
      'singleScore': singleScore,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  static int _encodeSingleScore(double score) {
    final normalized = score.clamp(-15.0, 15.0);
    return (normalized * 10).round();
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static String _encodeStyleTags(List<String> tags) => jsonEncode(tags);

  static List<String> _decodeStyleTags(String raw) {
    if (raw.trim().isEmpty) {
      return const <String>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      return const <String>[];
    }
    return const <String>[];
  }
}

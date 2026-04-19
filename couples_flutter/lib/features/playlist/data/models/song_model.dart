import '../../domain/entities/song.dart';
import '../../../../core/storage/drift/app_database.dart';

class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.name,
    required super.artist,
    required super.createdAt,
    required super.preference,
  });

  SongModel copyWith({
    String? id,
    String? name,
    String? artist,
    DateTime? createdAt,
    SongPreference? preference,
  }) {
    return SongModel(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      createdAt: createdAt ?? this.createdAt,
      preference: preference ?? this.preference,
    );
  }

  factory SongModel.fromRow(SongsTableData row) {
    return SongModel(
      id: row.id,
      name: row.name,
      artist: row.artist,
      createdAt: row.createdAt,
      preference: _preferenceFromRaw(row.preference),
    );
  }

  factory SongModel.fromCloudJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      preference: _preferenceFromRaw(json['preference'] as String? ?? 'none'),
    );
  }

  SongsTableCompanion toCompanion() {
    return SongsTableCompanion.insert(
      id: id,
      name: name,
      artist: artist,
      createdAt: createdAt,
      preference: _preferenceToRaw(preference),
    );
  }

  Map<String, dynamic> toCloudJson({required String coupleId}) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'name': name,
      'artist': artist,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'preference': _preferenceToRaw(preference),
    };
  }

  static SongPreference _preferenceFromRaw(String raw) {
    switch (raw) {
      case 'like':
        return SongPreference.like;
      case 'dislike':
        return SongPreference.dislike;
      default:
        return SongPreference.none;
    }
  }

  static String _preferenceToRaw(SongPreference value) {
    switch (value) {
      case SongPreference.like:
        return 'like';
      case SongPreference.dislike:
        return 'dislike';
      case SongPreference.none:
        return 'none';
    }
  }
}

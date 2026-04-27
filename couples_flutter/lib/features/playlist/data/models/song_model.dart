import '../../domain/entities/song.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.name,
    required super.artist,
    required super.createdAt,
    required super.preference,
    super.genre,
    super.recommender,
    super.updatedAt,
    super.isDeleted,
    super.pendingSync,
  });

  SongModel copyWith({
    String? id,
    String? name,
    String? artist,
    DateTime? createdAt,
    SongPreference? preference,
    String? genre,
    SongRecommender? recommender,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) {
    return SongModel(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      createdAt: createdAt ?? this.createdAt,
      preference: preference ?? this.preference,
      genre: genre ?? this.genre,
      recommender: recommender ?? this.recommender,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  factory SongModel.fromRow(SongsTableData row) {
    return SongModel(
      id: row.id,
      name: row.name,
      artist: row.artist,
      createdAt: row.createdAt,
      preference: _preferenceFromRaw(row.preference),
      genre: row.genre,
      recommender: _recommenderFromRaw(row.recommender),
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      pendingSync: row.pendingSync,
    );
  }

  factory SongModel.fromCloudJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
    final recommenderRaw = (json['recommender'] as String?)?.trim();
    return SongModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      createdAt: createdAt,
      preference: _preferenceFromRaw(json['preference'] as String? ?? 'none'),
      genre: json['genre'] as String? ?? '',
      recommender: _recommenderFromRaw(recommenderRaw ?? 'partner'),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          createdAt,
      isDeleted: json['isDeleted'] == true,
      pendingSync: false,
    );
  }

  SongsTableCompanion toCompanion() {
    return SongsTableCompanion.insert(
      id: id,
      name: name,
      artist: artist,
      createdAt: createdAt,
      preference: _preferenceToRaw(preference),
      genre: Value<String>(genre),
      recommender: Value<String>(_recommenderToRaw(recommender)),
      updatedAt: Value<DateTime>(updatedAt),
      isDeleted: Value<bool>(isDeleted),
      pendingSync: Value<bool>(pendingSync),
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
      'name': name,
      'artist': artist,
      'genre': genre,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'preference': _preferenceToRaw(preference),
      'isDeleted': isDeleted,
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

  static SongRecommender _recommenderFromRaw(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'me':
      case 'self':
        return SongRecommender.me;
      case 'partner':
      case 'ta':
      default:
        return SongRecommender.partner;
    }
  }

  static String _recommenderToRaw(SongRecommender value) {
    return value == SongRecommender.partner ? 'partner' : 'me';
  }
}

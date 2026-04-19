import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../models/song_model.dart';
import '../models/song_review_model.dart';

class PlaylistMockDataSource {
  PlaylistMockDataSource(this._db);

  final AppDatabase _db;

  Future<SongModel> addSong(String name, String artist) async {
    final trimmedName = name.trim();
    final trimmedArtist = artist.trim();
    if (trimmedName.isEmpty || trimmedArtist.isEmpty) {
      throw Exception('歌名和歌手不能为空');
    }

    final now = DateTime.now();
    final song = SongModel(
      id: 'song-${now.microsecondsSinceEpoch}',
      name: trimmedName,
      artist: trimmedArtist,
      createdAt: now,
      preference: SongPreference.none,
    );

    await _db
        .into(_db.songsTable)
        .insert(
          SongsTableCompanion.insert(
            id: song.id,
            name: song.name,
            artist: song.artist,
            createdAt: song.createdAt,
            preference: _preferenceToDbValue(song.preference),
          ),
        );

    return song;
  }

  Future<List<SongModel>> getSongs() async {
    final rows = await (_db.select(
      _db.songsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

    return rows
        .map(
          (row) => SongModel(
            id: row.id,
            name: row.name,
            artist: row.artist,
            createdAt: row.createdAt,
            preference: _preferenceFromDbValue(row.preference),
          ),
        )
        .toList();
  }

  Future<void> toggleSongPreference(String songId, SongPreference value) async {
    final song = await (_db.select(
      _db.songsTable,
    )..where((t) => t.id.equals(songId))).getSingleOrNull();
    if (song == null) {
      throw Exception('Song not found');
    }

    final current = _preferenceFromDbValue(song.preference);
    final next = current == value ? SongPreference.none : value;

    await (_db.update(_db.songsTable)..where((t) => t.id.equals(songId))).write(
      SongsTableCompanion(
        preference: Value<String>(_preferenceToDbValue(next)),
      ),
    );
  }

  Future<SongReviewModel> addOrUpdateReview(
    String songId,
    String content,
    List<String> styleTags,
    int atmosphereScore,
    int resonanceScore,
    int shareScore,
    ReviewAuthor author,
  ) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception('Review content is required');
    }
    final normalizedTags = _normalizeStyleTags(styleTags);

    final song = await (_db.select(
      _db.songsTable,
    )..where((t) => t.id.equals(songId))).getSingleOrNull();
    if (song == null) {
      throw Exception('Song not found');
    }

    final now = DateTime.now();

    if (author == ReviewAuthor.me) {
      final existing =
          await (_db.select(_db.songReviewsTable)
                ..where((t) => t.songId.equals(songId) & t.author.equals('me'))
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
              .getSingleOrNull();

      if (existing != null) {
        await (_db.update(
          _db.songReviewsTable,
        )..where((t) => t.id.equals(existing.id))).write(
          SongReviewsTableCompanion(
            content: Value<String>(trimmedContent),
            styleTags: Value<String>(_encodeStyleTags(normalizedTags)),
            atmosphereScore: Value<int>(atmosphereScore),
            resonanceScore: Value<int>(resonanceScore),
            shareScore: Value<int>(shareScore),
            createdAt: Value<DateTime>(now),
          ),
        );

        return SongReviewModel(
          id: existing.id,
          songId: existing.songId,
          author: ReviewAuthor.me,
          content: trimmedContent,
          styleTags: normalizedTags,
          atmosphereScore: atmosphereScore,
          resonanceScore: resonanceScore,
          shareScore: shareScore,
          createdAt: now,
        );
      }
    }

    final review = SongReviewModel(
      id: 'review-${now.microsecondsSinceEpoch}',
      songId: songId,
      author: author,
      content: trimmedContent,
      styleTags: normalizedTags,
      atmosphereScore: atmosphereScore,
      resonanceScore: resonanceScore,
      shareScore: shareScore,
      createdAt: now,
    );

    await _db
        .into(_db.songReviewsTable)
        .insert(
          SongReviewsTableCompanion.insert(
            id: review.id,
            songId: review.songId,
            author: _authorToDbValue(review.author),
            content: review.content,
            styleTags: Value<String>(_encodeStyleTags(review.styleTags)),
            atmosphereScore: Value<int>(review.atmosphereScore),
            resonanceScore: Value<int>(review.resonanceScore),
            shareScore: Value<int>(review.shareScore),
            createdAt: review.createdAt,
          ),
        );

    return review;
  }

  Future<List<SongReviewModel>> getReviews(String songId) async {
    final rows =
        await (_db.select(_db.songReviewsTable)
              ..where((t) => t.songId.equals(songId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return rows
        .map(
          (row) => SongReviewModel(
            id: row.id,
            songId: row.songId,
            author: _authorFromDbValue(row.author),
            content: row.content,
            styleTags: _decodeStyleTags(row.styleTags),
            atmosphereScore: row.atmosphereScore,
            resonanceScore: row.resonanceScore,
            shareScore: row.shareScore,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  String _preferenceToDbValue(SongPreference value) {
    switch (value) {
      case SongPreference.like:
        return 'like';
      case SongPreference.dislike:
        return 'dislike';
      case SongPreference.none:
        return 'none';
    }
  }

  SongPreference _preferenceFromDbValue(String value) {
    switch (value) {
      case 'like':
        return SongPreference.like;
      case 'dislike':
        return SongPreference.dislike;
      default:
        return SongPreference.none;
    }
  }

  String _authorToDbValue(ReviewAuthor value) {
    return value == ReviewAuthor.me ? 'me' : 'partner';
  }

  ReviewAuthor _authorFromDbValue(String value) {
    return value == 'partner' ? ReviewAuthor.partner : ReviewAuthor.me;
  }

  List<String> _normalizeStyleTags(List<String> styleTags) {
    final normalized = <String>[];
    for (final rawTag in styleTags) {
      final trimmed = rawTag.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (normalized.any(
        (existing) => existing.toLowerCase() == trimmed.toLowerCase(),
      )) {
        continue;
      }
      normalized.add(trimmed);
    }
    return normalized;
  }

  String _encodeStyleTags(List<String> tags) {
    return jsonEncode(tags);
  }

  List<String> _decodeStyleTags(String raw) {
    if (raw.trim().isEmpty) {
      return const <String>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }
    } catch (_) {
      return raw
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}


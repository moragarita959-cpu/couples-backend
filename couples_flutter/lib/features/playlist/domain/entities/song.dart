enum SongPreference {
  none,
  like,
  dislike,
}

enum SongRecommender {
  me,
  partner,
}

class Song {
  const Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.createdAt,
    required this.preference,
    this.genre = '',
    this.recommender = SongRecommender.me,
    DateTime? updatedAt,
    this.isDeleted = false,
    this.pendingSync = false,
  }) : updatedAt = updatedAt ?? createdAt;

  final String id;
  final String name;
  final String artist;
  final DateTime createdAt;
  final SongPreference preference;
  final String genre;
  final SongRecommender recommender;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;
}

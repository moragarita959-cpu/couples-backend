enum SongPreference {
  none,
  like,
  dislike,
}

class Song {
  const Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.createdAt,
    required this.preference,
  });

  final String id;
  final String name;
  final String artist;
  final DateTime createdAt;
  final SongPreference preference;
}

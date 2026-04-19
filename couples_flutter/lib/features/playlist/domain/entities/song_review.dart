enum ReviewAuthor { me, partner }

class SongReview {
  const SongReview({
    required this.id,
    required this.songId,
    required this.author,
    required this.content,
    required this.styleTags,
    required this.atmosphereScore,
    required this.resonanceScore,
    required this.shareScore,
    required this.createdAt,
  });

  final String id;
  final String songId;
  final ReviewAuthor author;
  final String content;
  final List<String> styleTags;
  final int atmosphereScore;
  final int resonanceScore;
  final int shareScore;
  final DateTime createdAt;

  int get totalScore => atmosphereScore + resonanceScore + shareScore;
}

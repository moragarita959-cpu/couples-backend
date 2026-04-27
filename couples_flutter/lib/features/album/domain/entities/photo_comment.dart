class PhotoComment {
  const PhotoComment({
    required this.id,
    required this.photoId,
    required this.coupleId,
    required this.authorUserId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String photoId;
  final String coupleId;
  final String authorUserId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool authoredBy(String? userId) => userId != null && authorUserId == userId;
}

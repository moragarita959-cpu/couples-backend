class ThoughtComment {
  const ThoughtComment({
    required this.id,
    required this.coupleId,
    required this.targetType,
    required this.targetId,
    required this.authorUserId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String targetTypeIdea = 'idea';
  static const String targetTypeExcerpt = 'excerpt';

  final String id;
  final String coupleId;
  final String targetType;
  final String targetId;
  final String authorUserId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool authoredBy(String? userId) => userId != null && authorUserId == userId;
}

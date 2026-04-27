class Album {
  const Album({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.description,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.coverPhotoUrl,
    this.coverLocalPath,
    this.photoCount = 0,
    this.lastPhotoAt,
  });

  final String id;
  final String coupleId;
  final String title;
  final String description;
  final String? coverPhotoUrl;
  final String? coverLocalPath;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int photoCount;
  final DateTime? lastPhotoAt;

  bool createdBy(String? userId) => userId != null && createdByUserId == userId;
}

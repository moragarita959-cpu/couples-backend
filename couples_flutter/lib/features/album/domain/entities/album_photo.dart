class AlbumPhoto {
  const AlbumPhoto({
    required this.id,
    required this.albumId,
    required this.coupleId,
    required this.uploaderUserId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.localPath,
    this.caption = '',
    this.takenAt,
    this.commentCount = 0,
    this.albumTitle,
  });

  final String id;
  final String albumId;
  final String coupleId;
  final String uploaderUserId;
  final String? imageUrl;
  final String? localPath;
  final String caption;
  final DateTime? takenAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;
  final String? albumTitle;

  bool uploadedBy(String? userId) => userId != null && uploaderUserId == userId;
}

import '../../domain/entities/album_photo.dart';
import '../../domain/entities/photo_comment.dart';

class PhotoDetailState {
  const PhotoDetailState({
    this.photo,
    this.comments = const <PhotoComment>[],
    this.isLoading = true,
    this.isSendingComment = false,
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final AlbumPhoto? photo;
  final List<PhotoComment> comments;
  final bool isLoading;
  final bool isSendingComment;
  final String? errorMessage;
  final String? cloudSyncMessage;

  PhotoDetailState copyWith({
    Object? photo = _noChange,
    List<PhotoComment>? comments,
    bool? isLoading,
    bool? isSendingComment,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return PhotoDetailState(
      photo: identical(photo, _noChange) ? this.photo : photo as AlbumPhoto?,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSendingComment: isSendingComment ?? this.isSendingComment,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

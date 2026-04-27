import '../../domain/entities/album.dart';
import '../../domain/entities/album_photo.dart';

class AlbumDetailState {
  const AlbumDetailState({
    this.album,
    this.photos = const <AlbumPhoto>[],
    this.isLoading = true,
    this.isPickingPhotos = false,
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final Album? album;
  final List<AlbumPhoto> photos;
  final bool isLoading;
  final bool isPickingPhotos;
  final String? errorMessage;
  final String? cloudSyncMessage;

  AlbumDetailState copyWith({
    Object? album = _noChange,
    List<AlbumPhoto>? photos,
    bool? isLoading,
    bool? isPickingPhotos,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return AlbumDetailState(
      album: identical(album, _noChange) ? this.album : album as Album?,
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isPickingPhotos: isPickingPhotos ?? this.isPickingPhotos,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

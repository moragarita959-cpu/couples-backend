import '../../domain/entities/album.dart';

class AlbumState {
  const AlbumState({
    this.albums = const <Album>[],
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final List<Album> albums;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  /// 云端未同步但已保留本地时的一次性提示。
  final String? cloudSyncMessage;

  int get totalAlbums => albums.length;

  int get totalPhotos =>
      albums.fold<int>(0, (sum, album) => sum + album.photoCount);

  DateTime? get lastUpdatedAt {
    if (albums.isEmpty) {
      return null;
    }
    final sorted = [...albums]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.first.updatedAt;
  }

  AlbumState copyWith({
    List<Album>? albums,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return AlbumState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

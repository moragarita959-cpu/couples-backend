import '../entities/album.dart';
import '../entities/album_photo.dart';
import '../entities/photo_comment.dart';

abstract class AlbumRepository {
  Stream<List<Album>> watchAlbums(String coupleId);
  Stream<Album?> watchAlbum(String albumId);
  Future<List<Album>> refreshAlbums();
  Future<Album> saveAlbum(Album album);
  Future<void> deleteAlbum(String albumId);

  Stream<List<AlbumPhoto>> watchPhotos(String albumId);
  Stream<AlbumPhoto?> watchPhoto(String photoId);
  Future<List<AlbumPhoto>> refreshPhotos(String albumId);
  Future<AlbumPhoto> savePhoto(AlbumPhoto photo);
  Future<void> deletePhoto(String photoId);

  Stream<List<PhotoComment>> watchComments(String photoId);
  Future<List<PhotoComment>> refreshComments(String photoId);
  Future<PhotoComment> saveComment(PhotoComment comment);
  Future<void> deleteComment(String commentId);

  Future<String> importPhotoToLocalStorage({
    required String albumId,
    required String sourcePath,
  });

  /// 最近一次写操作若云端失败则返回提示（一次性取走，便于在 UI 展示“已存本地”）。
  String? takeCloudSyncWarning();
}

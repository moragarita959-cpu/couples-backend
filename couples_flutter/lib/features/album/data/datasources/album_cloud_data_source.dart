import '../../../../core/network/api_client.dart';
import '../models/album_model.dart';
import '../models/album_photo_model.dart';
import '../models/photo_comment_model.dart';

class AlbumCloudDataSource {
  const AlbumCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  bool get isEnabled => _apiClient.usesHttpBackend;

  Future<List<AlbumModel>> fetchAlbums({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listAlbums(
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    return payload.map(AlbumModel.fromCloudJson).toList();
  }

  Future<AlbumModel> createAlbum({
    required String coupleId,
    required String currentUserId,
    required AlbumModel model,
  }) async {
    final payload = await _apiClient.createAlbum(
      <String, dynamic>{
        'coupleId': coupleId,
        'currentUserId': currentUserId,
        'title': model.title,
        'description': model.description,
        if (model.id.isNotEmpty) 'id': model.id,
      },
    );
    return AlbumModel.fromCloudJson(payload);
  }

  Future<AlbumModel> updateAlbum({
    required String coupleId,
    required String currentUserId,
    required AlbumModel model,
  }) async {
    final payload = await _apiClient.updateAlbum(
      <String, dynamic>{
        'coupleId': coupleId,
        'currentUserId': currentUserId,
        'albumId': model.id,
        'title': model.title,
        'description': model.description,
      },
    );
    return AlbumModel.fromCloudJson(payload);
  }

  Future<void> deleteAlbum({
    required String coupleId,
    required String currentUserId,
    required String albumId,
  }) {
    return _apiClient.deleteAlbum(
      coupleId: coupleId,
      currentUserId: currentUserId,
      albumId: albumId,
    );
  }

  Future<List<AlbumPhotoModel>> fetchPhotos({
    required String albumId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listAlbumPhotos(
      albumId: albumId,
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    return payload.map(AlbumPhotoModel.fromCloudJson).toList();
  }

  Future<AlbumPhotoModel> uploadPhoto({
    required String currentUserId,
    required AlbumPhotoModel model,
  }) async {
    final localPath = model.localPath;
    if (localPath == null || localPath.isEmpty) {
      throw const ApiClientException('invalid_request');
    }
    final payload = await _apiClient.uploadAlbumPhoto(
      coupleId: model.coupleId,
      albumId: model.albumId,
      currentUserId: currentUserId,
      sourcePath: localPath,
      caption: model.caption,
      localPath: localPath,
      id: model.id,
    );
    return AlbumPhotoModel.fromCloudJson(payload);
  }

  Future<AlbumPhotoModel> updatePhoto({
    required String currentUserId,
    required AlbumPhotoModel model,
  }) async {
    final payload = await _apiClient.updateAlbumPhoto(
      <String, dynamic>{
        'coupleId': model.coupleId,
        'currentUserId': currentUserId,
        'photoId': model.id,
        'caption': model.caption,
      },
    );
    return AlbumPhotoModel.fromCloudJson(payload);
  }

  Future<void> deletePhoto({
    required String coupleId,
    required String currentUserId,
    required String photoId,
  }) {
    return _apiClient.deleteAlbumPhoto(
      coupleId: coupleId,
      currentUserId: currentUserId,
      photoId: photoId,
    );
  }

  Future<List<PhotoCommentModel>> fetchComments({
    required String photoId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _apiClient.listPhotoComments(
      photoId: photoId,
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    return payload.map(PhotoCommentModel.fromCloudJson).toList();
  }

  Future<PhotoCommentModel> createComment({
    required String coupleId,
    required String currentUserId,
    required PhotoCommentModel model,
  }) async {
    final payload = await _apiClient.createPhotoComment(
      <String, dynamic>{
        'coupleId': coupleId,
        'currentUserId': currentUserId,
        'photoId': model.photoId,
        'content': model.content,
      },
    );
    return PhotoCommentModel.fromCloudJson(payload);
  }

  Future<void> deleteComment({
    required String coupleId,
    required String currentUserId,
    required String commentId,
  }) {
    return _apiClient.deletePhotoComment(
      coupleId: coupleId,
      currentUserId: currentUserId,
      commentId: commentId,
    );
  }
}

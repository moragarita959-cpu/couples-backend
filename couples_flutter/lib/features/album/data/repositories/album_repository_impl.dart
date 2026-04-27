import '../../../../core/network/api_client.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/album_photo.dart';
import '../../domain/entities/photo_comment.dart';
import '../../domain/repositories/album_repository.dart';
import '../datasources/album_cloud_data_source.dart';
import '../datasources/album_local_data_source.dart';
import '../datasources/album_media_store.dart';
import '../models/album_model.dart';
import '../models/album_photo_model.dart';
import '../models/photo_comment_model.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  AlbumRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource,
    this._mediaStore, {
    required String? Function() resolveCoupleId,
    required String? Function() resolveCurrentUserId,
  }) : _resolveCoupleId = resolveCoupleId,
       _resolveCurrentUserId = resolveCurrentUserId;

  static const _cloudFailedLocalKept = '云同步失败，已保存在本地';

  final AlbumLocalDataSource _localDataSource;
  final AlbumCloudDataSource _cloudDataSource;
  final AlbumMediaStore _mediaStore;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;

  String? _pendingCloudSyncWarning;

  @override
  String? takeCloudSyncWarning() {
    final out = _pendingCloudSyncWarning;
    _pendingCloudSyncWarning = null;
    return out;
  }

  @override
  Stream<List<Album>> watchAlbums(String coupleId) {
    return _localDataSource.watchAlbums(coupleId);
  }

  @override
  Stream<Album?> watchAlbum(String albumId) {
    return _localDataSource.watchAlbum(albumId);
  }

  @override
  Future<List<Album>> refreshAlbums() async {
    final identity = _resolveIdentity();
    if (identity == null) {
      return watchAlbumsSnapshot();
    }

    try {
      final remoteAlbums = await _cloudDataSource.fetchAlbums(
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
      );
      for (final album in remoteAlbums) {
        await _localDataSource.upsertAlbum(AlbumModel.fromEntity(album));
        await _refreshPhotosInternal(
          albumId: album.id,
          coupleId: identity.coupleId,
          currentUserId: identity.currentUserId,
        );
      }
    } catch (error) {
      _setCloudFailedWarning(error);
    }

    return watchAlbumsSnapshot();
  }

  @override
  Future<Album> saveAlbum(Album album) async {
    final model = AlbumModel.fromEntity(album);
    final localSaved = await _localDataSource.upsertAlbum(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _syncAlbum(model, identity.currentUserId);
      return await _localDataSource.upsertAlbum(remoteSaved);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    final album = await _localDataSource.getAlbum(albumId);
    final identity = _resolveIdentity(coupleId: album?.coupleId);
    if (identity == null || album == null) {
      await _localDataSource.deleteAlbum(albumId);
      return;
    }
    try {
      await _cloudDataSource.deleteAlbum(
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
        albumId: albumId,
      );
      await _localDataSource.deleteAlbum(albumId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (_isDeleteIdempotentCode(code)) {
        await _localDataSource.deleteAlbum(albumId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('album_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  Stream<List<AlbumPhoto>> watchPhotos(String albumId) {
    return _localDataSource.watchPhotos(albumId);
  }

  @override
  Stream<AlbumPhoto?> watchPhoto(String photoId) {
    return _localDataSource.watchPhoto(photoId);
  }

  @override
  Future<List<AlbumPhoto>> refreshPhotos(String albumId) async {
    final album = await _localDataSource.getAlbum(albumId);
    final identity = _resolveIdentity(coupleId: album?.coupleId);
    if (identity == null) {
      return watchPhotosSnapshot(albumId);
    }

    try {
      await _refreshPhotosInternal(
        albumId: albumId,
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
      );
    } catch (error) {
      _setCloudFailedWarning(error);
    }

    return watchPhotosSnapshot(albumId);
  }

  @override
  Future<AlbumPhoto> savePhoto(AlbumPhoto photo) async {
    final model = AlbumPhotoModel.fromEntity(photo);
    final localSaved = await _localDataSource.upsertPhoto(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _syncPhoto(model, identity.currentUserId);
      final merged = AlbumPhotoModel(
        id: remoteSaved.id,
        albumId: remoteSaved.albumId,
        coupleId: remoteSaved.coupleId,
        uploaderUserId: remoteSaved.uploaderUserId,
        imageUrl: (remoteSaved.imageUrl ?? '').trim().isNotEmpty
            ? remoteSaved.imageUrl
            : model.imageUrl,
        localPath: model.localPath ?? remoteSaved.localPath,
        caption: remoteSaved.caption,
        takenAt: remoteSaved.takenAt,
        createdAt: remoteSaved.createdAt,
        updatedAt: remoteSaved.updatedAt,
        commentCount: remoteSaved.commentCount,
        albumTitle: remoteSaved.albumTitle,
      );
      return await _localDataSource.upsertPhoto(merged);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    final photo = await _localDataSource.getPhoto(photoId);
    final identity = _resolveIdentity(coupleId: photo?.coupleId);
    if (identity == null || photo == null) {
      await _localDataSource.deletePhoto(photoId);
      return;
    }
    try {
      await _cloudDataSource.deletePhoto(
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
        photoId: photoId,
      );
      await _localDataSource.deletePhoto(photoId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (_isDeleteIdempotentCode(code)) {
        await _localDataSource.deletePhoto(photoId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('photo_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  Stream<List<PhotoComment>> watchComments(String photoId) {
    return _localDataSource.watchComments(photoId);
  }

  @override
  Future<List<PhotoComment>> refreshComments(String photoId) async {
    final photo = await _localDataSource.getPhoto(photoId);
    final identity = _resolveIdentity(coupleId: photo?.coupleId);
    if (identity == null) {
      return watchCommentsSnapshot(photoId);
    }

    try {
      final comments = await _cloudDataSource.fetchComments(
        photoId: photoId,
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
      );
      await _localDataSource.replaceComments(photoId, comments);
    } catch (error) {
      _setCloudFailedWarning(error);
    }

    return watchCommentsSnapshot(photoId);
  }

  @override
  Future<PhotoComment> saveComment(PhotoComment comment) async {
    final model = PhotoCommentModel.fromEntity(comment);
    final localSaved = await _localDataSource.upsertComment(model);
    final identity = _resolveIdentity(coupleId: model.coupleId);
    if (identity == null) {
      return localSaved;
    }

    try {
      final remoteSaved = await _cloudDataSource.createComment(
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
        model: model,
      );
      return await _localDataSource.upsertComment(remoteSaved);
    } catch (error) {
      _setCloudFailedWarning(error);
      return localSaved;
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final comment = await _localDataSource.getComment(commentId);
    final identity = _resolveIdentity(coupleId: comment?.coupleId);
    if (identity == null || comment == null) {
      await _localDataSource.deleteComment(commentId);
      return;
    }
    try {
      await _cloudDataSource.deleteComment(
        coupleId: identity.coupleId,
        currentUserId: identity.currentUserId,
        commentId: commentId,
      );
      await _localDataSource.deleteComment(commentId);
    } catch (error) {
      final code = _extractErrorCode(error);
      if (_isDeleteIdempotentCode(code)) {
        await _localDataSource.deleteComment(commentId);
        return;
      }
      _setCloudFailedWarning(error);
      throw StateError('comment_delete_cloud_failed:${code ?? error}');
    }
  }

  @override
  Future<String> importPhotoToLocalStorage({
    required String albumId,
    required String sourcePath,
  }) {
    return _mediaStore.importPhoto(albumId: albumId, sourcePath: sourcePath);
  }

  Future<List<Album>> watchAlbumsSnapshot() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return const <Album>[];
    }
    return _localDataSource.watchAlbums(coupleId).first;
  }

  Future<List<AlbumPhoto>> watchPhotosSnapshot(String albumId) {
    return _localDataSource.watchPhotos(albumId).first;
  }

  Future<List<PhotoComment>> watchCommentsSnapshot(String photoId) {
    return _localDataSource.watchComments(photoId).first;
  }

  Future<AlbumModel> _syncAlbum(AlbumModel album, String currentUserId) async {
    try {
      return await _cloudDataSource.createAlbum(
        coupleId: album.coupleId,
        currentUserId: currentUserId,
        model: album,
      );
    } catch (error) {
      final code = _extractErrorCode(error);
      if (!_isAlreadyExistsCode(code)) {
        rethrow;
      }
    }
    return _cloudDataSource.updateAlbum(
      coupleId: album.coupleId,
      currentUserId: currentUserId,
      model: album,
    );
  }

  Future<void> _refreshPhotosInternal({
    required String albumId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final photos = await _cloudDataSource.fetchPhotos(
      albumId: albumId,
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    await _localDataSource.replacePhotos(albumId, photos);
    for (final photo in photos) {
      await _refreshCommentsInternal(
        photoId: photo.id,
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
    }
  }

  Future<void> _refreshCommentsInternal({
    required String photoId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final comments = await _cloudDataSource.fetchComments(
      photoId: photoId,
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
    await _localDataSource.replaceComments(photoId, comments);
  }

  Future<AlbumPhotoModel> _syncPhoto(
    AlbumPhotoModel photo,
    String currentUserId,
  ) {
    if (photo.localPath != null && photo.localPath!.isNotEmpty) {
      return _cloudDataSource.uploadPhoto(
        model: photo,
        currentUserId: currentUserId,
      );
    }
    return _cloudDataSource.updatePhoto(
      model: photo,
      currentUserId: currentUserId,
    );
  }

  _AlbumIdentity? _resolveIdentity({String? coupleId}) {
    if (!_cloudDataSource.isEnabled) {
      return null;
    }
    final resolvedCoupleId = coupleId ?? _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (resolvedCoupleId == null ||
        resolvedCoupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return null;
    }
    return _AlbumIdentity(resolvedCoupleId, currentUserId);
  }

  void _setCloudFailedWarning([Object? error]) {
    final code = error == null ? null : _extractErrorCode(error);
    if (code == null || code.isEmpty) {
      _pendingCloudSyncWarning = _cloudFailedLocalKept;
      return;
    }
    if (code == 'route_not_found' || code == 'album_upload_route_missing') {
      _pendingCloudSyncWarning = '云同步失败：服务器相册接口地址未配置正确';
      return;
    }
    _pendingCloudSyncWarning = '$_cloudFailedLocalKept（$code）';
  }

  String? _extractErrorCode(Object error) {
    if (error is ApiClientException) {
      return _normalizeCode(error.code);
    }
    if (error is StateError) {
      return _normalizeCode(error.message);
    }
    return _normalizeCode(error.toString());
  }

  bool _isAlreadyExistsCode(String? code) {
    return code == 'album_already_exists' ||
        code == 'duplicate_album' ||
        code == 'already_exists';
  }

  bool _isDeleteIdempotentCode(String? code) {
    return code == 'album_not_found' ||
        code == 'photo_not_found' ||
        code == 'comment_not_found';
  }

  String? _normalizeCode(String? raw) {
    if (raw == null) {
      return null;
    }
    var value = raw.trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.startsWith('{') && value.endsWith('}')) {
      final normalized = value.replaceAll(RegExp(r'\s+'), '');
      final codeMatch = RegExp(r'"code":"([^"]+)"').firstMatch(normalized);
      if (codeMatch != null) {
        return codeMatch.group(1);
      }
      final errorMatch = RegExp(r'"error":"([^"]+)"').firstMatch(normalized);
      if (errorMatch != null) {
        return errorMatch.group(1);
      }
    }
    value = value
        .replaceFirst('Exception: ', '')
        .replaceFirst('StateError: ', '')
        .trim();
    final splitByColon = value.split(':');
    value = splitByColon.last.trim();
    if (value.startsWith('{') && value.endsWith('}')) {
      return 'http_error';
    }
    return value.isEmpty ? null : value;
  }
}

class _AlbumIdentity {
  const _AlbumIdentity(this.coupleId, this.currentUserId);

  final String coupleId;
  final String currentUserId;
}

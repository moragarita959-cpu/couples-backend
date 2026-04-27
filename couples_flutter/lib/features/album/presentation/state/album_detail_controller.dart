import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/album.dart';
import '../../domain/entities/album_photo.dart';
import '../../domain/usecases/delete_album.dart';
import '../../domain/usecases/delete_photo.dart';
import '../../domain/usecases/import_local_photo.dart';
import '../../domain/usecases/refresh_photos.dart';
import '../../domain/usecases/save_photo.dart';
import '../../domain/usecases/watch_album.dart';
import '../../domain/usecases/watch_photos.dart';
import 'album_detail_state.dart';

class AlbumDetailController extends StateNotifier<AlbumDetailState> {
  AlbumDetailController(
    this.albumId,
    this._watchAlbum,
    this._watchPhotos,
    this._refreshPhotos,
    this._savePhoto,
    this._deletePhoto,
    this._deleteAlbum,
    this._importLocalPhoto,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._takeCloudSyncWarning,
  ) : super(const AlbumDetailState()) {
    _bind();
    unawaited(refreshPhotos());
  }

  final String albumId;
  final WatchAlbum _watchAlbum;
  final WatchPhotos _watchPhotos;
  final RefreshPhotos _refreshPhotos;
  final SavePhoto _savePhoto;
  final DeletePhoto _deletePhoto;
  final DeleteAlbum _deleteAlbum;
  final ImportLocalPhoto _importLocalPhoto;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _takeCloudSyncWarning;

  StreamSubscription<Album?>? _albumSubscription;
  StreamSubscription<List<AlbumPhoto>>? _photoSubscription;

  void _bind() {
    state = state.copyWith(isLoading: true, errorMessage: null);

    _albumSubscription = _watchAlbum(albumId).listen(
      (album) {
        state = state.copyWith(
          album: album,
          isLoading: false,
          errorMessage: album == null ? '这个相册不存在了。' : null,
        );
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '相册详情加载失败。');
      },
    );

    _photoSubscription = _watchPhotos(albumId).listen(
      (photos) {
        state = state.copyWith(photos: photos, isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '照片列表加载失败。');
      },
    );
  }

  Future<void> refreshPhotos() async {
    try {
      await _refreshPhotos(albumId);
    } catch (_) {}
  }

  Future<bool> addPhotos(
    List<String> sourcePaths, {
    String caption = '',
  }) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先完成情侣绑定。');
      return false;
    }
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录后再添加照片。');
      return false;
    }
    if (sourcePaths.isEmpty) {
      return false;
    }

    state = state.copyWith(isPickingPhotos: true, errorMessage: null);
    try {
      for (final sourcePath in sourcePaths) {
        final importedPath = await _importLocalPhoto(
          albumId: albumId,
          sourcePath: sourcePath,
        );
        final now = DateTime.now();
        await _savePhoto(
          AlbumPhoto(
            id: 'photo-${now.microsecondsSinceEpoch}',
            albumId: albumId,
            coupleId: coupleId,
            uploaderUserId: currentUserId,
            localPath: importedPath,
            caption: caption.trim(),
            takenAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await refreshPhotos();
      final w = _takeCloudSyncWarning();
      state = state.copyWith(
        isPickingPhotos: false,
        errorMessage: null,
        cloudSyncMessage: w,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isPickingPhotos: false,
        errorMessage: '添加照片失败，请稍后重试。',
      );
      return false;
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    try {
      await _deletePhoto(photoId);
      await refreshPhotos();
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: null);
      return w == null;
    } catch (_) {
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: w ?? '删除照片失败。');
      return false;
    }
  }

  Future<bool> deleteAlbum() async {
    try {
      await _deleteAlbum(albumId);
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: null);
      return w == null;
    } catch (_) {
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: w ?? '删除相册失败。');
      return false;
    }
  }

  @override
  void dispose() {
    _albumSubscription?.cancel();
    _photoSubscription?.cancel();
    super.dispose();
  }
}

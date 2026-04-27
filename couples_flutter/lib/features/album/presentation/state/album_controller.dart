import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/album.dart';
import '../../domain/usecases/delete_album.dart';
import '../../domain/usecases/refresh_albums.dart';
import '../../domain/usecases/save_album.dart';
import '../../domain/usecases/watch_albums.dart';
import 'album_state.dart';

class AlbumController extends StateNotifier<AlbumState> {
  AlbumController(
    this._watchAlbums,
    this._refreshAlbums,
    this._saveAlbum,
    this._deleteAlbum,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._takeCloudSyncWarning,
  ) : super(const AlbumState()) {
    _bind();
    unawaited(refreshAlbums());
  }

  final WatchAlbums _watchAlbums;
  final RefreshAlbums _refreshAlbums;
  final SaveAlbum _saveAlbum;
  final DeleteAlbum _deleteAlbum;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _takeCloudSyncWarning;

  StreamSubscription<List<Album>>? _subscription;

  void _bind() {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(
        albums: const <Album>[],
        isLoading: false,
        errorMessage: '请先完成情侣绑定，再创建相册。',
      );
      return;
    }

    _subscription?.cancel();
    state = state.copyWith(isLoading: true, errorMessage: null);
    _subscription = _watchAlbums(coupleId).listen(
      (albums) {
        state = state.copyWith(
          albums: albums,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '相册加载失败，请稍后重试。');
      },
    );
  }

  Future<void> refreshAlbums() async {
    try {
      await _refreshAlbums();
    } catch (_) {}
  }

  Future<bool> saveAlbum({
    String? albumId,
    required String title,
    required String description,
  }) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    final trimmedTitle = title.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先完成情侣绑定。');
      return false;
    }
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录后再操作相册。');
      return false;
    }
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(errorMessage: '请输入相册名称。');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);
    final now = DateTime.now();
    final existing = albumId == null
        ? null
        : state.albums.cast<Album?>().firstWhere(
            (album) => album?.id == albumId,
            orElse: () => null,
          );

    final draft = Album(
      id: existing?.id ?? 'album-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      title: trimmedTitle,
      description: description.trim(),
      coverPhotoUrl: existing?.coverPhotoUrl,
      coverLocalPath: existing?.coverLocalPath,
      createdByUserId: existing?.createdByUserId ?? currentUserId,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      photoCount: existing?.photoCount ?? 0,
      lastPhotoAt: existing?.lastPhotoAt,
    );

    try {
      await _saveAlbum(draft);
      final w = _takeCloudSyncWarning();
      state = state.copyWith(
        isSaving: false,
        errorMessage: null,
        cloudSyncMessage: w,
      );
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: '保存相册失败，请稍后再试。');
      return false;
    }
  }

  Future<bool> deleteAlbum(String albumId) async {
    try {
      await _deleteAlbum(albumId);
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: null);
      return w == null;
    } catch (_) {
      final w = _takeCloudSyncWarning();
      state = state.copyWith(
        cloudSyncMessage: w,
        errorMessage: w ?? '删除相册失败，请稍后重试。',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

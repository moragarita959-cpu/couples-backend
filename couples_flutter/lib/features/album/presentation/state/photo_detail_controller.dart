import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/album_photo.dart';
import '../../domain/entities/photo_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/delete_photo.dart';
import '../../domain/usecases/refresh_comments.dart';
import '../../domain/usecases/save_comment.dart';
import '../../domain/usecases/watch_comments.dart';
import '../../domain/usecases/watch_photo.dart';
import 'photo_detail_state.dart';

class PhotoDetailController extends StateNotifier<PhotoDetailState> {
  PhotoDetailController(
    this.photoId,
    this._watchPhoto,
    this._watchComments,
    this._refreshComments,
    this._saveComment,
    this._deleteComment,
    this._deletePhoto,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._takeCloudSyncWarning,
  ) : super(const PhotoDetailState()) {
    _bind();
    unawaited(refreshComments());
  }

  final String photoId;
  final WatchPhoto _watchPhoto;
  final WatchComments _watchComments;
  final RefreshComments _refreshComments;
  final SaveComment _saveComment;
  final DeleteComment _deleteComment;
  final DeletePhoto _deletePhoto;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _takeCloudSyncWarning;

  StreamSubscription<AlbumPhoto?>? _photoSubscription;
  StreamSubscription<List<PhotoComment>>? _commentSubscription;

  void _bind() {
    state = state.copyWith(isLoading: true, errorMessage: null);
    _photoSubscription = _watchPhoto(photoId).listen(
      (photo) {
        state = state.copyWith(
          photo: photo,
          isLoading: false,
          errorMessage: photo == null ? '这张照片不存在了。' : null,
        );
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '照片详情加载失败。');
      },
    );
    _commentSubscription = _watchComments(photoId).listen(
      (comments) {
        state = state.copyWith(comments: comments, isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '评论加载失败。');
      },
    );
  }

  Future<void> refreshComments() async {
    try {
      await _refreshComments(photoId);
    } catch (_) {}
  }

  Future<bool> addComment(String content) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    final trimmed = content.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先完成情侣绑定。');
      return false;
    }
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录后再评论。');
      return false;
    }
    if (trimmed.isEmpty) {
      return false;
    }

    state = state.copyWith(isSendingComment: true, errorMessage: null);
    try {
      final now = DateTime.now();
      await _saveComment(
        PhotoComment(
          id: 'comment-${now.microsecondsSinceEpoch}',
          photoId: photoId,
          coupleId: coupleId,
          authorUserId: currentUserId,
          content: trimmed,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await refreshComments();
      final w = _takeCloudSyncWarning();
      state = state.copyWith(
        isSendingComment: false,
        errorMessage: null,
        cloudSyncMessage: w,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSendingComment: false,
        errorMessage: '发表评论失败，请稍后再试。',
      );
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await _deleteComment(commentId);
      await refreshComments();
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: null);
      return w == null;
    } catch (_) {
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: w ?? '删除评论失败。');
      return false;
    }
  }

  Future<bool> deletePhoto() async {
    try {
      await _deletePhoto(photoId);
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: null);
      return w == null;
    } catch (_) {
      final w = _takeCloudSyncWarning();
      state = state.copyWith(cloudSyncMessage: w, errorMessage: w ?? '删除照片失败。');
      return false;
    }
  }

  @override
  void dispose() {
    _photoSubscription?.cancel();
    _commentSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/thought_comment.dart';
import '../../domain/usecases/add_thought_comment.dart';
import '../../domain/usecases/delete_idea_note.dart';
import '../../domain/usecases/delete_thought_comment.dart';
import '../../domain/usecases/refresh_idea_notes.dart';
import '../../domain/usecases/refresh_thought_comments.dart';
import '../../domain/usecases/watch_idea_note.dart';
import '../../domain/usecases/watch_thought_comments.dart';
import 'idea_detail_state.dart';

class IdeaDetailController extends StateNotifier<IdeaDetailState> {
  IdeaDetailController(
    this.ideaId,
    this._watchIdeaNote,
    this._refreshIdeaNotes,
    this._watchThoughtComments,
    this._refreshThoughtComments,
    this._addThoughtComment,
    this._deleteThoughtComment,
    this._deleteIdeaNote,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._takeCloudSyncWarning,
  ) : super(const IdeaDetailState()) {
    _bind();
  }

  final String ideaId;
  final WatchIdeaNote _watchIdeaNote;
  final RefreshIdeaNotes _refreshIdeaNotes;
  final WatchThoughtComments _watchThoughtComments;
  final RefreshThoughtComments _refreshThoughtComments;
  final AddThoughtComment _addThoughtComment;
  final DeleteThoughtComment _deleteThoughtComment;
  final DeleteIdeaNote _deleteIdeaNote;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _takeCloudSyncWarning;

  StreamSubscription? _ideaSubscription;
  StreamSubscription? _commentSubscription;

  void _bind() {
    state = state.copyWith(isLoading: true, errorMessage: null);
    _ideaSubscription = _watchIdeaNote(ideaId).listen(
      (idea) {
        state = state.copyWith(
          idea: idea,
          isLoading: false,
          errorMessage: idea == null ? '这条想法已经不存在了。' : null,
        );
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '想法详情加载失败。');
      },
    );
    _commentSubscription = _watchThoughtComments(
      ThoughtComment.targetTypeIdea,
      ideaId,
    ).listen(
      (comments) {
        state = state.copyWith(comments: comments, isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '评论加载失败。');
      },
    );
    unawaited(refresh(showLoading: state.idea == null));
  }

  Future<void> refresh({bool showLoading = false}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      await _refreshIdeaNotes();
      await _refreshThoughtComments(ThoughtComment.targetTypeIdea, ideaId);
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '刷新失败，请稍后再试。');
    }
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
      await _addThoughtComment(
        ThoughtComment(
          id: 'thought-comment-${now.microsecondsSinceEpoch}',
          coupleId: coupleId,
          targetType: ThoughtComment.targetTypeIdea,
          targetId: ideaId,
          authorUserId: currentUserId,
          content: trimmed,
          createdAt: now,
          updatedAt: now,
        ),
      );
      state = state.copyWith(
        isSendingComment: false,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSendingComment: false,
        errorMessage: '发表评论失败。',
      );
      return false;
    }
  }

  Future<bool> deleteComment(ThoughtComment comment) async {
    final currentUserId = _resolveCurrentUserId();
    if (!comment.authoredBy(currentUserId)) {
      state = state.copyWith(errorMessage: '只能删除自己的评论。');
      return false;
    }
    try {
      await _deleteThoughtComment(comment.id);
      state = state.copyWith(
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除评论失败。');
      return false;
    }
  }

  Future<bool> deleteIdea() async {
    try {
      await _deleteIdeaNote(ideaId);
      state = state.copyWith(cloudSyncMessage: _takeCloudSyncWarning());
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除想法失败。');
      return false;
    }
  }

  @override
  void dispose() {
    _ideaSubscription?.cancel();
    _commentSubscription?.cancel();
    super.dispose();
  }
}

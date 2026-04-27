import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/excerpt_note.dart';
import '../../domain/entities/idea_note.dart';
import '../../domain/usecases/create_excerpt_note.dart';
import '../../domain/usecases/create_idea_note.dart';
import '../../domain/usecases/delete_excerpt_note.dart';
import '../../domain/usecases/delete_idea_note.dart';
import '../../domain/usecases/refresh_excerpt_notes.dart';
import '../../domain/usecases/refresh_idea_notes.dart';
import '../../domain/usecases/update_excerpt_note.dart';
import '../../domain/usecases/update_idea_note.dart';
import '../../domain/usecases/watch_excerpt_notes.dart';
import '../../domain/usecases/watch_idea_notes.dart';
import 'thoughts_home_state.dart';

class ThoughtsHomeController extends StateNotifier<ThoughtsHomeState> {
  ThoughtsHomeController(
    this._watchIdeaNotes,
    this._refreshIdeaNotes,
    this._createIdeaNote,
    this._updateIdeaNote,
    this._deleteIdeaNote,
    this._watchExcerptNotes,
    this._refreshExcerptNotes,
    this._createExcerptNote,
    this._updateExcerptNote,
    this._deleteExcerptNote,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._takeCloudSyncWarning,
  ) : super(const ThoughtsHomeState()) {
    _bind();
  }

  final WatchIdeaNotes _watchIdeaNotes;
  final RefreshIdeaNotes _refreshIdeaNotes;
  final CreateIdeaNote _createIdeaNote;
  final UpdateIdeaNote _updateIdeaNote;
  final DeleteIdeaNote _deleteIdeaNote;
  final WatchExcerptNotes _watchExcerptNotes;
  final RefreshExcerptNotes _refreshExcerptNotes;
  final CreateExcerptNote _createExcerptNote;
  final UpdateExcerptNote _updateExcerptNote;
  final DeleteExcerptNote _deleteExcerptNote;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _takeCloudSyncWarning;

  StreamSubscription<List<IdeaNote>>? _ideaSubscription;
  StreamSubscription<List<ExcerptNote>>? _excerptSubscription;

  void _bind() {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(
        ideas: const <IdeaNote>[],
        excerpts: const <ExcerptNote>[],
        isLoading: false,
        errorMessage: '请先完成情侣绑定，再来记录你们的心情和灵感。',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    _ideaSubscription?.cancel();
    _excerptSubscription?.cancel();

    _ideaSubscription = _watchIdeaNotes(coupleId).listen(
      (ideas) {
        state = state.copyWith(ideas: ideas, isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '想法列表加载失败。');
      },
    );

    _excerptSubscription = _watchExcerptNotes(coupleId).listen(
      (excerpts) {
        state = state.copyWith(excerpts: excerpts, isLoading: false);
      },
      onError: (_) {
        state = state.copyWith(isLoading: false, errorMessage: '文摘列表加载失败。');
      },
    );

    unawaited(refresh(showLoading: state.ideas.isEmpty && state.excerpts.isEmpty));
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      await _refreshIdeaNotes();
      await _refreshExcerptNotes();
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '刷新失败，请稍后再试。');
    }
  }

  void selectSection(ThoughtsSection section) {
    state = state.copyWith(
      section: section,
      isQuickCreateOpen: false,
      cloudSyncMessage: null,
    );
  }

  void selectIdeaFilter(IdeaFilter filter) {
    state = state.copyWith(ideaFilter: filter);
  }

  void selectExcerptFilter(ExcerptFilter filter) {
    state = state.copyWith(excerptFilter: filter);
  }

  void toggleSearch() {
    final nextVisible = !state.isSearchVisible;
    state = state.copyWith(
      isSearchVisible: nextVisible,
      ideaQuery: nextVisible ? state.ideaQuery : '',
      excerptQuery: nextVisible ? state.excerptQuery : '',
    );
  }

  void updateIdeaQuery(String value) {
    state = state.copyWith(ideaQuery: value);
  }

  void updateExcerptQuery(String value) {
    state = state.copyWith(excerptQuery: value);
  }

  void toggleQuickCreate() {
    state = state.copyWith(isQuickCreateOpen: !state.isQuickCreateOpen);
  }

  void closeQuickCreate() {
    if (state.isQuickCreateOpen) {
      state = state.copyWith(isQuickCreateOpen: false);
    }
  }

  Future<bool> saveIdea({
    String? ideaId,
    required String type,
    required String title,
    required String content,
    String? moodTag,
    String? colorStyle,
    String? layoutStyle,
  }) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    final trimmedContent = content.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先完成情侣绑定。');
      return false;
    }
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录后再保存。');
      return false;
    }
    if (trimmedContent.isEmpty) {
      state = state.copyWith(errorMessage: '想法内容不能为空。');
      return false;
    }

    final now = DateTime.now();
    final existing = ideaId == null
        ? null
        : state.ideas.cast<IdeaNote?>().firstWhere(
              (item) => item?.id == ideaId,
              orElse: () => null,
            );
    final draft = IdeaNote(
      id: existing?.id ?? 'idea-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      authorUserId: existing?.authorUserId ?? currentUserId,
      type: type,
      title: title.trim().isEmpty ? null : title.trim(),
      content: trimmedContent,
      moodTag: _cleanNullable(moodTag),
      colorStyle: colorStyle ?? IdeaNote.supportedColorStyles.first,
      layoutStyle: layoutStyle ?? IdeaNote.supportedLayoutStyles.first,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      commentCount: existing?.commentCount ?? 0,
    );

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      if (existing == null) {
        await _createIdeaNote(draft);
      } else {
        await _updateIdeaNote(draft);
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: '保存想法失败。');
      return false;
    }
  }

  Future<bool> deleteIdea(String ideaId) async {
    try {
      await _deleteIdeaNote(ideaId);
      state = state.copyWith(
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除想法失败。');
      return false;
    }
  }

  Future<bool> saveExcerpt({
    String? excerptId,
    required String category,
    required String quoteText,
    String? sourceTitle,
    String? sourceAuthor,
    String? sourceDetail,
    String? personalNote,
    String? cardStyle,
    String? colorStyle,
  }) async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    final trimmedQuote = quoteText.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先完成情侣绑定。');
      return false;
    }
    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录后再保存。');
      return false;
    }
    if (trimmedQuote.isEmpty) {
      state = state.copyWith(errorMessage: '摘录正文不能为空。');
      return false;
    }

    final now = DateTime.now();
    final existing = excerptId == null
        ? null
        : state.excerpts.cast<ExcerptNote?>().firstWhere(
              (item) => item?.id == excerptId,
              orElse: () => null,
            );
    final draft = ExcerptNote(
      id: existing?.id ?? 'excerpt-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      authorUserId: existing?.authorUserId ?? currentUserId,
      category: category,
      quoteText: trimmedQuote,
      sourceTitle: _cleanNullable(sourceTitle),
      sourceAuthor: _cleanNullable(sourceAuthor),
      sourceDetail: _cleanNullable(sourceDetail),
      personalNote: _cleanNullable(personalNote),
      cardStyle: existing?.cardStyle ?? cardStyle ?? ExcerptNote.supportedCardStyles.first,
      colorStyle: existing?.colorStyle ?? colorStyle ?? ExcerptNote.supportedColorStyles.first,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      commentCount: existing?.commentCount ?? 0,
    );

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      if (existing == null) {
        await _createExcerptNote(draft);
      } else {
        await _updateExcerptNote(draft);
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: '保存文摘失败。');
      return false;
    }
  }

  Future<bool> deleteExcerpt(String excerptId) async {
    try {
      await _deleteExcerptNote(excerptId);
      state = state.copyWith(
        errorMessage: null,
        cloudSyncMessage: _takeCloudSyncWarning(),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除文摘失败。');
      return false;
    }
  }

  @override
  void dispose() {
    _ideaSubscription?.cancel();
    _excerptSubscription?.cancel();
    super.dispose();
  }

  String? _cleanNullable(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/insert_todo.dart';
import '../../domain/usecases/load_all_todos.dart';
import '../../domain/usecases/refresh_todos.dart';
import '../../domain/usecases/update_todo.dart';
import 'todo_state.dart';

class TodoController extends StateNotifier<TodoState> {
  TodoController(
    this._loadAllTodos,
    this._refreshTodos,
    this._insertTodo,
    this._updateTodo,
    this._deleteTodo,
    this._addFeedEvent,
    this._resolveCoupleId,
  ) : super(const TodoState());

  final LoadAllTodos _loadAllTodos;
  final RefreshTodos _refreshTodos;
  final InsertTodo _insertTodo;
  final UpdateTodo _updateTodo;
  final DeleteTodo _deleteTodo;
  final AddFeedEvent _addFeedEvent;
  final String? Function() _resolveCoupleId;

  Future<void> loadAll() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _loadAllTodos(coupleId: coupleId);
      state = state.copyWith(
        items: items.where((item) => !item.isDeleted).toList(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '待办加载失败');
    }
  }

  Future<void> refresh() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final items = await _refreshTodos(coupleId: coupleId);
      state = state.copyWith(
        items: items.where((item) => !item.isDeleted).toList(),
        isRefreshing: false,
      );
    } catch (_) {
      state = state.copyWith(isRefreshing: false, errorMessage: '待办同步失败');
    }
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter, errorMessage: null);
  }

  Future<bool> create({
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  }) async {
    final coupleId = _resolveCoupleId();
    final trimmedTitle = title.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先绑定情侣关系');
      return false;
    }
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(errorMessage: '请输入待办标题');
      return false;
    }

    final now = DateTime.now();
    final optimistic = TodoItem(
      id: 'todo-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      title: trimmedTitle,
      description: description.trim(),
      dueAt: dueAt,
      owner: owner,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: true,
      meDone: false,
      partnerDone: false,
    );

    state = state.copyWith(items: [optimistic, ...state.items], errorMessage: null);
    try {
      final saved = await _insertTodo(optimistic);
      state = state.copyWith(
        items: [
          saved,
          ...state.items.where((item) => item.id != optimistic.id),
        ],
      );
      await _addFeedEvent(
        eventType: FeedEventType.todoCreated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.todo,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.todoCreated(
          title: saved.title,
          isPartnerTask: saved.owner == TodoOwner.partner,
        ),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '创建待办失败');
      return false;
    }
  }

  Future<void> toggleMyDone(String todoId, bool done) async {
    final target = state.items.cast<TodoItem?>().firstWhere(
      (item) => item?.id == todoId,
      orElse: () => null,
    );
    if (target == null) {
      return;
    }
    final optimistic = target.copyWith(
      meDone: done,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == todoId) optimistic else item,
      ],
      errorMessage: null,
    );

    try {
      final saved = await _updateTodo(optimistic);
      state = state.copyWith(
        items: [
          for (final item in state.items)
            if (item.id == todoId) saved else item,
        ],
      );
      if (done) {
        await _addFeedEvent(
          eventType: FeedEventType.todoCompleted,
          actorSide: FeedActorSide.me,
          targetType: FeedTargetType.todo,
          targetId: saved.id,
          summaryText: FeedSummaryBuilder.todoCompleted(title: saved.title),
        );
      }
    } catch (_) {
      state = state.copyWith(errorMessage: '更新待办状态失败');
    }
  }

  bool canManage(TodoItem item) {
    return item.owner == TodoOwner.me || item.owner == TodoOwner.shared;
  }

  Future<bool> updateDetails({
    required TodoItem item,
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  }) async {
    if (!canManage(item)) {
      state = state.copyWith(errorMessage: '不能修改 TA 的待办');
      return false;
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      state = state.copyWith(errorMessage: '请输入待办标题');
      return false;
    }
    final optimistic = item.copyWith(
      title: trimmedTitle,
      description: description.trim(),
      dueAt: dueAt,
      owner: owner,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    state = state.copyWith(
      items: [
        for (final current in state.items)
          if (current.id == item.id) optimistic else current,
      ],
      errorMessage: null,
    );
    try {
      final saved = await _updateTodo(optimistic);
      state = state.copyWith(
        items: [
          for (final current in state.items)
            if (current.id == item.id) saved else current,
        ],
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '更新待办失败');
      return false;
    }
  }

  Future<void> delete(TodoItem item) async {
    if (!canManage(item)) {
      state = state.copyWith(errorMessage: '不能删除 TA 的待办');
      return;
    }
    final deleted = item.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    state = state.copyWith(
      items: [
        for (final current in state.items)
          if (current.id == item.id) deleted else current,
      ],
      errorMessage: null,
    );
    try {
      await _deleteTodo(
        id: item.id,
        coupleId: item.coupleId,
        updatedAt: deleted.updatedAt,
      );
      state = state.copyWith(
        items: state.items.where((current) => !current.isDeleted).toList(),
      );
      await _addFeedEvent(
        eventType: FeedEventType.todoDeleted,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.todo,
        targetId: item.id,
        summaryText: FeedSummaryBuilder.todoDeleted(title: item.title),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '删除待办失败');
    }
  }
}

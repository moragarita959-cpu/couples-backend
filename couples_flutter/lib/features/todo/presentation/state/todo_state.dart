import '../../domain/entities/todo_entry.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/todo_progress.dart';

enum TodoFilter { mine, partner, shared }

class TodoState {
  const TodoState({
    this.items = const <TodoItem>[],
    this.filter = TodoFilter.mine,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final List<TodoItem> items;
  final TodoFilter filter;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  List<TodoEntry> get entries {
    return items
        .map(
          (item) => TodoEntry(
            item: item,
            progress: TodoProgress(
              todoId: item.id,
              meDone: item.meDone,
              partnerDone: item.partnerDone,
              updatedAt: item.updatedAt,
            ),
          ),
        )
        .toList();
  }

  List<TodoEntry> get filteredEntries {
    switch (filter) {
      case TodoFilter.mine:
        return entries
            .where(
              (e) =>
                  e.item.owner == TodoOwner.me ||
                  e.item.owner == TodoOwner.shared,
            )
            .toList();
      case TodoFilter.partner:
        return entries
            .where(
              (e) =>
                  e.item.owner == TodoOwner.partner ||
                  e.item.owner == TodoOwner.shared,
            )
            .toList();
      case TodoFilter.shared:
        return entries.where((e) => e.item.owner == TodoOwner.shared).toList();
    }
  }

  TodoState copyWith({
    List<TodoItem>? items,
    TodoFilter? filter,
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _noChange,
  }) {
    return TodoState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

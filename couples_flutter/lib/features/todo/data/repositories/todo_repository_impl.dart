import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_cloud_data_source.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_item_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._local, this._cloud);

  final TodoLocalDataSource _local;
  final TodoCloudDataSource _cloud;

  @override
  Future<List<TodoItem>> loadAll({required String coupleId}) {
    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<List<TodoItem>> refresh({required String coupleId}) async {
    final pending = await _local.getPendingSyncItems(coupleId: coupleId);
    for (final item in pending) {
      try {
        if (item.isDeleted) {
          await _cloud.deleteItem(
            id: item.id,
            coupleId: item.coupleId,
            updatedAt: item.updatedAt,
          );
          await _local.upsertItems([item.copyWith(pendingSync: false)]);
        } else {
          final remote = await _cloud.upsertItem(item);
          await _local.upsertItems([remote.copyWith(pendingSync: false)]);
        }
      } catch (_) {
        continue;
      }
    }

    List<TodoItemModel> remoteItems = const <TodoItemModel>[];
    try {
      remoteItems = await _cloud.listItems(coupleId: coupleId);
    } catch (_) {
      return _local.loadAll(coupleId: coupleId);
    }
    final localItems = await _local.loadAll(coupleId: coupleId);
    final localMap = <String, TodoItemModel>{
      for (final item in localItems.cast<TodoItemModel>()) item.id: item,
    };
    final merged = <TodoItemModel>[];

    for (final remote in remoteItems) {
      final local = localMap[remote.id];
      if (local == null ||
          remote.updatedAt.isAfter(local.updatedAt) ||
          remote.updatedAt.isAtSameMomentAs(local.updatedAt)) {
        merged.add(remote.copyWith(pendingSync: false));
      }
    }

    if (merged.isNotEmpty) {
      await _local.upsertItems(merged);
    }

    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<TodoItem> insert(TodoItem item) async {
    final optimistic = TodoItemModel.fromEntity(item).copyWith(pendingSync: true);
    await _local.upsertItems([optimistic]);
    try {
      final remote = await _cloud.upsertItem(optimistic);
      final synced = remote.copyWith(pendingSync: false);
      await _local.upsertItems([synced]);
      return synced;
    } catch (_) {
      return optimistic;
    }
  }

  @override
  Future<TodoItem> update(TodoItem item) async {
    final optimistic = TodoItemModel.fromEntity(item).copyWith(pendingSync: true);
    await _local.upsertItems([optimistic]);
    try {
      final remote = await _cloud.upsertItem(optimistic);
      final synced = remote.copyWith(pendingSync: false);
      await _local.upsertItems([synced]);
      return synced;
    } catch (_) {
      return optimistic;
    }
  }

  @override
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) async {
    await _local.markDeleted(id: id, updatedAt: updatedAt);
    try {
      await _cloud.deleteItem(
        id: id,
        coupleId: coupleId,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return;
    }
  }

  @override
  Future<List<TodoItem>> getTodos() {
    return Future<List<TodoItem>>.value(<TodoItem>[]);
  }

  @override
  Future<TodoItem> createTodo({
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  }) {
    final now = DateTime.now();
    return insert(
      TodoItem(
        id: 'todo-$now',
        coupleId: '',
        title: title,
        description: description,
        dueAt: dueAt,
        owner: owner,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        pendingSync: true,
      ),
    );
  }

  @override
  Future<void> setMyDone(String todoId, bool done) async {}
}

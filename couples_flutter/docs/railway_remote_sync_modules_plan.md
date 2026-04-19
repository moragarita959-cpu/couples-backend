# Flutter 情侣 App 占位模块远程互通方案

本文基于当前工程 `D:\couple\couples_flutter` 的实际结构整理，目标是让 `Todo / Feed / Bill / Countdown / Schedule / Playlist / Album / Diary` 都按和聊天模块一致的方式，支持：

- `controller -> usecase -> repository -> datasource`
- `repository = local datasource + cloud datasource`
- Railway API 云端互通
- `updatedAt + isDeleted` 冲突解决
- Controller optimistic update，UI 立即响应
- 首页统一聚合各模块摘要

## 1. 总体落地策略

### 1.1 推荐统一同步字段

所有可远程同步的实体都统一带以下字段：

```dart
abstract class SyncEntity {
  String get id;
  String get coupleId;
  DateTime get createdAt;
  DateTime get updatedAt;
  bool get isDeleted;
  bool get pendingSync;
}
```

建议各模块实体都补齐：

- `id`
- `coupleId`
- `createdAt`
- `updatedAt`
- `isDeleted`
- `pendingSync`

如果后面要更强的同步能力，还可以再加：

- `lastSyncedAt`
- `clientTag`
- `version`

### 1.2 冲突规则

统一采用 Last Write Wins：

1. `updatedAt` 更新更晚的数据覆盖更早的数据
2. 若远端记录 `isDeleted == true`，本地做软删除
3. 本地 optimistic 记录先写本地，标记 `pendingSync = true`
4. 云端返回正式记录后，再回写本地，清掉 `pendingSync`

建议封装公共比较器：

```dart
bool shouldReplace({
  required DateTime incomingUpdatedAt,
  required DateTime currentUpdatedAt,
}) {
  return incomingUpdatedAt.isAfter(currentUpdatedAt) ||
      incomingUpdatedAt.isAtSameMomentAs(currentUpdatedAt);
}
```

## 2. 建议文件结构

按你当前项目风格，建议每个模块统一成下面结构：

```text
lib/features/todo/
  data/
    datasources/
      todo_local_data_source.dart
      todo_cloud_data_source.dart
    models/
      todo_item_model.dart
      todo_sync_payload.dart
    repositories/
      todo_repository_impl.dart
  domain/
    entities/
      todo_item.dart
    repositories/
      todo_repository.dart
    usecases/
      load_all_todos.dart
      refresh_todos.dart
      create_todo.dart
      update_todo.dart
      delete_todo.dart
  presentation/
    pages/
      todo_page.dart
    state/
      todo_controller.dart
      todo_state.dart
```

其他模块同理：

- `bill`
- `feed`
- `countdown`
- `schedule`
- `playlist`
- `album`
- `diary`

首页聚合仍放在：

- `lib/features/couple/presentation/state/home_summary_controller.dart`
- `lib/features/couple/presentation/state/home_summary_vm.dart`

## 3. Railway API 约定

建议和聊天模块一样，继续通过 `ApiClient` 对 Railway 发请求，并为每个模块约定统一接口：

```text
POST /todo/list
POST /todo/upsert
POST /todo/delete

POST /feed/list
POST /feed/upsert
POST /feed/delete

POST /bill/list
POST /bill/upsert
POST /bill/delete
```

请求体建议统一：

```json
{
  "coupleId": "couple-1",
  "items": [
    {
      "id": "todo-1",
      "updatedAt": "2026-04-18T10:00:00.000Z",
      "isDeleted": false
    }
  ]
}
```

服务端返回统一：

```json
{
  "data": [
    {
      "id": "todo-1",
      "coupleId": "couple-1",
      "title": "今晚散步",
      "updatedAt": "2026-04-18T10:00:00.000Z",
      "isDeleted": false
    }
  ]
}
```

## 4. ApiClient 扩展示例

可沿用 `lib/core/network/api_client.dart` 的风格，继续扩展模块 API：

```dart
Future<List<Map<String, dynamic>>> listTodoItems({
  required String coupleId,
  DateTime? since,
}) async {
  final payload = await _postJson('/todo/list', <String, dynamic>{
    'coupleId': coupleId,
    'since': since?.toUtc().toIso8601String(),
  });
  return _extractList(payload);
}

Future<Map<String, dynamic>> upsertTodoItem(
  Map<String, dynamic> body,
) async {
  final payload = await _postJson('/todo/upsert', body);
  return _extractObject(payload);
}

Future<void> deleteTodoItem({
  required String coupleId,
  required String id,
  required DateTime updatedAt,
}) async {
  await _postJson('/todo/delete', <String, dynamic>{
    'coupleId': coupleId,
    'id': id,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  });
}
```

同样的 API 模式可复制到：

- `bill`
- `feed`
- `countdown`
- `schedule`
- `playlist`
- `album`
- `diary`

## 5. 通用同步仓库模式

### 5.1 Repository 接口

```dart
abstract class TodoRepository {
  Future<List<TodoItem>> loadAll({required String coupleId});
  Future<List<TodoItem>> refresh({required String coupleId});
  Future<TodoItem> insert(TodoItem item);
  Future<TodoItem> update(TodoItem item);
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  });
}
```

### 5.2 LocalDataSource 示例

```dart
class TodoLocalDataSource {
  const TodoLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<TodoItemModel>> loadAll({required String coupleId}) async {
    final rows =
        await (_db.select(_db.todosTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return rows.map(TodoItemModel.fromTable).toList();
  }

  Future<void> upsertItems(List<TodoItemModel> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.todosTable,
        items.map((item) => item.toCompanion()).toList(),
      );
    });
  }

  Future<void> markDeleted({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.todosTable)..where((t) => t.id.equals(id))).write(
      TodosTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(updatedAt),
        pendingSync: const Value(true),
      ),
    );
  }

  Future<List<TodoItemModel>> getPendingSyncItems({
    required String coupleId,
  }) async {
    final rows =
        await (_db.select(_db.todosTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.pendingSync.equals(true)))
            .get();
    return rows.map(TodoItemModel.fromTable).toList();
  }
}
```

### 5.3 CloudDataSource 示例

```dart
class TodoCloudDataSource {
  const TodoCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TodoItemModel>> listItems({
    required String coupleId,
    DateTime? since,
  }) async {
    final payload = await _apiClient.listTodoItems(
      coupleId: coupleId,
      since: since,
    );
    return payload.map(TodoItemModel.fromCloudJson).toList();
  }

  Future<TodoItemModel> upsertItem(TodoItemModel item) async {
    final payload = await _apiClient.upsertTodoItem(item.toCloudJson());
    return TodoItemModel.fromCloudJson(payload);
  }

  Future<void> deleteItem({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _apiClient.deleteTodoItem(
      coupleId: coupleId,
      id: id,
      updatedAt: updatedAt,
    );
  }
}
```

### 5.4 RepositoryImpl 示例

```dart
class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._local, this._cloud);

  final TodoLocalDataSource _local;
  final TodoCloudDataSource _cloud;

  @override
  Future<List<TodoItem>> loadAll({required String coupleId}) async {
    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<List<TodoItem>> refresh({required String coupleId}) async {
    final pending = await _local.getPendingSyncItems(coupleId: coupleId);

    for (final item in pending) {
      if (item.isDeleted) {
        await _cloud.deleteItem(
          id: item.id,
          coupleId: item.coupleId,
          updatedAt: item.updatedAt,
        );
      } else {
        final remote = await _cloud.upsertItem(item);
        await _local.upsertItems([remote.copyWith(pendingSync: false)]);
      }
    }

    final remoteItems = await _cloud.listItems(coupleId: coupleId);
    final localItems = await _local.loadAll(coupleId: coupleId);
    final localMap = {for (final item in localItems) item.id: item};

    final merged = <TodoItemModel>[];
    for (final remote in remoteItems) {
      final local = localMap[remote.id];
      if (local == null ||
          shouldReplace(
            incomingUpdatedAt: remote.updatedAt,
            currentUpdatedAt: local.updatedAt,
          )) {
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
      await _local.upsertItems([remote.copyWith(pendingSync: false)]);
      return remote;
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
      await _local.upsertItems([remote.copyWith(pendingSync: false)]);
      return remote;
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
      await _local.upsertItems([
        TodoItemModel.deleted(
          id: id,
          coupleId: coupleId,
          updatedAt: updatedAt,
          pendingSync: false,
        ),
      ]);
    } catch (_) {
      // 保留 pendingSync，等待 refresh 重试
    }
  }
}
```

## 6. Controller 模式与 optimistic update

### 6.1 通用 State 结构

```dart
class TodoState {
  const TodoState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<TodoItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  TodoState copyWith({
    List<TodoItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _noChange,
  }) {
    return TodoState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _noChange = Object();
}
```

### 6.2 TodoController 示例

```dart
class TodoController extends StateNotifier<TodoState> {
  TodoController(
    this._loadAll,
    this._refreshTodos,
    this._insertTodo,
    this._updateTodo,
    this._deleteTodo,
    this._resolveCoupleId,
  ) : super(const TodoState());

  final LoadAllTodos _loadAll;
  final RefreshTodos _refreshTodos;
  final InsertTodo _insertTodo;
  final UpdateTodo _updateTodo;
  final DeleteTodo _deleteTodo;
  final String? Function() _resolveCoupleId;

  Future<void> loadAll() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '未绑定情侣关系');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _loadAll(coupleId: coupleId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Todo 加载失败');
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
      state = state.copyWith(items: items, isRefreshing: false);
    } catch (_) {
      state = state.copyWith(isRefreshing: false, errorMessage: 'Todo 同步失败');
    }
  }

  Future<void> insert({
    required String title,
    required DateTime? dueAt,
  }) async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final optimistic = TodoItem(
      id: 'todo-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      title: title.trim(),
      dueAt: dueAt,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: true,
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
    } catch (_) {
      state = state.copyWith(errorMessage: 'Todo 新建失败');
    }
  }

  Future<void> update(TodoItem item) async {
    final updated = item.copyWith(
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    state = state.copyWith(
      items: [
        for (final current in state.items)
          if (current.id == item.id) updated else current,
      ],
      errorMessage: null,
    );

    try {
      final saved = await _updateTodo(updated);
      state = state.copyWith(
        items: [
          for (final current in state.items)
            if (current.id == item.id) saved else current,
        ],
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Todo 更新失败');
    }
  }

  Future<void> delete(TodoItem item) async {
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
    );

    try {
      await _deleteTodo(
        id: item.id,
        coupleId: item.coupleId,
        updatedAt: deleted.updatedAt,
      );
      state = state.copyWith(
        items: state.items.where((item) => !item.isDeleted).toList(),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Todo 删除失败');
    }
  }
}
```

## 7. 每个模块 StateNotifierProvider 示例

你的要求是每个模块独立 `StateNotifierProvider`，下面按当前工程 `lib/app/providers.dart` 的写法给出示例。

### 7.1 Todo

```dart
final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return TodoLocalDataSource(ref.watch(localDbProvider).database);
});

final todoCloudDataSourceProvider = Provider<TodoCloudDataSource>((ref) {
  return TodoCloudDataSource(ref.watch(apiClientProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(
    ref.watch(todoLocalDataSourceProvider),
    ref.watch(todoCloudDataSourceProvider),
  );
});

final loadAllTodosProvider = Provider<LoadAllTodos>((ref) {
  return LoadAllTodos(ref.watch(todoRepositoryProvider));
});

final refreshTodosProvider = Provider<RefreshTodos>((ref) {
  return RefreshTodos(ref.watch(todoRepositoryProvider));
});

final insertTodoProvider = Provider<InsertTodo>((ref) {
  return InsertTodo(ref.watch(todoRepositoryProvider));
});

final updateTodoProvider = Provider<UpdateTodo>((ref) {
  return UpdateTodo(ref.watch(todoRepositoryProvider));
});

final deleteTodoProvider = Provider<DeleteTodo>((ref) {
  return DeleteTodo(ref.watch(todoRepositoryProvider));
});

final todoControllerProvider =
    StateNotifierProvider<TodoController, TodoState>((ref) {
      return TodoController(
        ref.watch(loadAllTodosProvider),
        ref.watch(refreshTodosProvider),
        ref.watch(insertTodoProvider),
        ref.watch(updateTodoProvider),
        ref.watch(deleteTodoProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.2 Feed

```dart
final feedLocalDataSourceProvider = Provider<FeedLocalDataSource>((ref) {
  return FeedLocalDataSource(ref.watch(localDbProvider).database);
});

final feedCloudDataSourceProvider = Provider<FeedCloudDataSource>((ref) {
  return FeedCloudDataSource(ref.watch(apiClientProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    ref.watch(feedLocalDataSourceProvider),
    ref.watch(feedCloudDataSourceProvider),
  );
});

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
      return FeedController(
        ref.watch(loadAllFeedsProvider),
        ref.watch(refreshFeedsProvider),
        ref.watch(insertFeedProvider),
        ref.watch(updateFeedProvider),
        ref.watch(deleteFeedProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.3 Bill

```dart
final billLocalDataSourceProvider = Provider<BillLocalDataSource>((ref) {
  return BillLocalDataSource(ref.watch(localDbProvider).database);
});

final billCloudDataSourceProvider = Provider<BillCloudDataSource>((ref) {
  return BillCloudDataSource(ref.watch(apiClientProvider));
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl(
    ref.watch(billLocalDataSourceProvider),
    ref.watch(billCloudDataSourceProvider),
  );
});

final billControllerProvider =
    StateNotifierProvider<BillController, BillState>((ref) {
      return BillController(
        ref.watch(loadAllBillsProvider),
        ref.watch(refreshBillsProvider),
        ref.watch(insertBillProvider),
        ref.watch(updateBillProvider),
        ref.watch(deleteBillProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.4 Countdown

```dart
final countdownControllerProvider =
    StateNotifierProvider<CountdownController, CountdownState>((ref) {
      return CountdownController(
        ref.watch(loadAllCountdownEventsProvider),
        ref.watch(refreshCountdownEventsProvider),
        ref.watch(insertCountdownEventProvider),
        ref.watch(updateCountdownEventProvider),
        ref.watch(deleteCountdownEventProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.5 Schedule

```dart
final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
      return ScheduleController(
        ref.watch(loadAllCoursesProvider),
        ref.watch(refreshCoursesProvider),
        ref.watch(insertCourseProvider),
        ref.watch(updateCourseProvider),
        ref.watch(deleteCourseProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.6 Playlist

```dart
final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, PlaylistState>((ref) {
      return PlaylistController(
        ref.watch(loadAllSongsProvider),
        ref.watch(refreshSongsProvider),
        ref.watch(insertSongProvider),
        ref.watch(updateSongProvider),
        ref.watch(deleteSongProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.7 Album

```dart
final albumControllerProvider =
    StateNotifierProvider<AlbumController, AlbumState>((ref) {
      return AlbumController(
        ref.watch(loadAllAlbumsProvider),
        ref.watch(refreshAlbumsProvider),
        ref.watch(insertAlbumProvider),
        ref.watch(updateAlbumProvider),
        ref.watch(deleteAlbumProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

### 7.8 Diary

```dart
final diaryControllerProvider =
    StateNotifierProvider<DiaryController, DiaryState>((ref) {
      return DiaryController(
        ref.watch(loadAllDiariesProvider),
        ref.watch(refreshDiariesProvider),
        ref.watch(insertDiaryProvider),
        ref.watch(updateDiaryProvider),
        ref.watch(deleteDiaryProvider),
        ref.watch(currentCoupleIdResolverProvider),
      )..loadAll();
    });
```

## 8. UseCase 示例

每个模块都保持轻 usecase：

```dart
class RefreshTodos {
  const RefreshTodos(this._repository);

  final TodoRepository _repository;

  Future<List<TodoItem>> call({required String coupleId}) {
    return _repository.refresh(coupleId: coupleId);
  }
}
```

其余模块可一比一复制：

- `RefreshBills`
- `RefreshFeeds`
- `RefreshCountdownEvents`
- `RefreshCourses`
- `RefreshSongs`
- `RefreshAlbums`
- `RefreshDiaries`

## 9. HomeSummaryController 聚合示例

你当前首页聚合器在 `lib/features/couple/presentation/state/home_summary_controller.dart`，建议直接扩成“模块摘要聚合器”。

### 9.1 HomeSummaryVm 增加字段

```dart
class HomeSummaryVm {
  const HomeSummaryVm({
    required this.todayTodoDoneCount,
    required this.todayCountdownEvents,
    required this.billWeekTotal,
    required this.billMonthTotal,
    required this.feedTodayCount,
    required this.hasNewCourseContent,
    required this.hasNewPlaylistContent,
    required this.hasNewAlbumContent,
    required this.hasNewDiaryContent,
  });

  final int todayTodoDoneCount;
  final List<CountdownEvent> todayCountdownEvents;
  final double billWeekTotal;
  final double billMonthTotal;
  final int feedTodayCount;
  final bool hasNewCourseContent;
  final bool hasNewPlaylistContent;
  final bool hasNewAlbumContent;
  final bool hasNewDiaryContent;
}
```

### 9.2 Controller 聚合逻辑

```dart
class HomeSummaryController extends StateNotifier<HomeSummaryVm> {
  HomeSummaryController(
    this._todoRepository,
    this._countdownRepository,
    this._billRepository,
    this._feedRepository,
    this._scheduleRepository,
    this._playlistRepository,
    this._albumRepository,
    this._diaryRepository,
    this._resolveCoupleId,
  ) : super(const HomeSummaryVm.initial());

  final TodoRepository _todoRepository;
  final CountdownRepository _countdownRepository;
  final BillRepository _billRepository;
  final FeedRepository _feedRepository;
  final ScheduleRepository _scheduleRepository;
  final PlaylistRepository _playlistRepository;
  final AlbumRepository _albumRepository;
  final DiaryRepository _diaryRepository;
  final String? Function() _resolveCoupleId;

  Future<void> load() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final todos = await _todoRepository.loadAll(coupleId: coupleId);
    final countdownEvents = await _countdownRepository.loadAll(coupleId: coupleId);
    final bills = await _billRepository.loadAll(coupleId: coupleId);
    final feeds = await _feedRepository.loadAll(coupleId: coupleId);
    final courses = await _scheduleRepository.loadAll(coupleId: coupleId);
    final songs = await _playlistRepository.loadAll(coupleId: coupleId);
    final albums = await _albumRepository.loadAll(coupleId: coupleId);
    final diaries = await _diaryRepository.loadAll(coupleId: coupleId);

    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    state = state.copyWith(
      todayTodoDoneCount: todos.where((item) {
        if (!item.isDone) return false;
        final doneDay = DateTime(
          item.updatedAt.year,
          item.updatedAt.month,
          item.updatedAt.day,
        );
        return doneDay == today;
      }).length,
      todayCountdownEvents: countdownEvents.where((event) {
        final day = DateTime(event.date.year, event.date.month, event.date.day);
        return day == today && !event.isDeleted;
      }).toList(),
      billWeekTotal: bills.where((bill) {
        return !bill.isDeleted && !bill.occurredAt.isBefore(weekStart);
      }).fold(0, (sum, bill) => sum + bill.amount),
      billMonthTotal: bills.where((bill) {
        return !bill.isDeleted && !bill.occurredAt.isBefore(monthStart);
      }).fold(0, (sum, bill) => sum + bill.amount),
      feedTodayCount: feeds.where((feed) {
        final day = DateTime(
          feed.createdAt.year,
          feed.createdAt.month,
          feed.createdAt.day,
        );
        return day == today && !feed.isDeleted;
      }).length,
      hasNewCourseContent: courses.any((item) => _isTodayUpdated(item.updatedAt)),
      hasNewPlaylistContent: songs.any((item) => _isTodayUpdated(item.updatedAt)),
      hasNewAlbumContent: albums.any((item) => _isTodayUpdated(item.updatedAt)),
      hasNewDiaryContent: diaries.any((item) => _isTodayUpdated(item.updatedAt)),
    );
  }

  bool _isTodayUpdated(DateTime updatedAt) {
    final now = DateTime.now();
    return updatedAt.year == now.year &&
        updatedAt.month == now.month &&
        updatedAt.day == now.day;
  }
}
```

## 10. 首页入口 UI 示例

你现在首页入口在 `lib/features/couple/presentation/widgets/home_grid_menu.dart`，建议把 badge 和点击反馈直接加进去。

```dart
class HomeGridMenu extends ConsumerWidget {
  const HomeGridMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryControllerProvider);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.38,
      children: [
        _FeatureCard(
          icon: Icons.checklist_rounded,
          title: '待办',
          subtitle: '今日完成 ${summary.todayTodoDoneCount} 项',
          badgeText: summary.todayTodoDoneCount > 0
              ? '${summary.todayTodoDoneCount}'
              : null,
          onTap: () => context.push('/todo'),
        ),
        _FeatureCard(
          icon: Icons.event_note_outlined,
          title: '纪念日',
          subtitle: summary.todayCountdownEvents.isEmpty
              ? '今天没有倒计时事件'
              : '今天 ${summary.todayCountdownEvents.length} 个事件',
          badgeText: summary.todayCountdownEvents.isEmpty
              ? null
              : '${summary.todayCountdownEvents.length}',
          onTap: () => context.push('/countdown'),
        ),
        _FeatureCard(
          icon: Icons.receipt_long_outlined,
          title: '记账',
          subtitle: '本周 ${summary.billWeekTotal.toStringAsFixed(0)} / 本月 ${summary.billMonthTotal.toStringAsFixed(0)}',
          onTap: () => context.push('/bill'),
        ),
        _FeatureCard(
          icon: Icons.rss_feed_outlined,
          title: '动态',
          subtitle: '今日更新 ${summary.feedTodayCount} 条',
          badgeText: summary.feedTodayCount > 0 ? '${summary.feedTodayCount}' : null,
          onTap: () => context.push('/feed'),
        ),
        _FeatureCard(
          icon: Icons.calendar_view_week_outlined,
          title: '课表',
          subtitle: summary.hasNewCourseContent ? '有新内容' : '查看课程安排',
          showDot: summary.hasNewCourseContent,
          onTap: () => context.push('/schedule'),
        ),
        _FeatureCard(
          icon: Icons.library_music_outlined,
          title: '歌单',
          subtitle: summary.hasNewPlaylistContent ? '有新内容' : '一起收藏喜欢的歌',
          showDot: summary.hasNewPlaylistContent,
          onTap: () => context.push('/playlist'),
        ),
        _FeatureCard(
          icon: Icons.photo_album_outlined,
          title: '相册',
          subtitle: summary.hasNewAlbumContent ? '有新照片' : '记录共同回忆',
          showDot: summary.hasNewAlbumContent,
          onTap: () => context.push('/album'),
        ),
        _FeatureCard(
          icon: Icons.menu_book_outlined,
          title: '日记',
          subtitle: summary.hasNewDiaryContent ? '有新日记' : '写下今天的小事',
          showDot: summary.hasNewDiaryContent,
          onTap: () => context.push('/diary'),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
    this.showDot = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;
  final bool showDot;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() {
              _pressed = value;
            });
          },
          child: Stack(
            children: [
              // 你的原卡片内容
              if (widget.badgeText != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _Badge(text: widget.badgeText!),
                ),
              if (widget.showDot)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 11. 占位页如何联动首页

占位页只要用自己的 controller 完成插入或更新，再触发首页聚合刷新即可：

```dart
await ref.read(albumControllerProvider.notifier).insert(
  title: '周末火锅',
  coverUrl: imageUrl,
);
await ref.read(homeSummaryControllerProvider.notifier).load();
```

如果想自动联动，建议在 `HomeSummaryController` 内监听各模块状态：

```dart
ref.listen<TodoState>(todoControllerProvider, (_, __) {
  ref.read(homeSummaryControllerProvider.notifier).load();
});
```

也可以只在以下时机刷新首页：

- 页面返回首页时
- 模块 `insert/update/delete` 成功后
- 应用冷启动后统一 `refresh()`

## 12. 模块迁移顺序建议

建议按下面顺序推进，风险最低：

1. `Todo`
2. `Bill`
3. `Countdown`
4. `Feed`
5. `Schedule`
6. `Playlist`
7. `Album`
8. `Diary`

原因：

- `Todo / Bill / Countdown` 结构最清晰，最适合先验证同步链路
- `Feed` 可以复用“列表同步”能力
- `Album / Diary` 后续大概率会涉及图片上传，放后面更稳

## 13. 与当前工程的对齐建议

结合当前代码，建议直接这样调整：

### 第一批文件新增

- `lib/features/todo/data/datasources/todo_local_data_source.dart`
- `lib/features/todo/data/datasources/todo_cloud_data_source.dart`
- `lib/features/bill/data/datasources/bill_local_data_source.dart`
- `lib/features/bill/data/datasources/bill_cloud_data_source.dart`
- `lib/features/feed/data/datasources/feed_cloud_data_source.dart`
- `lib/features/countdown/data/datasources/countdown_local_data_source.dart`
- `lib/features/countdown/data/datasources/countdown_cloud_data_source.dart`
- `lib/features/schedule/data/datasources/schedule_local_data_source.dart`
- `lib/features/schedule/data/datasources/schedule_cloud_data_source.dart`
- `lib/features/playlist/data/datasources/playlist_local_data_source.dart`
- `lib/features/playlist/data/datasources/playlist_cloud_data_source.dart`

### 第二批文件改造

- `lib/app/providers.dart`
- `lib/core/network/api_client.dart`
- `lib/features/couple/presentation/state/home_summary_controller.dart`
- `lib/features/couple/presentation/state/home_summary_vm.dart`
- `lib/features/couple/presentation/widgets/home_grid_menu.dart`

## 14. 最小可运行落地版本

如果你希望先快速打通远程互通，我建议第一版只做下面最小集合：

1. 每个模块先支持 `loadAll / refresh / insert / update / delete`
2. 本地表先补 `updatedAt / isDeleted / pendingSync`
3. `refresh()` 先做“本地 pending 上行 + 远端全量拉取”
4. 首页先聚合：
   - 今日 Todo 完成数
   - 今日倒计时事件
   - 记账本周/本月总额
   - Feed 今日更新数
   - 课表/歌单/相册/日记是否有今日更新

等这个链路稳定后，再补：

- 增量同步 `since`
- 图片上传
- 更细粒度冲突处理
- WebSocket / SSE 实时刷新

## 15. 结论

最适合你当前项目的方案，不是单独给每个模块再写一套完全不同的远程逻辑，而是抽象成统一的“本地优先 + 云端同步 + optimistic update + Home 聚合”模板：

- 聊天模块继续保留当前模式
- Todo / Bill / Countdown / Feed / Schedule / Playlist / Album / Diary 全部向这个模板靠齐
- `providers.dart` 统一注册 `local + cloud + repository + usecase + controller`
- 首页通过 `HomeSummaryController` 聚合各模块摘要

这套结构后面继续接 Railway、对象存储、推送、实时订阅都会比较顺。

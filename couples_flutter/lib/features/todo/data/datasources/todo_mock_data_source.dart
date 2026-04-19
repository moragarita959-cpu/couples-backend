import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/todo_item.dart';
import '../models/todo_entry_model.dart';
import '../models/todo_item_model.dart';
import '../models/todo_progress_model.dart';

class TodoMockDataSource {
  TodoMockDataSource(this._db);

  final AppDatabase _db;
  bool _seedChecked = false;

  Future<List<TodoEntryModel>> getTodos() async {
    await _ensureSeeded();
    final query =
        _db.select(_db.todosTable).join([
          leftOuterJoin(
            _db.todoProgressTable,
            _db.todoProgressTable.todoId.equalsExp(_db.todosTable.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.todosTable.dueAt),
          OrderingTerm.desc(_db.todosTable.createdAt),
        ]);

    final rows = await query.get();
    return rows.map(_rowToEntry).toList();
  }

  Future<TodoEntryModel> createTodo({
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('待办标题不能为空');
    }

    final now = DateTime.now();
    final item = TodoItemModel(
      id: 'todo-${now.microsecondsSinceEpoch}',
      coupleId: '',
      title: trimmedTitle,
      description: description.trim(),
      dueAt: dueAt,
      owner: owner,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: false,
    );
    final progress = TodoProgressModel(
      todoId: item.id,
      meDone: false,
      partnerDone: false,
      updatedAt: now,
    );

    await _db.batch((batch) {
      batch.insert(
        _db.todosTable,
        TodosTableCompanion.insert(
          id: item.id,
          coupleId: Value<String>(item.coupleId),
          title: item.title,
          description: item.description,
          dueAt: Value<DateTime?>(item.dueAt),
          owner: _ownerToDbValue(item.owner),
          createdAt: item.createdAt,
          updatedAt: Value<DateTime>(item.updatedAt),
          isDeleted: Value<bool>(item.isDeleted),
          pendingSync: Value<bool>(item.pendingSync),
        ),
      );
      batch.insert(
        _db.todoProgressTable,
        TodoProgressTableCompanion.insert(
          todoId: progress.todoId,
          meDone: Value<bool>(progress.meDone),
          partnerDone: Value<bool>(progress.partnerDone),
          updatedAt: progress.updatedAt,
        ),
      );
    });

    return TodoEntryModel(item: item, progress: progress);
  }

  Future<void> setMyDone(String todoId, bool done) async {
    await _ensureSeeded();
    final now = DateTime.now();
    final existing = await (_db.select(
      _db.todoProgressTable,
    )..where((t) => t.todoId.equals(todoId))).getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.todoProgressTable)
          .insert(
            TodoProgressTableCompanion.insert(
              todoId: todoId,
              meDone: Value<bool>(done),
              partnerDone: const Value<bool>(false),
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(
      _db.todoProgressTable,
    )..where((t) => t.todoId.equals(todoId))).write(
      TodoProgressTableCompanion(
        meDone: Value<bool>(done),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  Future<void> _ensureSeeded() async {
    if (_seedChecked) {
      return;
    }
    _seedChecked = true;

    final countExpr = _db.todosTable.id.count();
    final countQuery = _db.selectOnly(_db.todosTable)..addColumns([countExpr]);
    final total = await countQuery
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle();
    if (total > 0) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final seedTodos = <TodosTableCompanion>[
      TodosTableCompanion.insert(
        id: 'todo-seed-1',
        coupleId: const Value<String>(''),
        title: '今晚一起散步',
        description: '饭后在小区散步 20 分钟',
        dueAt: Value<DateTime?>(today.add(const Duration(hours: 21))),
        owner: _ownerToDbValue(TodoOwner.shared),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: Value<DateTime>(now.subtract(const Duration(days: 1))),
        isDeleted: const Value<bool>(false),
        pendingSync: const Value<bool>(false),
      ),
      TodosTableCompanion.insert(
        id: 'todo-seed-2',
        coupleId: const Value<String>(''),
        title: '帮 TA 订明天的早餐',
        description: '记得备注不要香菜',
        dueAt: Value<DateTime?>(today.add(const Duration(days: 1, hours: 8))),
        owner: _ownerToDbValue(TodoOwner.me),
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: Value<DateTime>(now.subtract(const Duration(hours: 8))),
        isDeleted: const Value<bool>(false),
        pendingSync: const Value<bool>(false),
      ),
      TodosTableCompanion.insert(
        id: 'todo-seed-3',
        coupleId: const Value<String>(''),
        title: 'TA 的英语作业',
        description: '提醒 TA 晚上 9 点前提交',
        dueAt: Value<DateTime?>(today.add(const Duration(hours: 21))),
        owner: _ownerToDbValue(TodoOwner.partner),
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: Value<DateTime>(now.subtract(const Duration(hours: 3))),
        isDeleted: const Value<bool>(false),
        pendingSync: const Value<bool>(false),
      ),
    ];

    final seedProgress = <TodoProgressTableCompanion>[
      TodoProgressTableCompanion.insert(
        todoId: 'todo-seed-1',
        meDone: const Value<bool>(false),
        partnerDone: const Value<bool>(false),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      TodoProgressTableCompanion.insert(
        todoId: 'todo-seed-2',
        meDone: const Value<bool>(true),
        partnerDone: const Value<bool>(false),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      TodoProgressTableCompanion.insert(
        todoId: 'todo-seed-3',
        meDone: const Value<bool>(false),
        partnerDone: const Value<bool>(true),
        updatedAt: now.subtract(const Duration(minutes: 40)),
      ),
    ];

    await _db.batch((batch) {
      batch.insertAll(_db.todosTable, seedTodos);
      batch.insertAll(_db.todoProgressTable, seedProgress);
    });
  }

  TodoEntryModel _rowToEntry(TypedResult row) {
    final todo = row.readTable(_db.todosTable);
    final progress = row.readTableOrNull(_db.todoProgressTable);

    final itemModel = TodoItemModel(
      id: todo.id,
      coupleId: todo.coupleId,
      title: todo.title,
      description: todo.description,
      dueAt: todo.dueAt,
      owner: _ownerFromDbValue(todo.owner),
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
      isDeleted: todo.isDeleted,
      pendingSync: todo.pendingSync,
      meDone: progress?.meDone ?? false,
      partnerDone: progress?.partnerDone ?? false,
    );
    final progressModel = TodoProgressModel(
      todoId: todo.id,
      meDone: progress?.meDone ?? false,
      partnerDone: progress?.partnerDone ?? false,
      updatedAt: progress?.updatedAt ?? todo.createdAt,
    );

    return TodoEntryModel(item: itemModel, progress: progressModel);
  }

  String _ownerToDbValue(TodoOwner owner) {
    switch (owner) {
      case TodoOwner.me:
        return 'me';
      case TodoOwner.partner:
        return 'partner';
      case TodoOwner.shared:
        return 'shared';
    }
  }

  TodoOwner _ownerFromDbValue(String raw) {
    switch (raw) {
      case 'me':
        return TodoOwner.me;
      case 'partner':
        return TodoOwner.partner;
      default:
        return TodoOwner.shared;
    }
  }
}


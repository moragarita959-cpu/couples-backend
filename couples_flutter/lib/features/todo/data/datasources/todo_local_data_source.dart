import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/todo_item_model.dart';

class TodoLocalDataSource {
  const TodoLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<TodoItemModel>> loadAll({required String coupleId}) async {
    final query =
        _db.select(_db.todosTable).join([
          leftOuterJoin(
            _db.todoProgressTable,
            _db.todoProgressTable.todoId.equalsExp(_db.todosTable.id),
          ),
        ])
          ..where(
            _db.todosTable.coupleId.equals(coupleId) &
                _db.todosTable.isDeleted.equals(false),
          )
          ..orderBy([
            OrderingTerm.desc(_db.todosTable.updatedAt),
            OrderingTerm.desc(_db.todosTable.createdAt),
          ]);

    final rows = await query.get();
    return rows.map((row) {
      final todo = row.readTable(_db.todosTable);
      final progress = row.readTableOrNull(_db.todoProgressTable);
      return TodoItemModel.fromRow(
        todo,
        meDone: progress?.meDone ?? false,
        partnerDone: progress?.partnerDone ?? false,
      );
    }).toList();
  }

  Future<void> upsertItems(List<TodoItemModel> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.todosTable,
        items.map((item) => item.toTodoCompanion()).toList(),
      );
      batch.insertAllOnConflictUpdate(
        _db.todoProgressTable,
        items.map((item) => item.toProgressCompanion()).toList(),
      );
    });
  }

  Future<List<TodoItemModel>> getPendingSyncItems({
    required String coupleId,
  }) async {
    final query =
        _db.select(_db.todosTable).join([
          leftOuterJoin(
            _db.todoProgressTable,
            _db.todoProgressTable.todoId.equalsExp(_db.todosTable.id),
          ),
        ])
          ..where(
            _db.todosTable.coupleId.equals(coupleId) &
                _db.todosTable.pendingSync.equals(true),
          );
    final rows = await query.get();
    return rows.map((row) {
      final todo = row.readTable(_db.todosTable);
      final progress = row.readTableOrNull(_db.todoProgressTable);
      return TodoItemModel.fromRow(
        todo,
        meDone: progress?.meDone ?? false,
        partnerDone: progress?.partnerDone ?? false,
      );
    }).toList();
  }

  Future<void> markDeleted({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.todosTable)..where((t) => t.id.equals(id))).write(
      TodosTableCompanion(
        isDeleted: const Value<bool>(true),
        pendingSync: const Value<bool>(true),
        updatedAt: Value<DateTime>(updatedAt),
      ),
    );
  }
}

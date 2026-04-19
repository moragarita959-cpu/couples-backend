import 'package:drift/drift.dart';

class TodoProgressTable extends Table {
  @override
  String get tableName => 'todo_progress';

  TextColumn get todoId => text()();

  BoolColumn get meDone => boolean().withDefault(const Constant(false))();

  BoolColumn get partnerDone => boolean().withDefault(const Constant(false))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{todoId};
}

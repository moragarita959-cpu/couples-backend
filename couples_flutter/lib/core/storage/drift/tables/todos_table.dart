import 'package:drift/drift.dart';

class TodosTable extends Table {
  @override
  String get tableName => 'todos';

  TextColumn get id => text()();

  TextColumn get coupleId => text().withDefault(const Constant(''))();

  TextColumn get title => text()();

  TextColumn get description => text()();

  DateTimeColumn get dueAt => dateTime().nullable()();

  TextColumn get owner => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

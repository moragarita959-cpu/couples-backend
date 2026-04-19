import 'package:drift/drift.dart';

class CountdownEventsTable extends Table {
  @override
  String get tableName => 'countdown_events';

  TextColumn get id => text()();

  TextColumn get coupleId => text().withDefault(const Constant(''))();

  TextColumn get name => text()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

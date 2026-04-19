import 'package:drift/drift.dart';

class BillRecordsTable extends Table {
  @override
  String get tableName => 'bill_records';

  TextColumn get id => text()();

  TextColumn get coupleId => text().withDefault(const Constant(''))();

  TextColumn get type => text()();

  RealColumn get amount => real()();

  TextColumn get category => text().withDefault(const Constant('other'))();

  TextColumn get note => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

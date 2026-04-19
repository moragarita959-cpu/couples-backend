import 'package:drift/drift.dart';

class SongsTable extends Table {
  @override
  String get tableName => 'songs';

  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get artist => text()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get preference => text()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

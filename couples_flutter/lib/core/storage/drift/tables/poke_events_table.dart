import 'package:drift/drift.dart';

class PokeEventsTable extends Table {
  @override
  String get tableName => 'poke_events';

  TextColumn get id => text()();

  TextColumn get sender => text()();

  TextColumn get message => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

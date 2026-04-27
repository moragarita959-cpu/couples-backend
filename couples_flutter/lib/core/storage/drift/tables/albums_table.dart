import 'package:drift/drift.dart';

class AlbumsTable extends Table {
  @override
  String get tableName => 'albums';

  TextColumn get id => text()();

  TextColumn get coupleId => text()();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get coverPhotoUrl => text().nullable()();

  TextColumn get createdByUserId => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

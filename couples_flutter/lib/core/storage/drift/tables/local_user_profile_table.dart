import 'package:drift/drift.dart';

class LocalUserProfileTable extends Table {
  @override
  String get tableName => 'local_user_profile';

  TextColumn get userId => text()();

  TextColumn get nickname => text()();

  TextColumn get pairCode => text()();

  TextColumn get coupleId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{userId};
}

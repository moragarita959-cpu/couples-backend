import 'package:drift/drift.dart';

class ThoughtCommentsTable extends Table {
  @override
  String get tableName => 'thought_comments';

  TextColumn get id => text()();

  TextColumn get coupleId => text()();

  TextColumn get targetType => text()();

  TextColumn get targetId => text()();

  TextColumn get authorUserId => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

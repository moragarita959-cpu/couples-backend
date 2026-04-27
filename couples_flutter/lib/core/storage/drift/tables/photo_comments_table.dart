import 'package:drift/drift.dart';

class PhotoCommentsTable extends Table {
  @override
  String get tableName => 'photo_comments';

  TextColumn get id => text()();

  TextColumn get photoId => text()();

  TextColumn get coupleId => text()();

  TextColumn get authorUserId => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

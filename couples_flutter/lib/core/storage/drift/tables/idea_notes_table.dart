import 'package:drift/drift.dart';

class IdeaNotesTable extends Table {
  @override
  String get tableName => 'idea_notes';

  TextColumn get id => text()();

  TextColumn get coupleId => text()();

  TextColumn get authorUserId => text()();

  TextColumn get type => text()();

  TextColumn get title => text().nullable()();

  TextColumn get content => text()();

  TextColumn get moodTag => text().nullable()();

  TextColumn get colorStyle => text().nullable()();

  TextColumn get layoutStyle => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

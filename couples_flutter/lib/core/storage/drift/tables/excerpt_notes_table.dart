import 'package:drift/drift.dart';

class ExcerptNotesTable extends Table {
  @override
  String get tableName => 'excerpt_notes';

  TextColumn get id => text()();

  TextColumn get coupleId => text()();

  TextColumn get authorUserId => text()();

  TextColumn get category => text()();

  TextColumn get quoteText => text()();

  TextColumn get sourceTitle => text().nullable()();

  TextColumn get sourceAuthor => text().nullable()();

  TextColumn get sourceDetail => text().nullable()();

  TextColumn get personalNote => text().nullable()();

  TextColumn get cardStyle => text().nullable()();

  TextColumn get colorStyle => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

import 'package:drift/drift.dart';

class SongReviewsTable extends Table {
  @override
  String get tableName => 'song_reviews';

  TextColumn get id => text()();

  TextColumn get songId => text()();

  TextColumn get author => text()();

  TextColumn get content => text()();

  IntColumn get atmosphereScore => integer().withDefault(const Constant(0))();

  IntColumn get resonanceScore => integer().withDefault(const Constant(0))();

  IntColumn get shareScore => integer().withDefault(const Constant(0))();

  TextColumn get styleTags => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

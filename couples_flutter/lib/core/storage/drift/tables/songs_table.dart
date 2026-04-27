import 'package:drift/drift.dart';

class SongsTable extends Table {
  @override
  String get tableName => 'songs';

  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get artist => text()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get genre => text().withDefault(const Constant(''))();

  TextColumn get recommender => text().withDefault(const Constant('me'))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  TextColumn get preference => text()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

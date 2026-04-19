import 'package:drift/drift.dart';

class RelationshipSettingsTable extends Table {
  @override
  String get tableName => 'relationship_settings';

  TextColumn get id => text().withDefault(const Constant('primary'))();

  DateTimeColumn get loveStartDate => dateTime().nullable()();

  IntColumn get loveDaysOverride => integer().nullable()();

  BoolColumn get distanceEnabled => boolean().withDefault(const Constant(false))();

  TextColumn get distanceText => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

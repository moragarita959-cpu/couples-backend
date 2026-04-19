import 'package:drift/drift.dart';

class FeedEventsTable extends Table {
  @override
  String get tableName => 'feed_events';

  TextColumn get id => text()();

  TextColumn get eventType => text()();

  TextColumn get actorSide => text()();

  TextColumn get targetType => text()();

  TextColumn get targetId => text()();

  TextColumn get summaryText => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

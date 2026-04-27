import 'package:drift/drift.dart';

/// Single-row local pick for homepage 「今日一句」 (maps from a feed line).
class DailySentencePickTable extends Table {
  @override
  String get tableName => 'daily_sentence_pick';

  /// Always `primary` — one row per install.
  TextColumn get id => text()();

  TextColumn get feedEventId => text().nullable()();

  TextColumn get summaryText => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

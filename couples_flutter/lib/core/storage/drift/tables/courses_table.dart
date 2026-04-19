import 'package:drift/drift.dart';

class CoursesTable extends Table {
  @override
  String get tableName => 'courses';

  TextColumn get id => text()();

  TextColumn get title => text()();

  IntColumn get weekday => integer()();

  IntColumn get startMinute => integer().withDefault(const Constant(480))();

  IntColumn get endMinute => integer().withDefault(const Constant(575))();

  IntColumn get startWeek => integer().withDefault(const Constant(1))();

  IntColumn get endWeek => integer().withDefault(const Constant(20))();

  BoolColumn get repeatWeekly => boolean().withDefault(const Constant(true))();

  IntColumn get startPeriod => integer()();

  IntColumn get endPeriod => integer()();

  TextColumn get location => text()();

  TextColumn get teacher => text()();

  TextColumn get note => text().withDefault(const Constant(''))();

  TextColumn get owner => text()();

  TextColumn get colorHex => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

import 'package:drift/drift.dart';

class LocalCoupleProfileTable extends Table {
  @override
  String get tableName => 'local_couple_profile';

  TextColumn get coupleId => text()();

  TextColumn get currentUserId => text()();

  TextColumn get currentUserNickname => text()();

  TextColumn get partnerUserId => text()();

  TextColumn get partnerNickname => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{coupleId};
}

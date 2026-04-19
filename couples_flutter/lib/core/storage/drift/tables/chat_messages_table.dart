import 'package:drift/drift.dart';

class ChatMessagesTable extends Table {
  @override
  String get tableName => 'chat_messages';

  TextColumn get id => text()();

  TextColumn get content => text()();

  TextColumn get sender => text()();

  TextColumn get senderUserId => text().nullable()();

  TextColumn get clientMessageId => text().nullable()();

  TextColumn get messageType =>
      text().withDefault(const Constant('text'))();

  TextColumn get mediaUrl => text().nullable()();

  IntColumn get mediaDurationMs => integer().nullable()();

  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

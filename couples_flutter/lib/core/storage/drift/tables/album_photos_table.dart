import 'package:drift/drift.dart';

class AlbumPhotosTable extends Table {
  @override
  String get tableName => 'album_photos';

  TextColumn get id => text()();

  TextColumn get albumId => text()();

  TextColumn get coupleId => text()();

  TextColumn get uploaderUserId => text()();

  TextColumn get imageUrl => text().nullable()();

  TextColumn get localPath => text().nullable()();

  TextColumn get caption => text().withDefault(const Constant(''))();

  DateTimeColumn get takenAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

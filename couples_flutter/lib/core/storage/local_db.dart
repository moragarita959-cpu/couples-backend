import 'drift/app_database.dart';

class LocalDb {
  LocalDb({AppDatabase? database}) : _database = database ?? AppDatabase();

  final AppDatabase _database;

  AppDatabase get database => _database;

  bool get ready => true;

  Future<void> close() {
    return _database.close();
  }
}

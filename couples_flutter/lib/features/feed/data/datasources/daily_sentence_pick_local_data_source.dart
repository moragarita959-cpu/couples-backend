import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/feed_event.dart';

class DailySentencePickLocalDataSource {
  DailySentencePickLocalDataSource(this._db);

  final AppDatabase _db;

  static const String _rowId = 'primary';

  Stream<DailySentencePickTableData?> watchPick() {
    return (_db.select(_db.dailySentencePickTable)
          ..where((t) => t.id.equals(_rowId)))
        .watchSingleOrNull();
  }

  Future<void> saveFromFeedEvent(FeedEvent event) async {
    await _db.into(_db.dailySentencePickTable).insertOnConflictUpdate(
          DailySentencePickTableCompanion.insert(
            id: _rowId,
            feedEventId: Value<String>(event.id),
            summaryText: event.summaryText.trim(),
            updatedAt: DateTime.now(),
          ),
        );
  }
}

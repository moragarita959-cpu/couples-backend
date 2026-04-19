import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/countdown_settings.dart';
import '../models/countdown_event_model.dart';

class CountdownLocalDataSource {
  const CountdownLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<CountdownEventModel>> loadAll({required String coupleId}) async {
    final rows =
        await (_db.select(_db.countdownEventsTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])).get();
    return rows.map(CountdownEventModel.fromRow).toList();
  }

  Future<void> upsertItems(List<CountdownEventModel> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.countdownEventsTable,
        items.map((item) => item.toCompanion()).toList(),
      );
    });
  }

  Future<List<CountdownEventModel>> getPendingSyncItems({
    required String coupleId,
  }) async {
    final rows =
        await (_db.select(_db.countdownEventsTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.pendingSync.equals(true)))
            .get();
    return rows.map(CountdownEventModel.fromRow).toList();
  }

  Future<void> markDeleted({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.countdownEventsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      CountdownEventsTableCompanion(
        isDeleted: const Value<bool>(true),
        pendingSync: const Value<bool>(true),
        updatedAt: Value<DateTime>(updatedAt),
      ),
    );
  }

  Future<CountdownSettings> getSettings() async {
    final row = await (_db.select(
      _db.relationshipSettingsTable,
    )..where((t) => t.id.equals('primary'))).getSingleOrNull();

    return CountdownSettings(
      loveStartDate: row?.loveStartDate,
      loveDaysOverride: row?.loveDaysOverride,
    );
  }

  Future<void> saveSettings({
    DateTime? loveStartDate,
    int? loveDaysOverride,
  }) async {
    final now = DateTime.now();
    final existing = await (_db.select(
      _db.relationshipSettingsTable,
    )..where((t) => t.id.equals('primary'))).getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.relationshipSettingsTable).insert(
            RelationshipSettingsTableCompanion.insert(
              id: const Value<String>('primary'),
              loveStartDate: Value<DateTime?>(loveStartDate),
              loveDaysOverride: Value<int?>(loveDaysOverride),
              distanceEnabled: const Value<bool>(false),
              distanceText: const Value<String?>(null),
              updatedAt: now,
            ),
          );
      return;
    }

    await (_db.update(_db.relationshipSettingsTable)
          ..where((t) => t.id.equals('primary')))
        .write(
      RelationshipSettingsTableCompanion(
        loveStartDate: Value<DateTime?>(loveStartDate),
        loveDaysOverride: Value<int?>(loveDaysOverride),
        distanceEnabled: Value<bool>(existing.distanceEnabled),
        distanceText: Value<String?>(existing.distanceText),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }
}

import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/countdown_settings.dart';
import '../models/countdown_event_model.dart';

class CountdownMockDataSource {
  CountdownMockDataSource(this._db);

  final AppDatabase _db;

  Future<CountdownEventModel> addEvent(String name, DateTime date) async {
    final now = DateTime.now();
    final event = CountdownEventModel(
      id: 'countdown-${now.microsecondsSinceEpoch}',
      coupleId: '',
      name: name,
      date: date,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: false,
    );

    await _db.into(_db.countdownEventsTable).insert(
          CountdownEventsTableCompanion.insert(
            id: event.id,
            coupleId: Value<String>(event.coupleId),
            name: event.name,
            date: event.date,
            createdAt: Value<DateTime>(event.createdAt),
            updatedAt: Value<DateTime>(event.updatedAt),
            isDeleted: Value<bool>(event.isDeleted),
            pendingSync: Value<bool>(event.pendingSync),
          ),
        );

    return event;
  }

  Future<CountdownEventModel> updateEvent(
    String id,
    String name,
    DateTime date,
  ) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Countdown name is required');
    }

    await (_db.update(_db.countdownEventsTable)..where((t) => t.id.equals(id)))
        .write(
      CountdownEventsTableCompanion(
        name: Value<String>(trimmedName),
        date: Value<DateTime>(date),
      ),
    );

    return CountdownEventModel(
      id: id,
      coupleId: '',
      name: trimmedName,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      pendingSync: false,
    );
  }

  Future<void> deleteEvent(String id) {
    return (_db.delete(_db.countdownEventsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<CountdownEventModel>> getEvents() async {
    final rows = await (_db.select(_db.countdownEventsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
          ]))
        .get();

    return rows
        .map(
          (row) => CountdownEventModel(
            id: row.id,
            coupleId: row.coupleId,
            name: row.name,
            date: row.date,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            isDeleted: row.isDeleted,
            pendingSync: row.pendingSync,
          ),
        )
        .toList();
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

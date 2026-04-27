import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/distance_info.dart';

class DistanceMockDataSource {
  DistanceMockDataSource(this._db);

  final AppDatabase _db;

  Future<DistanceInfo> getDistanceInfo() async {
    final row = await _loadSettings();
    final enabled = row?.distanceEnabled ?? false;
    return DistanceInfo(
      isEnabled: enabled,
      distanceText: enabled ? row?.distanceText : null,
    );
  }

  Future<DistanceInfo> enableDistance() async {
    final existing = await _loadSettings();
    final nextText = (existing?.distanceText?.trim().isNotEmpty ?? false)
        ? existing!.distanceText
        : 'You are 126.4 km apart';
    await _persist(
      distanceEnabled: true,
      distanceText: nextText,
      loveStartDate: existing?.loveStartDate,
      loveDaysOverride: existing?.loveDaysOverride,
    );
    return DistanceInfo(isEnabled: true, distanceText: nextText);
  }

  Future<DistanceInfo> disableDistance() async {
    final existing = await _loadSettings();
    await _persist(
      distanceEnabled: false,
      distanceText: existing?.distanceText,
      loveStartDate: existing?.loveStartDate,
      loveDaysOverride: existing?.loveDaysOverride,
    );
    return const DistanceInfo(isEnabled: false, distanceText: null);
  }

  Future<DistanceInfo> updateDistanceText(String distanceText) async {
    final existing = await _loadSettings();
    final nextText = distanceText.trim();
    await _persist(
      distanceEnabled: existing?.distanceEnabled ?? true,
      distanceText: nextText,
      loveStartDate: existing?.loveStartDate,
      loveDaysOverride: existing?.loveDaysOverride,
    );
    return DistanceInfo(
      isEnabled: existing?.distanceEnabled ?? true,
      distanceText: nextText,
    );
  }

  Future<RelationshipSettingsTableData?> _loadSettings() {
    return (_db.select(
      _db.relationshipSettingsTable,
    )..where((t) => t.id.equals('primary'))).getSingleOrNull();
  }

  Future<(String? userId, String? coupleId)> loadIdentityContext() async {
    final profile = await (_db.select(_db.localUserProfileTable)..limit(1)).getSingleOrNull();
    if (profile == null) {
      return (null, null);
    }
    final coupleId = profile.coupleId;
    return (
      profile.userId.trim().isEmpty ? null : profile.userId,
      coupleId == null || coupleId.trim().isEmpty ? null : coupleId,
    );
  }

  Future<void> _persist({
    required bool distanceEnabled,
    required String? distanceText,
    required DateTime? loveStartDate,
    required int? loveDaysOverride,
  }) async {
    final now = DateTime.now();
    final existing = await _loadSettings();

    if (existing == null) {
      await _db.into(_db.relationshipSettingsTable).insert(
            RelationshipSettingsTableCompanion.insert(
              id: const Value<String>('primary'),
              loveStartDate: Value<DateTime?>(loveStartDate),
              loveDaysOverride: Value<int?>(loveDaysOverride),
              distanceEnabled: Value<bool>(distanceEnabled),
              distanceText: Value<String?>(distanceText),
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
        distanceEnabled: Value<bool>(distanceEnabled),
        distanceText: Value<String?>(distanceText),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }
}

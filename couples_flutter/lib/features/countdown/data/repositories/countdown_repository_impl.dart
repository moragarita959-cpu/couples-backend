import '../../domain/entities/countdown_event.dart';
import '../../domain/entities/countdown_settings.dart';
import '../../domain/repositories/countdown_repository.dart';
import '../datasources/countdown_cloud_data_source.dart';
import '../datasources/countdown_local_data_source.dart';
import '../models/countdown_event_model.dart';

class CountdownRepositoryImpl implements CountdownRepository {
  const CountdownRepositoryImpl(this._local, this._cloud);

  final CountdownLocalDataSource _local;
  final CountdownCloudDataSource _cloud;

  @override
  Future<List<CountdownEvent>> loadAll({required String coupleId}) {
    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<List<CountdownEvent>> refresh({required String coupleId}) async {
    final pending = await _local.getPendingSyncItems(coupleId: coupleId);
    for (final item in pending) {
      if (item.isDeleted) {
        await _cloud.deleteItem(
          id: item.id,
          coupleId: item.coupleId,
          updatedAt: item.updatedAt,
        );
        await _local.upsertItems([item.copyWith(pendingSync: false)]);
      } else {
        final remote = await _cloud.upsertItem(item);
        await _local.upsertItems([remote.copyWith(pendingSync: false)]);
      }
    }

    final remoteItems = await _cloud.listItems(coupleId: coupleId);
    final localItems = await _local.loadAll(coupleId: coupleId);
    final localMap = <String, CountdownEventModel>{
      for (final item in localItems.cast<CountdownEventModel>()) item.id: item,
    };
    final merged = <CountdownEventModel>[];

    for (final remote in remoteItems) {
      final local = localMap[remote.id];
      if (local == null ||
          remote.updatedAt.isAfter(local.updatedAt) ||
          remote.updatedAt.isAtSameMomentAs(local.updatedAt)) {
        merged.add(remote.copyWith(pendingSync: false));
      }
    }

    if (merged.isNotEmpty) {
      await _local.upsertItems(merged);
    }
    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<CountdownEvent> insert(CountdownEvent event) async {
    final optimistic =
        CountdownEventModel.fromEntity(event).copyWith(pendingSync: true);
    await _local.upsertItems([optimistic]);
    try {
      final remote = await _cloud.upsertItem(optimistic);
      final synced = remote.copyWith(pendingSync: false);
      await _local.upsertItems([synced]);
      return synced;
    } catch (_) {
      return optimistic;
    }
  }

  @override
  Future<CountdownEvent> update(CountdownEvent event) async {
    final optimistic =
        CountdownEventModel.fromEntity(event).copyWith(pendingSync: true);
    await _local.upsertItems([optimistic]);
    try {
      final remote = await _cloud.upsertItem(optimistic);
      final synced = remote.copyWith(pendingSync: false);
      await _local.upsertItems([synced]);
      return synced;
    } catch (_) {
      return optimistic;
    }
  }

  @override
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) async {
    await _local.markDeleted(id: id, updatedAt: updatedAt);
    try {
      await _cloud.deleteItem(
        id: id,
        coupleId: coupleId,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return;
    }
  }

  @override
  Future<CountdownSettings> getSettings() {
    return _local.getSettings();
  }

  @override
  Future<void> saveSettings({
    DateTime? loveStartDate,
    int? loveDaysOverride,
  }) {
    return _local.saveSettings(
      loveStartDate: loveStartDate,
      loveDaysOverride: loveDaysOverride,
    );
  }

  @override
  Future<CountdownEvent> addEvent(String name, DateTime date) {
    final now = DateTime.now();
    return insert(
      CountdownEvent(
        id: 'countdown-$now',
        coupleId: '',
        name: name,
        date: date,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        pendingSync: true,
      ),
    );
  }

  @override
  Future<CountdownEvent> updateEvent(String id, String name, DateTime date) {
    final now = DateTime.now();
    return update(
      CountdownEvent(
        id: id,
        coupleId: '',
        name: name,
        date: date,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        pendingSync: true,
      ),
    );
  }

  @override
  Future<void> deleteEvent(String id) {
    return delete(id: id, coupleId: '', updatedAt: DateTime.now());
  }

  @override
  Future<List<CountdownEvent>> getEvents() {
    return loadAll(coupleId: '');
  }
}

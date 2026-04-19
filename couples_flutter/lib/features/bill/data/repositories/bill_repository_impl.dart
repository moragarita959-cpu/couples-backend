import '../../domain/entities/bill_record.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/bill_cloud_data_source.dart';
import '../datasources/bill_local_data_source.dart';
import '../models/bill_record_model.dart';

class BillRepositoryImpl implements BillRepository {
  const BillRepositoryImpl(this._local, this._cloud);

  final BillLocalDataSource _local;
  final BillCloudDataSource _cloud;

  @override
  Future<List<BillRecord>> loadAll({required String coupleId}) {
    return _local.loadAll(coupleId: coupleId);
  }

  @override
  Future<List<BillRecord>> refresh({required String coupleId}) async {
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
    final localMap = <String, BillRecordModel>{
      for (final item in localItems.cast<BillRecordModel>()) item.id: item,
    };
    final merged = <BillRecordModel>[];

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
  Future<BillRecord> insert(BillRecord item) async {
    final optimistic = BillRecordModel.fromEntity(item).copyWith(pendingSync: true);
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
  Future<BillRecord> update(BillRecord item) async {
    final optimistic = BillRecordModel.fromEntity(item).copyWith(pendingSync: true);
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
  Future<BillSummary> getSummary({String coupleId = ''}) {
    return _local.buildSummary(coupleId: coupleId);
  }

  @override
  Future<BillRecord> createRecord(
    BillType type,
    BillCategory category,
    double amount,
    String note,
  ) {
    final now = DateTime.now();
    return insert(
      BillRecord(
        id: 'bill-$now',
        coupleId: '',
        type: type,
        category: category,
        amount: amount,
        note: note,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        pendingSync: true,
      ),
    );
  }

  @override
  Future<List<BillRecord>> getRecords() {
    return loadAll(coupleId: '');
  }
}

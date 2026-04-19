import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/bill_record.dart';
import '../models/bill_record_model.dart';

class BillLocalDataSource {
  const BillLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<BillRecordModel>> loadAll({required String coupleId}) async {
    final rows =
        await (_db.select(_db.billRecordsTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(BillRecordModel.fromRow).toList();
  }

  Future<void> upsertItems(List<BillRecordModel> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.billRecordsTable,
        items.map((item) => item.toCompanion()).toList(),
      );
    });
  }

  Future<List<BillRecordModel>> getPendingSyncItems({
    required String coupleId,
  }) async {
    final rows =
        await (_db.select(_db.billRecordsTable)
          ..where((t) => t.coupleId.equals(coupleId) & t.pendingSync.equals(true)))
            .get();
    return rows.map(BillRecordModel.fromRow).toList();
  }

  Future<void> markDeleted({
    required String id,
    required DateTime updatedAt,
  }) async {
    await (_db.update(_db.billRecordsTable)..where((t) => t.id.equals(id))).write(
      BillRecordsTableCompanion(
        isDeleted: const Value<bool>(true),
        pendingSync: const Value<bool>(true),
        updatedAt: Value<DateTime>(updatedAt),
      ),
    );
  }

  Future<BillSummary> buildSummary({required String coupleId}) async {
    final records = await loadAll(coupleId: coupleId);
    final now = DateTime.now();
    final weekStart = _startOfWeek(now);
    final monthStart = DateTime(now.year, now.month, 1);
    return BillSummary(
      overall: _buildPeriodSummary(records),
      currentWeek: _buildPeriodSummary(
        records.where((record) => !record.createdAt.isBefore(weekStart)).toList(),
      ),
      currentMonth: _buildPeriodSummary(
        records.where((record) => !record.createdAt.isBefore(monthStart)).toList(),
      ),
    );
  }

  BillPeriodSummary _buildPeriodSummary(List<BillRecord> records) {
    double incomeTotal = 0;
    double expenseTotal = 0;
    final expenseByCategory = <BillCategory, double>{};

    for (final record in records) {
      if (record.type == BillType.income) {
        incomeTotal += record.amount;
      } else {
        expenseTotal += record.amount;
        expenseByCategory.update(
          record.category,
          (value) => value + record.amount,
          ifAbsent: () => record.amount,
        );
      }
    }

    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BillPeriodSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      balance: incomeTotal - expenseTotal,
      expenseByCategory: Map<BillCategory, double>.fromEntries(sortedEntries),
      recordCount: records.length,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
  }
}

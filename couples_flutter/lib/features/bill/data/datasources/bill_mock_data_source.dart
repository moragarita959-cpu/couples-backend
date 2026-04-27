import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../models/bill_record_model.dart';

class BillMockDataSource {
  BillMockDataSource(this._db);

  final AppDatabase _db;

  Future<BillRecordModel> createRecord(
    BillType type,
    String categoryKey,
    double amount,
    String note, {
    required String ownerUserId,
    required String coupleId,
  }) async {
    if (amount <= 0) {
      throw Exception('金额必须大于 0');
    }

    final now = DateTime.now();
    final key = BillTagCatalog.normalizeKey(categoryKey);
    final record = BillRecordModel(
      id: 'bill-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      ownerUserId: ownerUserId,
      type: type,
      categoryKey: key,
      amount: amount,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: false,
    );

    await _db.into(_db.billRecordsTable).insert(record.toCompanion());

    return record;
  }

  Future<List<BillRecordModel>> getRecords() async {
    final rows = await (_db.select(_db.billRecordsTable)
          ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .get();
    return rows.map(BillRecordModel.fromRow).toList();
  }

  Future<BillSummary> getSummary() async {
    final rows = await _db.select(_db.billRecordsTable).get();
    final records = rows.map(BillRecordModel.fromRow).toList();
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final startOfMonth = DateTime(now.year, now.month, 1);

    return BillSummary(
      overall: _buildPeriodSummary(records),
      currentWeek: _buildPeriodSummary(
        records.where((record) => !record.createdAt.isBefore(startOfWeek)).toList(),
      ),
      currentMonth: _buildPeriodSummary(
        records.where((record) => !record.createdAt.isBefore(startOfMonth)).toList(),
      ),
    );
  }

  BillPeriodSummary _buildPeriodSummary(List<BillRecordModel> records) {
    double incomeTotal = 0;
    double expenseTotal = 0;
    final expenseByCategoryKey = <String, double>{};

    for (final record in records) {
      if (record.type == BillType.income) {
        incomeTotal += record.amount;
        continue;
      }

      expenseTotal += record.amount;
      final key = BillTagCatalog.normalizeKey(record.categoryKey);
      expenseByCategoryKey.update(
        key,
        (value) => value + record.amount,
        ifAbsent: () => record.amount,
      );
    }

    final sortedEntries = expenseByCategoryKey.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BillPeriodSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      balance: incomeTotal - expenseTotal,
      expenseByCategoryKey: Map<String, double>.fromEntries(sortedEntries),
      recordCount: records.length,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final offset = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: offset));
  }
}

import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/bill_record.dart';
import '../models/bill_record_model.dart';

class BillMockDataSource {
  BillMockDataSource(this._db);

  final AppDatabase _db;

  Future<BillRecordModel> createRecord(
    BillType type,
    BillCategory category,
    double amount,
    String note,
  ) async {
    if (amount <= 0) {
      throw Exception('金额必须大于 0');
    }

    final now = DateTime.now();
    final record = BillRecordModel(
      id: 'bill-${now.microsecondsSinceEpoch}',
      coupleId: '',
      type: type,
      category: category,
      amount: amount,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: false,
    );

    await _db.into(_db.billRecordsTable).insert(
          BillRecordsTableCompanion.insert(
            id: record.id,
            coupleId: Value<String>(record.coupleId),
            type: _typeToDbValue(record.type),
            category: Value<String>(_categoryToDbValue(record.category)),
            amount: record.amount,
            note: record.note,
            createdAt: record.createdAt,
            updatedAt: Value<DateTime>(record.updatedAt),
            isDeleted: Value<bool>(record.isDeleted),
            pendingSync: Value<bool>(record.pendingSync),
          ),
        );

    return record;
  }

  Future<List<BillRecordModel>> getRecords() async {
    final rows = await (_db.select(_db.billRecordsTable)
          ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  Future<BillSummary> getSummary() async {
    final rows = await _db.select(_db.billRecordsTable).get();
    final records = rows.map(_rowToModel).toList();
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

  BillRecordModel _rowToModel(BillRecordsTableData row) {
    return BillRecordModel(
      id: row.id,
      coupleId: row.coupleId,
      type: _typeFromDbValue(row.type),
      category: _categoryFromDbValue(row.category),
      amount: row.amount,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      pendingSync: row.pendingSync,
    );
  }

  BillPeriodSummary _buildPeriodSummary(List<BillRecordModel> records) {
    double incomeTotal = 0;
    double expenseTotal = 0;
    final expenseByCategory = <BillCategory, double>{};

    for (final record in records) {
      if (record.type == BillType.income) {
        incomeTotal += record.amount;
        continue;
      }

      expenseTotal += record.amount;
      expenseByCategory.update(
        record.category,
        (value) => value + record.amount,
        ifAbsent: () => record.amount,
      );
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
    final offset = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: offset));
  }

  String _typeToDbValue(BillType type) {
    return type == BillType.income ? 'income' : 'expense';
  }

  BillType _typeFromDbValue(String value) {
    return value == 'expense' ? BillType.expense : BillType.income;
  }

  String _categoryToDbValue(BillCategory category) {
    return category.name;
  }

  BillCategory _categoryFromDbValue(String value) {
    for (final category in BillCategory.values) {
      if (category.name == value) {
        return category;
      }
    }
    return BillCategory.other;
  }
}


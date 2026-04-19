import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/bill_record.dart';
import '../../domain/usecases/delete_bill_record.dart';
import '../../domain/usecases/insert_bill_record.dart';
import '../../domain/usecases/load_all_bill_records.dart';
import '../../domain/usecases/refresh_bill_records.dart';
import '../../domain/usecases/update_bill_record.dart';
import '../state/bill_state.dart';

class BillController extends StateNotifier<BillState> {
  BillController(
    this._loadAllBillRecords,
    this._refreshBillRecords,
    this._insertBillRecord,
    this._updateBillRecord,
    this._deleteBillRecord,
    this._addFeedEvent,
    this._resolveCoupleId,
  ) : super(const BillState());

  final LoadAllBillRecords _loadAllBillRecords;
  final RefreshBillRecords _refreshBillRecords;
  final InsertBillRecord _insertBillRecord;
  final UpdateBillRecord _updateBillRecord;
  final DeleteBillRecord _deleteBillRecord;
  final AddFeedEvent _addFeedEvent;
  final String? Function() _resolveCoupleId;

  Future<void> loadAll() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final records = await _loadAllBillRecords(coupleId: coupleId);
      state = state.copyWith(
        records: records.where((record) => !record.isDeleted).toList(),
        summary: _buildSummary(records),
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '账单加载失败');
    }
  }

  Future<void> refresh() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final records = await _refreshBillRecords(coupleId: coupleId);
      state = state.copyWith(
        records: records.where((record) => !record.isDeleted).toList(),
        summary: _buildSummary(records),
        isRefreshing: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isRefreshing: false, errorMessage: '账单同步失败');
    }
  }

  Future<bool> create({
    required BillType type,
    required BillCategory category,
    required String amountText,
    required String note,
  }) async {
    final coupleId = _resolveCoupleId();
    final raw = amountText.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先绑定情侣关系');
      return false;
    }
    if (raw.isEmpty) {
      state = state.copyWith(errorMessage: '请输入金额');
      return false;
    }
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      state = state.copyWith(errorMessage: '金额必须大于 0');
      return false;
    }

    final now = DateTime.now();
    final optimistic = BillRecord(
      id: 'bill-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      type: type,
      category: category,
      amount: amount,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: true,
    );

    final nextRecords = [optimistic, ...state.records];
    state = state.copyWith(
      records: nextRecords,
      summary: _buildSummary(nextRecords),
      errorMessage: null,
    );

    try {
      final saved = await _insertBillRecord(optimistic);
      final merged = [
        saved,
        ...state.records.where((item) => item.id != optimistic.id),
      ];
      state = state.copyWith(records: merged, summary: _buildSummary(merged));
      await _addFeedEvent(
        eventType: FeedEventType.billCreated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.billCreated(
          categoryLabel: saved.category.label,
          amount: saved.amount,
        ),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '保存账单失败');
      return false;
    }
  }

  Future<void> update(BillRecord record) async {
    final optimistic = record.copyWith(
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    state = state.copyWith(
      records: [
        for (final item in state.records)
          if (item.id == record.id) optimistic else item,
      ],
      summary: _buildSummary([
        for (final item in state.records)
          if (item.id == record.id) optimistic else item,
      ]),
      errorMessage: null,
    );

    try {
      final saved = await _updateBillRecord(optimistic);
      final merged = [
        for (final item in state.records)
          if (item.id == record.id) saved else item,
      ];
      state = state.copyWith(records: merged, summary: _buildSummary(merged));
      await _addFeedEvent(
        eventType: FeedEventType.billUpdated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.billUpdated(
          categoryLabel: saved.category.label,
          amount: saved.amount,
        ),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '更新账单失败');
    }
  }

  Future<void> delete(BillRecord record) async {
    final deleted = record.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    state = state.copyWith(
      records: [
        for (final item in state.records)
          if (item.id == record.id) deleted else item,
      ],
      summary: _buildSummary([
        for (final item in state.records)
          if (item.id == record.id) deleted else item,
      ]),
      errorMessage: null,
    );
    try {
      await _deleteBillRecord(
        id: record.id,
        coupleId: record.coupleId,
        updatedAt: deleted.updatedAt,
      );
      final kept = state.records.where((item) => !item.isDeleted).toList();
      state = state.copyWith(records: kept, summary: _buildSummary(kept));
      await _addFeedEvent(
        eventType: FeedEventType.billDeleted,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: record.id,
        summaryText: FeedSummaryBuilder.billDeleted(
          categoryLabel: record.category.label,
          amount: record.amount,
        ),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '删除账单失败');
    }
  }

  BillSummary _buildSummary(List<BillRecord> records) {
    final visible = records.where((item) => !item.isDeleted).toList();
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));
    final monthStart = DateTime(now.year, now.month, 1);
    return BillSummary(
      overall: _buildPeriodSummary(visible),
      currentWeek: _buildPeriodSummary(
        visible.where((item) => !item.createdAt.isBefore(weekStart)).toList(),
      ),
      currentMonth: _buildPeriodSummary(
        visible.where((item) => !item.createdAt.isBefore(monthStart)).toList(),
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
    final sorted = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BillPeriodSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      balance: incomeTotal - expenseTotal,
      expenseByCategory: Map<BillCategory, double>.fromEntries(sorted),
      recordCount: records.length,
    );
  }
}

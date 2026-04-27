import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/bill_stats_models.dart';
import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../../domain/usecases/delete_bill_record.dart';
import '../../domain/usecases/insert_bill_record.dart';
import '../../domain/usecases/load_all_bill_records.dart';
import '../../domain/usecases/refresh_bill_records.dart';
import '../../domain/usecases/update_bill_record.dart';
import 'bill_state.dart';

typedef PartnerUserIdLoader = Future<String?> Function();

class BillController extends StateNotifier<BillState> {
  BillController(
    this._loadAllBillRecords,
    this._refreshBillRecords,
    this._insertBillRecord,
    this._updateBillRecord,
    this._deleteBillRecord,
    this._addFeedEvent,
    this._resolveCoupleId,
    this._resolveCurrentUserId,
    this._loadPartnerUserId,
  ) : super(BillState());

  final LoadAllBillRecords _loadAllBillRecords;
  final RefreshBillRecords _refreshBillRecords;
  final InsertBillRecord _insertBillRecord;
  final UpdateBillRecord _updateBillRecord;
  final DeleteBillRecord _deleteBillRecord;
  final AddFeedEvent _addFeedEvent;
  final String? Function() _resolveCoupleId;
  final String? Function() _resolveCurrentUserId;
  final PartnerUserIdLoader _loadPartnerUserId;

  Future<void> loadAll() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final partnerId = await _loadPartnerUserId();
      final records = await _loadAllBillRecords(coupleId: coupleId);
      final visible = _visibleRecords(
        records: records,
        ledgerView: state.ledgerView,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: _resolveCurrentUserId(),
        partnerUserId: partnerId,
      );
      state = state.copyWith(
        records: records.where((record) => !record.isDeleted).toList(),
        summary: _buildSummary(_recordsWithinCurrentRange(visible)),
        partnerUserId: partnerId,
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
      final partnerId = await _loadPartnerUserId();
      final records = await _refreshBillRecords(coupleId: coupleId);
      final visible = _visibleRecords(
        records: records,
        ledgerView: state.ledgerView,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: _resolveCurrentUserId(),
        partnerUserId: partnerId,
      );
      state = state.copyWith(
        records: records.where((record) => !record.isDeleted).toList(),
        summary: _buildSummary(_recordsWithinCurrentRange(visible)),
        partnerUserId: partnerId,
        isRefreshing: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isRefreshing: false, errorMessage: '账单同步失败');
    }
  }

  void setLedgerView(BillLedgerView view) {
    if (view == BillLedgerView.partner) {
      final pid = state.partnerUserId?.trim();
      if (pid == null || pid.isEmpty) {
        unawaited(_reloadPartnerLedgerView());
        return;
      }
    }
    _setLedgerViewImmediate(view);
  }

  void _setLedgerViewImmediate(BillLedgerView view) {
    final visible = _visibleRecords(
      records: [...state.records],
      ledgerView: view,
      filterCategoryKey: state.filterCategoryKey,
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      ledgerView: view,
      dualExpenseLinesInMerged: view == BillLedgerView.merged
          ? state.dualExpenseLinesInMerged
          : false,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
    );
  }

  Future<void> _reloadPartnerLedgerView() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      _setLedgerViewImmediate(BillLedgerView.partner);
      return;
    }
    try {
      final partnerId = await _loadPartnerUserId();
      final visible = _visibleRecords(
        records: [...state.records],
        ledgerView: BillLedgerView.partner,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: _resolveCurrentUserId(),
        partnerUserId: partnerId,
      );
      state = state.copyWith(
        ledgerView: BillLedgerView.partner,
        partnerUserId: partnerId,
        dualExpenseLinesInMerged: false,
        summary: _buildSummary(_recordsWithinCurrentRange(visible)),
      );
    } catch (_) {
      _setLedgerViewImmediate(BillLedgerView.partner);
    }
  }

  void setFilterCategoryKey(String? key) {
    final normalized = _normalizeFilterKey(key);
    final parsed = _splitCategoryKey(normalized);
    final visible = _visibleRecords(
      records: [...state.records],
      ledgerView: state.ledgerView,
      filterCategoryKey: normalized,
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      filterCategoryKey: normalized,
      statsCategoryKey: normalized,
      selectedParentKey: parsed.$1,
      selectedChildKey: parsed.$2,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
    );
  }

  void setTagSelection({
    String? parentKey,
    String? childKey,
  }) {
    final normalizedParent = parentKey?.trim();
    final normalizedChild = childKey?.trim();
    String? composed;
    if (normalizedParent != null && normalizedParent.isNotEmpty) {
      composed = normalizedChild == null || normalizedChild.isEmpty
          ? normalizedParent
          : '$normalizedParent.$normalizedChild';
    }
    final visible = _visibleRecords(
      records: [...state.records],
      ledgerView: state.ledgerView,
      filterCategoryKey: composed,
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      filterCategoryKey: composed,
      statsCategoryKey: composed,
      selectedParentKey: normalizedParent,
      selectedChildKey: normalizedChild,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
    );
  }

  void setGranularity(BillStatsGranularity g) {
    final visible = _visibleRecords(
      records: [...state.records],
      ledgerView: state.ledgerView,
      filterCategoryKey: state.filterCategoryKey,
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    final range = billStatsRangeBounds(
      g,
      focusMonth: state.focusMonth,
      focusDay: state.focusDay,
      customStart: state.customRangeStart,
      customEnd: state.customRangeEnd,
    );
    state = state.copyWith(
      granularity: g,
      summary: _buildSummary(_recordsWithinRange(visible, range)),
    );
  }

  void setQuickRange(BillStatsGranularity g) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    state = state.copyWith(
      granularity: g,
      focusDay: g == BillStatsGranularity.day || g == BillStatsGranularity.week
          ? today
          : state.focusDay,
      focusMonth: g == BillStatsGranularity.month ||
              g == BillStatsGranularity.year
          ? DateTime(now.year, now.month, 1)
          : state.focusMonth,
      customRangeStart: null,
      customRangeEnd: null,
      summary: _buildSummary(
        _recordsWithinRange(
          _visibleRecords(
            records: state.records,
            ledgerView: state.ledgerView,
            filterCategoryKey: _effectiveCategoryKey(),
            currentUserId: _resolveCurrentUserId(),
            partnerUserId: state.partnerUserId,
          ),
          billStatsRangeBounds(
            g,
            focusMonth: g == BillStatsGranularity.month ||
                    g == BillStatsGranularity.year
                ? DateTime(now.year, now.month, 1)
                : state.focusMonth,
            focusDay: g == BillStatsGranularity.day ||
                    g == BillStatsGranularity.week
                ? today
                : state.focusDay,
          ),
        ),
      ),
    );
  }

  void shiftFocusMonth(int delta) {
    final next = DateTime(state.focusMonth.year, state.focusMonth.month + delta, 1);
    state = state.copyWith(focusMonth: next);
  }

  void shiftRange(int delta) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (state.granularity) {
      case BillStatsGranularity.day:
        final base = state.focusDay ?? today;
        state = state.copyWith(focusDay: base.add(Duration(days: delta)));
        break;
      case BillStatsGranularity.week:
      case BillStatsGranularity.last30:
        final base = state.focusDay ?? today;
        state = state.copyWith(focusDay: base.add(Duration(days: delta * 7)));
        break;
      case BillStatsGranularity.month:
        state = state.copyWith(
          focusMonth: DateTime(
            state.focusMonth.year,
            state.focusMonth.month + delta,
            1,
          ),
        );
        break;
      case BillStatsGranularity.year:
        state = state.copyWith(
          focusMonth: DateTime(state.focusMonth.year + delta, 1, 1),
        );
        break;
      case BillStatsGranularity.custom:
        final start = state.customRangeStart;
        final end = state.customRangeEnd;
        if (start == null || end == null) {
          return;
        }
        final days = end.difference(start).inDays.abs() + 1;
        final shift = Duration(days: days * delta);
        final nextStart = start.add(shift);
        final nextEnd = end.add(shift);
        state = state.copyWith(
          customRangeStart: nextStart,
          customRangeEnd: nextEnd,
          focusMonth: DateTime(nextStart.year, nextStart.month, 1),
          focusDay: nextStart,
        );
        break;
    }
  }

  void setFocusMonth(DateTime month) {
    state = state.copyWith(
      focusMonth: DateTime(month.year, month.month, 1),
    );
  }

  void setMonthRange(DateTime month) {
    state = state.copyWith(
      granularity: BillStatsGranularity.month,
      focusMonth: DateTime(month.year, month.month, 1),
      focusDay: null,
      customRangeStart: null,
      customRangeEnd: null,
    );
  }

  void setFocusDay(DateTime? day) {
    state = state.copyWith(focusDay: day == null ? null : DateTime(day.year, day.month, day.day));
  }

  void setCustomRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    final rangeStart =
        normalizedStart.isAfter(normalizedEnd) ? normalizedEnd : normalizedStart;
    final rangeEnd =
        normalizedStart.isAfter(normalizedEnd) ? normalizedStart : normalizedEnd;
    state = state.copyWith(
      granularity: BillStatsGranularity.custom,
      focusMonth: DateTime(rangeStart.year, rangeStart.month, 1),
      focusDay: rangeStart,
      customRangeStart: rangeStart,
      customRangeEnd: rangeEnd,
    );
  }

  void setChartKind(BillStatsChartKind k) {
    state = state.copyWith(chartKind: k);
  }

  void setStatsCategoryKey(String? key) {
    state = state.copyWith(statsCategoryKey: key);
  }

  void setDualExpenseLinesInMerged(bool value) {
    if (state.ledgerView != BillLedgerView.merged) {
      state = state.copyWith(dualExpenseLinesInMerged: false);
      return;
    }
    state = state.copyWith(dualExpenseLinesInMerged: value);
  }

  void setHideIncomeInCharts(bool value) {
    state = state.copyWith(hideIncomeInCharts: value);
  }

  void setHideExpenseInCharts(bool value) {
    state = state.copyWith(hideExpenseInCharts: value);
  }

  (DateTime start, DateTime end) currentRangeBounds() {
    return billStatsRangeBounds(
      state.granularity,
      focusMonth: state.focusMonth,
      focusDay: state.focusDay,
      customStart: state.customRangeStart,
      customEnd: state.customRangeEnd,
    );
  }

  DateTime calendarMonth() {
    final range = currentRangeBounds();
    return DateTime(range.$1.year, range.$1.month, 1);
  }

  /// Records for charts: time range from [granularity], optional [statsCategoryKey], then ledger scope.
  List<BillRecord> recordsForCharts() {
    final records = _visibleRecords(
      records: state.records,
      ledgerView: state.ledgerView,
      filterCategoryKey: _effectiveCategoryKey(),
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    return _withCompatOwners(_recordsWithinCurrentRange(records));
  }

  BillPeriodSummary chartPeriodSummary() {
    return _buildPeriodSummary(recordsForCharts());
  }

  List<BillRecord> recordsForCalendarMonth() {
    final base = _visibleRecords(
      records: state.records,
      ledgerView: state.ledgerView,
      filterCategoryKey: _effectiveCategoryKey(),
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    final month = calendarMonth();
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    return _withCompatOwners(base.where((record) {
      final d = DateTime(record.createdAt.year, record.createdAt.month, record.createdAt.day);
      return !d.isBefore(monthStart) && !d.isAfter(monthEnd);
    }).toList());
  }

  List<BillRecord> visibleRecordsForUi() {
    final visible = _visibleRecords(
      records: state.records,
      ledgerView: state.ledgerView,
      filterCategoryKey: _effectiveCategoryKey(),
      currentUserId: _resolveCurrentUserId(),
      partnerUserId: state.partnerUserId,
    );
    return _withCompatOwners(_recordsWithinCurrentRange(visible));
  }

  String ownerLabelFor(BillRecord record) {
    final me = _normalizedUserId(_resolveCurrentUserId());
    final partner = _normalizedUserId(state.partnerUserId);
    final owner = _effectiveOwnerUserId(
      record: record,
      currentUserId: me,
      partnerUserId: partner,
    );
    if (owner == null) {
      return '未标注';
    }
    if (me != null && owner == me) {
      return '我';
    }
    if (partner != null && owner == partner) {
      return 'TA';
    }
    if (me != null && owner != me) {
      return 'TA';
    }
    return '未标注';
  }

  bool canEdit(BillRecord record) {
    final me = _normalizedUserId(_resolveCurrentUserId());
    if (me == null) {
      return false;
    }
    final owner = _effectiveOwnerUserId(
      record: record,
      currentUserId: me,
      partnerUserId: _normalizedUserId(state.partnerUserId),
    );
    return owner != null && owner == me;
  }

  Future<bool> create({
    required BillType type,
    required String categoryKey,
    required String amountText,
    required String note,
    DateTime? createdAt,
  }) async {
    final coupleId = _resolveCoupleId();
    final me = _resolveCurrentUserId();
    final raw = amountText.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先绑定情侣关系');
      return false;
    }
    if (me == null || me.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录');
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
    final normalizedKey = BillTagCatalog.normalizeKey(categoryKey);
    if (!BillTagCatalog.isValidForType(normalizedKey, type)) {
      state = state.copyWith(errorMessage: '请选择有效标签');
      return false;
    }

    final now = DateTime.now();
    final created = createdAt == null
        ? now
        : DateTime(
            createdAt.year,
            createdAt.month,
            createdAt.day,
            now.hour,
            now.minute,
            now.second,
          );
    final optimistic = BillRecord(
      id: 'bill-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      ownerUserId: me,
      type: type,
      categoryKey: normalizedKey,
      amount: amount,
      note: note.trim(),
      createdAt: created,
      updatedAt: now,
      isDeleted: false,
      pendingSync: true,
    );

    final nextRecords = [optimistic, ...state.records];
    final visible = _visibleRecords(
      records: nextRecords,
      ledgerView: state.ledgerView,
      filterCategoryKey: state.filterCategoryKey,
      currentUserId: me,
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      records: nextRecords,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
      errorMessage: null,
    );

    try {
      final saved = await _insertBillRecord(optimistic);
      final merged = [
        saved,
        ...state.records.where((item) => item.id != optimistic.id),
      ];
      final vis = _visibleRecords(
        records: merged,
        ledgerView: state.ledgerView,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: me,
        partnerUserId: state.partnerUserId,
      );
      state = state.copyWith(
        records: merged,
        summary: _buildSummary(_recordsWithinCurrentRange(vis)),
      );
      await _addFeedEvent(
        eventType: FeedEventType.billCreated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.billCreated(
          categoryLabel: saved.categoryDisplayLabel,
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
    if (!canEdit(record)) {
      state = state.copyWith(errorMessage: '不能修改对方的账单');
      return;
    }
    final me = _resolveCurrentUserId() ?? '';
    final optimistic = record.copyWith(
      ownerUserId: record.ownerUserId.trim().isEmpty ? me : record.ownerUserId,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    final next = [
      for (final item in state.records)
        if (item.id == record.id) optimistic else item,
    ];
    final visible = _visibleRecords(
      records: next,
      ledgerView: state.ledgerView,
      filterCategoryKey: state.filterCategoryKey,
      currentUserId: me.isEmpty ? null : me,
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      records: next,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
      errorMessage: null,
    );

    try {
      final saved = await _updateBillRecord(optimistic);
      final merged = [
        for (final item in state.records)
          if (item.id == record.id) saved else item,
      ];
      final vis = _visibleRecords(
        records: merged,
        ledgerView: state.ledgerView,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: me.isEmpty ? null : me,
        partnerUserId: state.partnerUserId,
      );
      state = state.copyWith(
        records: merged,
        summary: _buildSummary(_recordsWithinCurrentRange(vis)),
      );
      await _addFeedEvent(
        eventType: FeedEventType.billUpdated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.billUpdated(
          categoryLabel: saved.categoryDisplayLabel,
          amount: saved.amount,
        ),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '更新账单失败');
    }
  }

  Future<void> delete(BillRecord record) async {
    if (!canEdit(record)) {
      state = state.copyWith(errorMessage: '不能删除对方的账单');
      return;
    }
    final me = _resolveCurrentUserId() ?? '';
    if (me.isEmpty) {
      state = state.copyWith(errorMessage: '请先登录');
      return;
    }
    final deleted = record.copyWith(
      ownerUserId: record.ownerUserId.trim().isEmpty ? me : record.ownerUserId,
      isDeleted: true,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    final next = [
      for (final item in state.records)
        if (item.id == record.id) deleted else item,
    ];
    final visible = _visibleRecords(
      records: next,
      ledgerView: state.ledgerView,
      filterCategoryKey: state.filterCategoryKey,
      currentUserId: me,
      partnerUserId: state.partnerUserId,
    );
    state = state.copyWith(
      records: next,
      summary: _buildSummary(_recordsWithinCurrentRange(visible)),
      errorMessage: null,
    );
    try {
      await _deleteBillRecord(
        id: record.id,
        coupleId: record.coupleId,
        updatedAt: deleted.updatedAt,
        actorUserId: me,
      );
      final kept = state.records.where((item) => !item.isDeleted).toList();
      final vis = _visibleRecords(
        records: kept,
        ledgerView: state.ledgerView,
        filterCategoryKey: state.filterCategoryKey,
        currentUserId: me,
        partnerUserId: state.partnerUserId,
      );
      state = state.copyWith(
        records: kept,
        summary: _buildSummary(_recordsWithinCurrentRange(vis)),
      );
      await _addFeedEvent(
        eventType: FeedEventType.billDeleted,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.bill,
        targetId: record.id,
        summaryText: FeedSummaryBuilder.billDeleted(
          categoryLabel: record.categoryDisplayLabel,
          amount: record.amount,
        ),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '删除账单失败');
    }
  }

  List<BillRecord> _visibleRecords({
    required List<BillRecord> records,
    required BillLedgerView ledgerView,
    required String? filterCategoryKey,
    required String? currentUserId,
    required String? partnerUserId,
  }) {
    Iterable<BillRecord> rows = records.where((record) => !record.isDeleted);
    final normalizedMe = _normalizedUserId(currentUserId);
    final normalizedPartner = _normalizedUserId(partnerUserId);
    switch (ledgerView) {
      case BillLedgerView.mine:
        if (normalizedMe != null) {
          rows = rows.where(
            (record) => _sameOwner(
              record: record,
              expectedUserId: normalizedMe,
              currentUserId: normalizedMe,
              partnerUserId: normalizedPartner,
            ),
          );
        } else {
          rows = rows.where((_) => false);
        }
        break;
      case BillLedgerView.partner:
        if (normalizedPartner != null) {
          rows = rows.where(
            (record) => _sameOwner(
              record: record,
              expectedUserId: normalizedPartner,
              currentUserId: normalizedMe,
              partnerUserId: normalizedPartner,
            ),
          );
        } else {
          rows = rows.where((_) => false);
        }
        break;
      case BillLedgerView.merged:
        break;
    }
    if (filterCategoryKey != null && filterCategoryKey.isNotEmpty) {
      final rawFilter = filterCategoryKey.trim();
      if (rawFilter.contains('.')) {
        final normalizedFilter = BillTagCatalog.normalizeKey(rawFilter);
        rows = rows.where(
          (record) => BillTagCatalog.normalizeKey(record.categoryKey) == normalizedFilter,
        );
      } else {
        rows = rows.where(
          (record) => BillTagCatalog.normalizeKey(record.categoryKey).startsWith('$rawFilter.'),
        );
      }
    }
    return rows.toList();
  }

  List<BillRecord> _recordsWithinCurrentRange(List<BillRecord> records) {
    return _recordsWithinRange(records, currentRangeBounds());
  }

  List<BillRecord> _recordsWithinRange(
    List<BillRecord> records,
    (DateTime start, DateTime end) range,
  ) {
    final start = range.$1;
    final end = range.$2;
    final startD = DateTime(start.year, start.month, start.day);
    final endD = DateTime(end.year, end.month, end.day);
    return records.where((record) {
      final day = DateTime(
        record.createdAt.year,
        record.createdAt.month,
        record.createdAt.day,
      );
      return !day.isBefore(startD) && !day.isAfter(endD);
    }).toList();
  }

  String? _normalizedUserId(String? raw) {
    final id = raw?.trim() ?? '';
    return id.isEmpty ? null : id;
  }

  bool _sameOwner({
    required BillRecord record,
    required String expectedUserId,
    required String? currentUserId,
    required String? partnerUserId,
  }) {
    final eff = _effectiveOwnerUserId(
      record: record,
      currentUserId: currentUserId,
      partnerUserId: partnerUserId,
    );
    if (eff == null) {
      return false;
    }
    return eff == expectedUserId;
  }

  /// Null owner = legacy / unknown → only **merged** ledger matches; never guess "我".
  String? _effectiveOwnerUserId({
    required BillRecord record,
    required String? currentUserId,
    required String? partnerUserId,
  }) {
    final owner = _normalizedUserId(record.ownerUserId);
    if (owner != null) {
      return owner;
    }
    return null;
  }

  List<BillRecord> _withCompatOwners(List<BillRecord> records) {
    final me = _normalizedUserId(_resolveCurrentUserId());
    if (me == null) {
      return records;
    }
    return records
        .map(
          (record) => record.ownerUserId.trim().isEmpty
              ? record.copyWith(ownerUserId: me)
              : record,
        )
        .toList();
  }

  String? _normalizeFilterKey(String? key) {
    final raw = key?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    if (!raw.contains('.')) {
      return raw;
    }
    return BillTagCatalog.normalizeKey(raw);
  }

  (String?, String?) _splitCategoryKey(String? key) {
    if (key == null || key.isEmpty) {
      return (null, null);
    }
    final parts = key.split('.');
    if (parts.length == 1) {
      return (parts.first, null);
    }
    if (parts.length != 2) {
      return (null, null);
    }
    return (parts.first, parts.last);
  }

  String? _effectiveCategoryKey() {
    if (state.selectedParentKey == null || state.selectedParentKey!.isEmpty) {
      return null;
    }
    final child = state.selectedChildKey;
    if (child == null || child.isEmpty) {
      return state.selectedParentKey;
    }
    return '${state.selectedParentKey}.${state.selectedChildKey}';
  }

  BillSummary _buildSummary(List<BillRecord> records) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));
    final monthStart = DateTime(now.year, now.month, 1);
    return BillSummary(
      overall: _buildPeriodSummary(records),
      currentWeek: _buildPeriodSummary(
        records.where((item) => !item.createdAt.isBefore(weekStart)).toList(),
      ),
      currentMonth: _buildPeriodSummary(
        records.where((item) => !item.createdAt.isBefore(monthStart)).toList(),
      ),
    );
  }

  BillPeriodSummary _buildPeriodSummary(List<BillRecord> records) {
    double incomeTotal = 0;
    double expenseTotal = 0;
    final expenseByCategoryKey = <String, double>{};
    for (final record in records) {
      if (record.type == BillType.income) {
        incomeTotal += record.amount;
      } else {
        expenseTotal += record.amount;
        final key = BillTagCatalog.normalizeKey(record.categoryKey);
        expenseByCategoryKey.update(
          key,
          (value) => value + record.amount,
          ifAbsent: () => record.amount,
        );
      }
    }
    final sorted = expenseByCategoryKey.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BillPeriodSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      balance: incomeTotal - expenseTotal,
      expenseByCategoryKey: Map<String, double>.fromEntries(sorted),
      recordCount: records.length,
    );
  }
}

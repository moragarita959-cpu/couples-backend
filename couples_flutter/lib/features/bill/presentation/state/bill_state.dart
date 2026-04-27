import '../../domain/bill_stats_models.dart';
import '../../domain/entities/bill_record.dart';

export '../../domain/bill_stats_models.dart'
    show BillStatsGranularity, BillStatsChartKind;

const Object _unset = Object();

enum BillLedgerView {
  merged,
  mine,
  partner,
}

class BillState {
  BillState({
    this.records = const <BillRecord>[],
    this.summary = const BillSummary.empty(),
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.ledgerView = BillLedgerView.merged,
    this.filterCategoryKey,
    this.statsCategoryKey,
    this.selectedParentKey,
    this.selectedChildKey,
    this.granularity = BillStatsGranularity.month,
    this.chartKind = BillStatsChartKind.line,
    this.dualExpenseLinesInMerged = true,
    this.hideIncomeInCharts = false,
    this.hideExpenseInCharts = false,
    this.partnerUserId,
    DateTime? focusMonth,
    this.focusDay,
    DateTime? customRangeStart,
    DateTime? customRangeEnd,
  }) : focusMonth = focusMonth == null
          ? DateTime(DateTime.now().year, DateTime.now().month, 1)
          : DateTime(focusMonth.year, focusMonth.month, 1),
       customRangeStart = customRangeStart == null
          ? null
          : DateTime(
              customRangeStart.year,
              customRangeStart.month,
              customRangeStart.day,
            ),
       customRangeEnd = customRangeEnd == null
          ? null
          : DateTime(
              customRangeEnd.year,
              customRangeEnd.month,
              customRangeEnd.day,
            );

  final List<BillRecord> records;
  final BillSummary summary;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final BillLedgerView ledgerView;
  /// List filter (明细列表).
  final String? filterCategoryKey;
  /// Chart-only tag filter; null = all tags in chart aggregation.
  final String? statsCategoryKey;
  /// Unified list/chart parent tag filter; null = all parents.
  final String? selectedParentKey;
  /// Unified list/chart child tag filter; null = all children under parent/all.
  final String? selectedChildKey;
  final BillStatsGranularity granularity;
  final BillStatsChartKind chartKind;
  /// Merged ledger: show two expense lines (me vs TA) on line chart.
  final bool dualExpenseLinesInMerged;
  final bool hideIncomeInCharts;
  final bool hideExpenseInCharts;
  final String? partnerUserId;
  final DateTime focusMonth;
  final DateTime? focusDay;
  final DateTime? customRangeStart;
  final DateTime? customRangeEnd;

  BillState copyWith({
    List<BillRecord>? records,
    BillSummary? summary,
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _unset,
    BillLedgerView? ledgerView,
    Object? filterCategoryKey = _unset,
    Object? statsCategoryKey = _unset,
    Object? selectedParentKey = _unset,
    Object? selectedChildKey = _unset,
    BillStatsGranularity? granularity,
    BillStatsChartKind? chartKind,
    bool? dualExpenseLinesInMerged,
    bool? hideIncomeInCharts,
    bool? hideExpenseInCharts,
    Object? partnerUserId = _unset,
    DateTime? focusMonth,
    Object? focusDay = _unset,
    Object? customRangeStart = _unset,
    Object? customRangeEnd = _unset,
  }) {
    return BillState(
      records: records ?? this.records,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      ledgerView: ledgerView ?? this.ledgerView,
      filterCategoryKey: filterCategoryKey == _unset
          ? this.filterCategoryKey
          : filterCategoryKey as String?,
      statsCategoryKey: statsCategoryKey == _unset
          ? this.statsCategoryKey
          : statsCategoryKey as String?,
      selectedParentKey: selectedParentKey == _unset
          ? this.selectedParentKey
          : selectedParentKey as String?,
      selectedChildKey: selectedChildKey == _unset
          ? this.selectedChildKey
          : selectedChildKey as String?,
      granularity: granularity ?? this.granularity,
      chartKind: chartKind ?? this.chartKind,
      dualExpenseLinesInMerged:
          dualExpenseLinesInMerged ?? this.dualExpenseLinesInMerged,
      hideIncomeInCharts: hideIncomeInCharts ?? this.hideIncomeInCharts,
      hideExpenseInCharts: hideExpenseInCharts ?? this.hideExpenseInCharts,
      partnerUserId: partnerUserId == _unset
          ? this.partnerUserId
          : partnerUserId as String?,
      focusMonth: focusMonth ?? this.focusMonth,
      focusDay: focusDay == _unset ? this.focusDay : focusDay as DateTime?,
      customRangeStart: customRangeStart == _unset
          ? this.customRangeStart
          : customRangeStart as DateTime?,
      customRangeEnd: customRangeEnd == _unset
          ? this.customRangeEnd
          : customRangeEnd as DateTime?,
    );
  }
}

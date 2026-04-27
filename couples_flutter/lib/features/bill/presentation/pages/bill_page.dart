import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../couple/presentation/state/couple_state.dart';
import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../state/bill_controller.dart';
import '../state/bill_state.dart';
import '../widgets/bill_add_sheet.dart';
import '../widgets/bill_charts_panel.dart';
import '../widgets/bill_theme.dart';

class BillPage extends ConsumerStatefulWidget {
  const BillPage({super.key});

  @override
  ConsumerState<BillPage> createState() => _BillPageState();
}

class _BillPageState extends ConsumerState<BillPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _heroCtrl;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshBills();
      }
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshBills();
    }
  }

  Future<void> _refreshBills() async {
    await ref.read(billControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    await ref.read(homeSummaryControllerProvider.notifier).load();
  }

  String _statsSectionLabel(BillState state) {
    final base = switch (state.granularity) {
      BillStatsGranularity.day => '统计 · 当日',
      BillStatsGranularity.week => '统计 · 本周',
      BillStatsGranularity.month => '统计 · 本月',
      BillStatsGranularity.year => '统计 · 本年',
      BillStatsGranularity.last30 => '统计 · 近30日',
      BillStatsGranularity.custom => '统计 · 自定义',
    };
    final tag = state.statsCategoryKey;
    if (tag == null || tag.isEmpty) {
      return base;
    }
    return '$base · ${BillTagCatalog.displayLabel(tag)}';
  }

  String _rangeLabel(BillState state) {
    String dateLabel(DateTime value) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }

    final range = ref.read(billControllerProvider.notifier).currentRangeBounds();
    return switch (state.granularity) {
      BillStatsGranularity.day => '今天 · ${dateLabel(range.$1)}',
      BillStatsGranularity.week =>
        '本周 · ${dateLabel(range.$1)} 至 ${dateLabel(range.$2)}',
      BillStatsGranularity.month =>
        '月份 · ${state.focusMonth.year}-${state.focusMonth.month.toString().padLeft(2, '0')}',
      BillStatsGranularity.year => '本年 · ${state.focusMonth.year}',
      BillStatsGranularity.last30 =>
        '近30日 · ${dateLabel(range.$1)} 至 ${dateLabel(range.$2)}',
      BillStatsGranularity.custom =>
        '自定义 · ${dateLabel(range.$1)} 至 ${dateLabel(range.$2)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CoupleState>(coupleControllerProvider, (prev, next) {
      final prevPartner = prev?.profile?.partnerUserId;
      final nextPartner = next.profile?.partnerUserId;
      final prevCouple = prev?.profile?.coupleId;
      final nextCouple = next.profile?.coupleId;
      if (prevPartner != nextPartner || prevCouple != nextCouple) {
        Future<void>.microtask(
          () => ref.read(billControllerProvider.notifier).loadAll(),
        );
      }
    });

    final state = ref.watch(billControllerProvider);
    final controller = ref.read(billControllerProvider.notifier);
    final me = ref.read(currentUserIdResolverProvider)();
    final visible = controller.visibleRecordsForUi();
    final chartRows = controller.recordsForCharts();
    final calendarRows = controller.recordsForCalendarMonth();
    final chartSummary = controller.chartPeriodSummary();
    final chartRange = controller.currentRangeBounds();
    final calendarMonth = controller.calendarMonth();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('记账'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: (value) {
              switch (value) {
                case 'merged':
                  controller.setLedgerView(BillLedgerView.merged);
                  break;
                case 'mine':
                  controller.setLedgerView(BillLedgerView.mine);
                  break;
                case 'partner':
                  controller.setLedgerView(BillLedgerView.partner);
                  break;
                case 'week':
                  controller.setQuickRange(BillStatsGranularity.week);
                  break;
                case 'month':
                  controller.setQuickRange(BillStatsGranularity.month);
                  break;
                case 'day':
                  controller.setQuickRange(BillStatsGranularity.day);
                  break;
                case 'year':
                  controller.setQuickRange(BillStatsGranularity.year);
                  break;
                case 'last30':
                  controller.setQuickRange(BillStatsGranularity.last30);
                  break;
                case 'dual':
                  controller.setDualExpenseLinesInMerged(!state.dualExpenseLinesInMerged);
                  break;
                case 'clearStatsTag':
                  controller.setStatsCategoryKey(null);
                  break;
                case 'clearListTag':
                  controller.setFilterCategoryKey(null);
                  break;
              }
            },
            itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                enabled: false,
                child: Text('账本视图', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              CheckedPopupMenuItem<String>(
                value: 'merged',
                checked: state.ledgerView == BillLedgerView.merged,
                child: const Text('合并（只读对方）'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'mine',
                checked: state.ledgerView == BillLedgerView.mine,
                child: const Text('我的账本'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'partner',
                checked: state.ledgerView == BillLedgerView.partner,
                child: const Text('TA 的账本'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                enabled: false,
                child: Text('统计周期', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              CheckedPopupMenuItem<String>(
                value: 'day',
                checked: state.granularity == BillStatsGranularity.day,
                child: const Text('按日'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'week',
                checked: state.granularity == BillStatsGranularity.week,
                child: const Text('按周'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'month',
                checked: state.granularity == BillStatsGranularity.month,
                child: const Text('按月'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'year',
                checked: state.granularity == BillStatsGranularity.year,
                child: const Text('按年'),
              ),
              CheckedPopupMenuItem<String>(
                value: 'last30',
                checked: state.granularity == BillStatsGranularity.last30,
                child: const Text('近30日'),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem<String>(
                value: 'dual',
                checked: state.dualExpenseLinesInMerged,
                enabled: state.ledgerView == BillLedgerView.merged,
                child: const Text('合并视图：双支出曲线'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'clearStatsTag',
                child: Text('清除统计标签筛选'),
              ),
              const PopupMenuItem<String>(
                value: 'clearListTag',
                child: Text('清除列表标签筛选'),
              ),
            ],
          ),
          IconButton(
            tooltip: '列表标签筛选',
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _openListTagFilter(context, controller),
          ),
          IconButton(
            tooltip: '统计标签筛选',
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => _openStatsTagFilter(context, controller),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutBack),
        child: FloatingActionButton.extended(
          onPressed: () => showBillAddSheet(
            context: context,
            controller: controller,
            onSaved: _refreshBills,
          ),
          backgroundColor: BillTheme.me,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('记一笔'),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: BillTheme.pageGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshBills,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ListView(
                key: ValueKey<String>(
                  '${state.ledgerView}-${state.filterCategoryKey}-${state.statsCategoryKey}-${state.chartKind}-${state.granularity}-${state.focusMonth}-${state.focusDay}-${state.customRangeStart}-${state.customRangeEnd}',
                ),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                children: <Widget>[
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic)),
                      child: _SummaryStrip(
                        summary: chartSummary,
                        headerLabel: _statsSectionLabel(state),
                        ledgerView: state.ledgerView,
                      ),
                    ),
                  ),
                  _TimeRangeBar(
                    label: _rangeLabel(state),
                    granularity: state.granularity,
                    onPrev: () => controller.shiftRange(-1),
                    onNext: () => controller.shiftRange(1),
                    onToday: () =>
                        controller.setQuickRange(BillStatsGranularity.day),
                    onWeek: () =>
                        controller.setQuickRange(BillStatsGranularity.week),
                    onMonth: () =>
                        controller.setQuickRange(BillStatsGranularity.month),
                    onYear: () =>
                        controller.setQuickRange(BillStatsGranularity.year),
                    onPickMonth: () => _pickMonth(context, controller),
                    onCustom: () => _pickCustomRange(context, controller),
                  ),
                  const SizedBox(height: 8),
                  if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.97, end: 1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: _ChartsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SegmentedButton<BillStatsChartKind>(
                            segments: const <ButtonSegment<BillStatsChartKind>>[
                              ButtonSegment<BillStatsChartKind>(
                                value: BillStatsChartKind.line,
                                label: Text('折线'),
                                icon: Icon(Icons.show_chart, size: 18),
                              ),
                              ButtonSegment<BillStatsChartKind>(
                                value: BillStatsChartKind.pie,
                                label: Text('扇形'),
                                icon: Icon(Icons.pie_chart_outline, size: 18),
                              ),
                            ],
                            selected: <BillStatsChartKind>{state.chartKind},
                            onSelectionChanged: (s) {
                              controller.setChartKind(s.first);
                            },
                          ),
                          const SizedBox(height: 10),
                          if (state.chartKind == BillStatsChartKind.line) ...<Widget>[
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: <Widget>[
                                if (!(state.ledgerView == BillLedgerView.merged &&
                                    state.dualExpenseLinesInMerged))
                                  FilterChip(
                                    label: const Text('隐藏收入线'),
                                    selected: state.hideIncomeInCharts,
                                    onSelected: (v) => controller.setHideIncomeInCharts(v),
                                    selectedColor: BillTheme.income.withValues(alpha: 0.2),
                                    checkmarkColor: BillTheme.income,
                                  ),
                                FilterChip(
                                  label: const Text('隐藏支出线'),
                                  selected: state.hideExpenseInCharts,
                                  onSelected: (v) => controller.setHideExpenseInCharts(v),
                                  selectedColor: BillTheme.expense.withValues(alpha: 0.2),
                                  checkmarkColor: BillTheme.expense,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          BillChartsPanel(
                            records: chartRows,
                            granularity: state.granularity,
                            rangeStart: chartRange.$1,
                            rangeEnd: chartRange.$2,
                            chartKind: state.chartKind,
                            hideIncome: state.hideIncomeInCharts,
                            hideExpense: state.hideExpenseInCharts,
                            ledgerView: state.ledgerView,
                            dualExpenseLinesInMerged: state.dualExpenseLinesInMerged,
                            currentUserId: me,
                            partnerUserId: state.partnerUserId,
                            selectedParentKey: state.selectedParentKey,
                            selectedChildKey: state.selectedChildKey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChartsCard(
                    child: _CalendarHeatmap(
                      month: calendarMonth,
                      rows: calendarRows,
                      selectedDay: state.focusDay,
                      onTapDay: (day) {
                        controller.setFocusDay(day);
                        controller.setGranularity(BillStatsGranularity.day);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '账目明细',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('暂无记录')),
                    )
                  else
                    ...visible.map((BillRecord r) {
                      final ownerLabel = controller.ownerLabelFor(r);
                      final isMine = ownerLabel == '我';
                      return _BillRecordCard(
                        record: r,
                        ownerLabel: ownerLabel,
                        ownerAccent: isMine ? BillTheme.me : BillTheme.partner,
                        canDelete: controller.canEdit(r),
                        canEdit: controller.canEdit(r),
                        onEdit: () => showBillAddSheet(
                          context: context,
                          controller: controller,
                          editing: r,
                          onSaved: _refreshBills,
                        ),
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text('删除账目'),
                                content: const Text('删除后会同步到双方账本。'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('删除'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed == true) {
                            await controller.delete(r);
                            await _refreshBills();
                          }
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openListTagFilter(
    BuildContext context,
    BillController controller,
  ) async {
    final state = ref.read(billControllerProvider);
    final picked = await _pickTag(
      context,
      state.selectedParentKey,
      state.selectedChildKey,
    );
    if (picked == null) {
      return;
    }
    controller.setTagSelection(
      parentKey: picked.$1,
      childKey: picked.$2,
    );
  }

  Future<void> _pickMonth(
    BuildContext context,
    BillController controller,
  ) async {
    final state = ref.read(billControllerProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.focusMonth,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null) {
      return;
    }
    controller.setMonthRange(picked);
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    BillController controller,
  ) async {
    final bounds = controller.currentRangeBounds();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: bounds.$1, end: bounds.$2),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null) {
      return;
    }
    controller.setCustomRange(picked.start, picked.end);
  }

  Future<void> _openStatsTagFilter(
    BuildContext context,
    BillController controller,
  ) async {
    final state = ref.read(billControllerProvider);
    final picked = await _pickTag(
      context,
      state.selectedParentKey,
      state.selectedChildKey,
    );
    if (picked == null) {
      return;
    }
    controller.setTagSelection(
      parentKey: picked.$1,
      childKey: picked.$2,
    );
  }

  Future<(String?, String?)?> _pickTag(
    BuildContext context,
    String? currentParent,
    String? currentChild,
  ) {
    return showModalBottomSheet<(String?, String?)>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              ListTile(
                title: const Text('全部标签'),
                trailing: currentParent == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, (null, null)),
              ),
              for (final p in BillTagCatalog.parents)
                ...<Widget>[
                  ListTile(
                    leading: Icon(p.icon, color: p.color, size: 20),
                    title: Text(p.label),
                    trailing:
                        currentParent == p.key && currentChild == null
                            ? const Icon(Icons.check)
                            : null,
                    onTap: () => Navigator.pop(ctx, (p.key, null)),
                  ),
                  ...p.children.map(
                    (c) {
                      final childKey = c.key;
                      final selected =
                          currentParent == p.key && currentChild == childKey;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 40, right: 16),
                        leading: Icon(p.icon, color: p.color, size: 16),
                        title: Text(c.label),
                        trailing: selected ? const Icon(Icons.check) : null,
                        onTap: () => Navigator.pop(ctx, (p.key, childKey)),
                      );
                    },
                  ),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.summary,
    required this.headerLabel,
    required this.ledgerView,
  });

  final BillPeriodSummary summary;
  final String headerLabel;
  final BillLedgerView ledgerView;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: ledgerView == BillLedgerView.mine
              ? <Color>[
                  Colors.white,
                  BillTheme.me.withValues(alpha: 0.13),
                  BillTheme.me.withValues(alpha: 0.06),
                ]
              : ledgerView == BillLedgerView.partner
                  ? <Color>[
                      Colors.white,
                      BillTheme.partner.withValues(alpha: 0.13),
                      BillTheme.partner.withValues(alpha: 0.06),
                    ]
                  : <Color>[
                      Colors.white,
                      BillTheme.me.withValues(alpha: 0.1),
                      BillTheme.partner.withValues(alpha: 0.1),
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            headerLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E6880),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _metric('收入', summary.incomeTotal, BillTheme.income),
              const SizedBox(width: 10),
              _metric('支出', summary.expenseTotal, BillTheme.expense),
              const SizedBox(width: 10),
              _metric('结余', summary.balance, BillTheme.partner),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _metric(String label, double value, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6E6880))),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRangeBar extends StatelessWidget {
  const _TimeRangeBar({
    required this.label,
    required this.granularity,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onWeek,
    required this.onMonth,
    required this.onYear,
    required this.onPickMonth,
    required this.onCustom,
  });

  final String label;
  final BillStatsGranularity granularity;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onWeek;
  final VoidCallback onMonth;
  final VoidCallback onYear;
  final VoidCallback onPickMonth;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('今天'),
                      selected: granularity == BillStatsGranularity.day,
                      onSelected: (_) => onToday(),
                    ),
                    ChoiceChip(
                      label: const Text('本周'),
                      selected: granularity == BillStatsGranularity.week,
                      onSelected: (_) => onWeek(),
                    ),
                    ChoiceChip(
                      label: const Text('本月'),
                      selected: granularity == BillStatsGranularity.month,
                      onSelected: (_) => onMonth(),
                    ),
                    ChoiceChip(
                      label: const Text('本年'),
                      selected: granularity == BillStatsGranularity.year,
                      onSelected: (_) => onYear(),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('指定月份'),
                      onPressed: onPickMonth,
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.date_range, size: 16),
                      label: const Text('自定义'),
                      selected: granularity == BillStatsGranularity.custom,
                      onSelected: (_) => onCustom(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({
    required this.month,
    required this.rows,
    required this.selectedDay,
    required this.onTapDay,
  });

  final DateTime month;
  final List<BillRecord> rows;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onTapDay;

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final offset = monthStart.weekday - DateTime.monday;
    final totalCells = ((offset + monthEnd.day + 6) ~/ 7) * 7;
    final map = <DateTime, (double income, double expense)>{};
    for (final r in rows) {
      final d = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      final old = map[d] ?? (0, 0);
      map[d] = r.type == BillType.income
          ? (old.$1 + r.amount, old.$2)
          : (old.$1, old.$2 + r.amount);
    }
    final maxFlow = map.values.fold<double>(
      1,
      (m, v) => (v.$1 > v.$2 ? v.$1 : v.$2) > m ? (v.$1 > v.$2 ? v.$1 : v.$2) : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          '日历统计',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final dayNum = index - offset + 1;
            if (dayNum <= 0 || dayNum > monthEnd.day) {
              return const SizedBox.shrink();
            }
            final day = DateTime(month.year, month.month, dayNum);
            final stat = map[day] ?? (0, 0);
            final color = _dayColor(stat.$1, stat.$2, maxFlow);
            final selected = selectedDay != null &&
                DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day) == day;
            return InkWell(
              onTap: () => onTapDay(day),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? const Color(0xFF302B40) : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? const Color(0xFF302B40) : const Color(0xFF4A4559),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _dayColor(double income, double expense, double maxFlow) {
    if (income == 0 && expense == 0) {
      return const Color(0xFFF1F1F5);
    }
    final major = income > expense ? income : expense;
    final t = (major / maxFlow).clamp(0.15, 1.0);
    if (income > expense) {
      return Color.lerp(const Color(0xFFE8F7EE), const Color(0xFF62B986), t)!;
    }
    if (expense > income) {
      return Color.lerp(const Color(0xFFFFECEF), const Color(0xFFDF6B7A), t)!;
    }
    return Color.lerp(const Color(0xFFF3F0FB), const Color(0xFFAC9FD1), t)!;
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x12000000)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _BillRecordCard extends StatelessWidget {
  const _BillRecordCard({
    required this.record,
    required this.ownerLabel,
    required this.ownerAccent,
    required this.canEdit,
    required this.onEdit,
    required this.canDelete,
    required this.onDelete,
  });

  final BillRecord record;
  final String ownerLabel;
  final Color ownerAccent;
  final bool canEdit;
  final VoidCallback onEdit;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tone = ownerAccent;
    final typeColor = record.type == BillType.income ? BillTheme.income : BillTheme.expense;
    final tagColor = BillTagCatalog.colorFor(record.categoryKey);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tone.withValues(alpha: 0.25)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: tone.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: record.type == BillType.income
                      ? const <Color>[Color(0xFF5B8CFF), Color(0xFF37B7AE)]
                      : <Color>[tagColor.withValues(alpha: 0.9), BillTheme.expense],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        record.type == BillType.income ? '收入' : '支出',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.categoryDisplayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: BillTagCatalog.colorFor(record.categoryKey),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        ownerLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (record.note.trim().isNotEmpty) ...<Widget>[
                    Text(
                      record.note,
                      style: const TextStyle(color: Color(0xFF6E6880), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '${record.createdAt.month}/${record.createdAt.day} ${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9A94A9)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (canEdit || canDelete)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(Icons.more_horiz, size: 18),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        onEdit();
                        return;
                      }
                      if (value == 'delete') {
                        await HapticFeedback.lightImpact();
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      if (canEdit)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('编辑'),
                        ),
                      if (canDelete)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('删除'),
                        ),
                    ],
                  ),
                Text(
                  '${record.type == BillType.income ? '+' : '-'}${record.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

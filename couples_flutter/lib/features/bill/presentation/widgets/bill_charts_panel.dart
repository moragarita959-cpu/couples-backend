import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../state/bill_state.dart';
import 'bill_theme.dart';

class BillChartsPanel extends StatelessWidget {
  const BillChartsPanel({
    super.key,
    required this.records,
    required this.granularity,
    required this.rangeStart,
    required this.rangeEnd,
    required this.chartKind,
    required this.hideIncome,
    required this.hideExpense,
    required this.ledgerView,
    required this.dualExpenseLinesInMerged,
    required this.currentUserId,
    required this.partnerUserId,
    required this.selectedParentKey,
    required this.selectedChildKey,
  });

  final List<BillRecord> records;
  final BillStatsGranularity granularity;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final BillStatsChartKind chartKind;
  final bool hideIncome;
  final bool hideExpense;
  final BillLedgerView ledgerView;
  final bool dualExpenseLinesInMerged;
  final String? currentUserId;
  final String? partnerUserId;
  final String? selectedParentKey;
  final String? selectedChildKey;

  @override
  Widget build(BuildContext context) {
    final days = _eachSlots(rangeStart, rangeEnd, granularity);
    final title = switch (granularity) {
      BillStatsGranularity.day => '当日趋势',
      BillStatsGranularity.week => '本周趋势',
      BillStatsGranularity.month => '本月趋势',
      BillStatsGranularity.year => '本年趋势',
      BillStatsGranularity.last30 => '近30日趋势',
      BillStatsGranularity.custom => '自定义趋势',
    };

    final lineSection = _LineSection(
      days: days,
      records: records,
      granularity: granularity,
      hideIncome: hideIncome,
      hideExpense: hideExpense,
      ledgerView: ledgerView,
      dualExpenseLinesInMerged: dualExpenseLinesInMerged,
      currentUserId: currentUserId,
      partnerUserId: partnerUserId,
      title: title,
    );

    final compareIncomeInMerged = ledgerView == BillLedgerView.merged &&
        hideExpense &&
        !hideIncome;
    final pieTitle = ledgerView == BillLedgerView.merged
        ? (compareIncomeInMerged ? '双方收入占比' : '双方支出占比')
        : '支出构成';
    final pieSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          pieTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        if (ledgerView == BillLedgerView.merged &&
            currentUserId != null &&
            partnerUserId != null)
          _PieCard(
            title: compareIncomeInMerged ? '收入对比' : '支出对比',
            tone: compareIncomeInMerged ? BillTheme.income : BillTheme.expense,
            sections: _comparisonSections(
              records: records,
              meId: currentUserId!,
              partnerId: partnerUserId!,
              compareType: compareIncomeInMerged ? BillType.income : BillType.expense,
            ),
          )
        else
          _PieCard(
            title: '支出',
            tone: BillTheme.expense,
            sections: _pieSections(
              records,
              selectedParentKey: selectedParentKey,
              selectedChildKey: selectedChildKey,
            ),
          ),
      ],
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>('chart-${chartKind.name}'),
        child: chartKind == BillStatsChartKind.line
            ? lineSection
            : pieSection,
      ),
    );
  }

  List<DateTime> _eachSlots(
    DateTime start,
    DateTime end,
    BillStatsGranularity granularity,
  ) {
    if (granularity == BillStatsGranularity.year) {
      return List<DateTime>.generate(
        12,
        (i) => DateTime(start.year, i + 1, 1),
      );
    }
    final out = <DateTime>[];
    var d = DateTime(start.year, start.month, start.day);
    final endD = DateTime(end.year, end.month, end.day);
    while (!d.isAfter(endD)) {
      out.add(d);
      d = d.add(const Duration(days: 1));
    }
    return out.isEmpty ? <DateTime>[DateTime.now()] : out;
  }
}

class _LineSection extends StatelessWidget {
  const _LineSection({
    required this.days,
    required this.records,
    required this.granularity,
    required this.hideIncome,
    required this.hideExpense,
    required this.ledgerView,
    required this.dualExpenseLinesInMerged,
    required this.currentUserId,
    required this.partnerUserId,
    required this.title,
  });

  final List<DateTime> days;
  final List<BillRecord> records;
  final BillStatsGranularity granularity;
  final bool hideIncome;
  final bool hideExpense;
  final BillLedgerView ledgerView;
  final bool dualExpenseLinesInMerged;
  final String? currentUserId;
  final String? partnerUserId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final showDualExpense = dualExpenseLinesInMerged &&
        ledgerView == BillLedgerView.merged &&
        currentUserId != null &&
        partnerUserId != null;
    final effectiveHideIncome = hideIncome || showDualExpense;

    final spotsIncome = _spotsForGranularity(days, records, BillType.income, null, granularity);
    final spotsExpense = showDualExpense && !hideExpense
        ? <FlSpot>[]
        : _spotsForGranularity(days, records, BillType.expense, null, granularity);
    final spotsExpMe = showDualExpense && !hideExpense
        ? _spotsForGranularity(days, records, BillType.expense, currentUserId, granularity)
        : <FlSpot>[];
    final spotsExpPartner = showDualExpense && !hideExpense
        ? _spotsForGranularity(days, records, BillType.expense, partnerUserId, granularity)
        : <FlSpot>[];
    final meHasExpense = spotsExpMe.any((spot) => spot.y > 0);
    final partnerHasExpense = spotsExpPartner.any((spot) => spot.y > 0);

    final bars = <LineChartBarData>[];
    if (!effectiveHideIncome) {
      bars.add(
        LineChartBarData(
          spots: spotsIncome,
          color: BillTheme.income,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: BillTheme.income.withValues(alpha: 0.12),
          ),
        ),
      );
    }
    if (showDualExpense) {
      if (!hideExpense) {
        bars.add(
          LineChartBarData(
            spots: spotsExpMe,
            color: BillTheme.me,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: BillTheme.me.withValues(alpha: 0.1),
            ),
          ),
        );
        bars.add(
          LineChartBarData(
            spots: spotsExpPartner,
            color: BillTheme.partner,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: BillTheme.partner.withValues(alpha: 0.1),
            ),
          ),
        );
      }
    } else if (!hideExpense) {
      bars.add(
        LineChartBarData(
          spots: spotsExpense,
          color: BillTheme.expense,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: BillTheme.expense.withValues(alpha: 0.12),
          ),
        ),
      );
    }

    var maxY = 0.0;
    for (final b in bars) {
      for (final s in b.spots) {
        if (s.y > maxY) {
          maxY = s.y;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (showDualExpense && !hideExpense) ...<Widget>[
              _LegendDot(color: BillTheme.me, label: '我·支出'),
              const SizedBox(width: 10),
              _LegendDot(color: BillTheme.partner, label: 'TA·支出'),
            ],
          ],
        ),
        if (showDualExpense &&
            !hideExpense &&
            (!meHasExpense || !partnerHasExpense)) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            !meHasExpense && !partnerHasExpense
                ? '当前时间段双方暂无支出'
                : (!meHasExpense ? '当前时间段我暂无支出' : '当前时间段 TA 暂无支出'),
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A849A)),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: bars.isEmpty
              ? const Center(child: Text('暂无曲线数据'))
              : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (days.length - 1).clamp(0, 999).toDouble(),
                    minY: 0,
                    maxY: maxY <= 0 ? 1 : maxY * 1.08,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY <= 0 ? 1 : maxY / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0x14000000),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) => Text(
                            value >= 1000
                                ? '${(value / 1000).toStringAsFixed(1)}k'
                                : value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8A849A),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (days.length / 5).clamp(1, 99).toDouble(),
                          getTitlesWidget: (value, meta) {
                            final i = value.round().clamp(0, days.length - 1);
                            final d = days[i];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                              granularity == BillStatsGranularity.year
                                  ? '${d.month}月'
                                  : '${d.month}/${d.day}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8A849A),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: bars,
                  ),
                ),
        ),
      ],
    );
  }

  static List<FlSpot> _spotsForGranularity(
    List<DateTime> days,
    List<BillRecord> records,
    BillType type,
    String? ownerId,
    BillStatsGranularity granularity,
  ) {
    final out = <FlSpot>[];
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      var sum = 0.0;
      for (final r in records) {
        if (r.type != type) {
          continue;
        }
        if (ownerId != null && r.ownerUserId != ownerId) {
          continue;
        }
        final rd = granularity == BillStatsGranularity.year
            ? DateTime(r.createdAt.year, r.createdAt.month, 1)
            : DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
        final bucket = granularity == BillStatsGranularity.year
            ? DateTime(day.year, day.month, 1)
            : day;
        if (rd == bucket) {
          sum += r.amount;
        }
      }
      out.add(FlSpot(i.toDouble(), sum));
    }
    return out;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6E6880)),
        ),
      ],
    );
  }
}

List<PieChartSectionData> _pieSections(
  List<BillRecord> rows, {
  String? selectedParentKey,
  String? selectedChildKey,
}) {
  final map = <String, double>{};
  for (final r in rows) {
    if (r.type != BillType.expense) {
      continue;
    }
    final normalized = BillTagCatalog.normalizeKey(r.categoryKey);
    final parts = normalized.split('.');
    if (parts.length != 2) {
      continue;
    }
    if (selectedChildKey != null && selectedChildKey.isNotEmpty) {
      if (parts.first != selectedParentKey || parts.last != selectedChildKey) {
        continue;
      }
    } else if (selectedParentKey != null && selectedParentKey.isNotEmpty) {
      if (parts.first != selectedParentKey) {
        continue;
      }
    }
    final k = (selectedParentKey != null &&
            selectedParentKey.isNotEmpty &&
            (selectedChildKey == null || selectedChildKey.isEmpty))
        ? normalized
        : parts.first;
    map.update(k, (v) => v + r.amount, ifAbsent: () => r.amount);
  }
  if (map.isEmpty) {
    return <PieChartSectionData>[];
  }
  final total = map.values.fold<double>(0, (a, b) => a + b);
  var i = 0;
  return map.entries.map((e) {
    final color = BillTagCatalog.colorFor(e.key).withValues(alpha: 0.85);
    final label = selectedParentKey != null &&
            selectedParentKey.isNotEmpty &&
            (selectedChildKey == null || selectedChildKey.isEmpty)
        ? e.key.split('.').last
        : BillTagCatalog.parentOf(e.key)?.label ?? e.key;
    final t = i++;
    return PieChartSectionData(
      color: color,
      value: e.value,
      title: '$label ${(e.value / total * 100).round()}%',
      radius: 52,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titlePositionPercentageOffset: 0.55 + (t % 3) * 0.02,
    );
  }).toList();
}

List<PieChartSectionData> _comparisonSections({
  required List<BillRecord> records,
  required String meId,
  required String partnerId,
  required BillType compareType,
}) {
  final normalizedMe = meId.trim();
  final normalizedPartner = partnerId.trim();
  if (normalizedMe.isEmpty || normalizedPartner.isEmpty) {
    return <PieChartSectionData>[];
  }
  var meTotal = 0.0;
  var partnerTotal = 0.0;
  for (final record in records) {
    if (record.type != compareType) {
      continue;
    }
    final owner = record.ownerUserId.trim();
    if (owner == normalizedMe) {
      meTotal += record.amount;
    } else if (owner == normalizedPartner) {
      partnerTotal += record.amount;
    }
  }
  final total = meTotal + partnerTotal;
  if (total <= 0) {
    return <PieChartSectionData>[];
  }
  return <PieChartSectionData>[
    PieChartSectionData(
      color: BillTheme.me.withValues(alpha: 0.9),
      value: meTotal,
      title: '我 ${(meTotal / total * 100).round()}%',
      radius: 56,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titlePositionPercentageOffset: 0.6,
    ),
    PieChartSectionData(
      color: BillTheme.partner.withValues(alpha: 0.9),
      value: partnerTotal,
      title: 'TA ${(partnerTotal / total * 100).round()}%',
      radius: 56,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titlePositionPercentageOffset: 0.6,
    ),
  ];
}

class _PieCard extends StatelessWidget {
  const _PieCard({
    required this.title,
    required this.tone,
    required this.sections,
  });

  final String title;
  final Color tone;
  final List<PieChartSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: <Color>[
            tone.withValues(alpha: 0.14),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: <Widget>[
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: tone)),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: sections.isEmpty
                ? Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(color: tone.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 1,
                      centerSpaceRadius: 28,
                      sections: sections,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

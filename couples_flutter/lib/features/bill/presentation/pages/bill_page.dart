import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/bill_record.dart';

class BillPage extends ConsumerStatefulWidget {
  const BillPage({super.key});

  @override
  ConsumerState<BillPage> createState() => _BillPageState();
}

enum _BillStatsRange { week, month, overall }

class _BillPageState extends ConsumerState<BillPage>
    with WidgetsBindingObserver {
  BillType _selectedType = BillType.expense;
  BillCategory _selectedCategory = BillCategory.meals;
  _BillStatsRange _selectedRange = _BillStatsRange.month;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _refreshBills();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _noteController.dispose();
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

  List<BillCategory> get _availableCategories {
    return BillCategoryX.availableFor(_selectedType);
  }

  BillPeriodSummary _summaryForRange(BillSummary summary) {
    switch (_selectedRange) {
      case _BillStatsRange.week:
        return summary.currentWeek;
      case _BillStatsRange.month:
        return summary.currentMonth;
      case _BillStatsRange.overall:
        return summary.overall;
    }
  }

  String _rangeLabel(_BillStatsRange range) {
    switch (range) {
      case _BillStatsRange.week:
        return '本周';
      case _BillStatsRange.month:
        return '本月';
      case _BillStatsRange.overall:
        return '全部';
    }
  }

  Color _typeColor(BillType type) {
    return type == BillType.income
        ? const Color(0xFF68A57C)
        : const Color(0xFFE1888E);
  }

  String _typeLabel(BillType type) {
    return type == BillType.income ? '收入' : '支出';
  }

  Color _categoryColor(BillCategory category) {
    switch (category) {
      case BillCategory.meals:
        return const Color(0xFFE0987C);
      case BillCategory.transport:
        return const Color(0xFF7E9BD6);
      case BillCategory.entertainment:
        return const Color(0xFFBE7CC9);
      case BillCategory.shopping:
        return const Color(0xFFE58BAA);
      case BillCategory.daily:
        return const Color(0xFF8EB291);
      case BillCategory.housing:
        return const Color(0xFF9B8CC6);
      case BillCategory.travel:
        return const Color(0xFF70B7B2);
      case BillCategory.medical:
        return const Color(0xFFD98686);
      case BillCategory.salary:
        return const Color(0xFF6FA27F);
      case BillCategory.bonus:
        return const Color(0xFF7EA990);
      case BillCategory.gift:
        return const Color(0xFFD394B8);
      case BillCategory.other:
        return const Color(0xFF8B879E);
    }
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month/$day  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billControllerProvider);
    final controller = ref.read(billControllerProvider.notifier);
    final rangeSummary = _summaryForRange(state.summary);

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('双人记账'),
        centerTitle: true,
        backgroundColor: CoupleUi.surface,
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: CoupleUi.pageBackgroundDecoration(),
          child: RefreshIndicator(
            onRefresh: _refreshBills,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _SummaryCard(
                    selectedRange: _selectedRange,
                    onRangeChanged: (range) {
                      setState(() {
                        _selectedRange = range;
                      });
                    },
                    rangeSummary: rangeSummary,
                    rangeLabel: _rangeLabel(_selectedRange),
                    categoryColor: _categoryColor,
                  ),
                  const SizedBox(height: 12),
                  _ComposerCard(
                    selectedType: _selectedType,
                    selectedCategory: _selectedCategory,
                    availableCategories: _availableCategories,
                    amountController: _amountController,
                    noteController: _noteController,
                    categoryColor: _categoryColor,
                    typeColor: _typeColor,
                    typeLabel: _typeLabel,
                    onTypeChanged: (type) {
                      setState(() {
                        _selectedType = type;
                        _selectedCategory = BillCategoryX.availableFor(type).first;
                      });
                    },
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    onSubmit: () async {
                      final success = await controller.create(
                        type: _selectedType,
                        category: _selectedCategory,
                        amountText: _amountController.text,
                        note: _noteController.text,
                      );
                      if (!success) {
                        return;
                      }
                      _amountController.clear();
                      _noteController.clear();
                      await _refreshBills();
                    },
                  ),
                  if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _RecordsCard(
                    records: state.records,
                    formatAmount: _formatAmount,
                    formatDate: _formatDate,
                    categoryColor: _categoryColor,
                    typeColor: _typeColor,
                    typeLabel: _typeLabel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.selectedRange,
    required this.onRangeChanged,
    required this.rangeSummary,
    required this.rangeLabel,
    required this.categoryColor,
  });

  final _BillStatsRange selectedRange;
  final ValueChanged<_BillStatsRange> onRangeChanged;
  final BillPeriodSummary rangeSummary;
  final String rangeLabel;
  final Color Function(BillCategory category) categoryColor;

  @override
  Widget build(BuildContext context) {
    final topCategories = rangeSummary.expenseByCategory.entries.take(4).toList();
    final maxExpense = topCategories.isEmpty
        ? 0.0
        : topCategories.first.value <= 0
            ? 0.0
            : topCategories.first.value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '统计总览',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF302B40),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _BillStatsRange.values.map((range) {
              final selected = selectedRange == range;
              return ChoiceChip(
                label: Text(
                  switch (range) {
                    _BillStatsRange.week => '周',
                    _BillStatsRange.month => '月',
                    _BillStatsRange.overall => '全部',
                  },
                ),
                selected: selected,
                onSelected: (_) => onRangeChanged(range),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            rangeLabel,
            style: const TextStyle(
              color: Color(0xFF716B84),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricTile(
                  label: '收入',
                  value: rangeSummary.incomeTotal,
                  color: const Color(0xFF68A57C),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: '支出',
                  value: rangeSummary.expenseTotal,
                  color: const Color(0xFFE1888E),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: '结余',
                  value: rangeSummary.balance,
                  color: const Color(0xFF7C91C8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: CoupleUi.nestedCardDecoration(),
            child: Row(
              children: <Widget>[
                const Text(
                  '记录数',
                  style: TextStyle(
                    color: Color(0xFF615A75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${rangeSummary.recordCount}',
                  style: const TextStyle(
                    color: Color(0xFF302B40),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '支出分类',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A344B),
            ),
          ),
          const SizedBox(height: 10),
          if (topCategories.isEmpty)
            const Text(
              '这个时间范围内还没有支出数据。',
              style: TextStyle(color: Color(0xFF8A849A)),
            )
          else
            Column(
              children: topCategories.map((entry) {
                final progress = maxExpense == 0 ? 0.0 : entry.value / maxExpense;
                final color = categoryColor(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4E4960),
                              ),
                            ),
                          ),
                          Text(
                            entry.value.toStringAsFixed(2),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: progress,
                          backgroundColor: color.withValues(alpha: 0.14),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.selectedType,
    required this.selectedCategory,
    required this.availableCategories,
    required this.amountController,
    required this.noteController,
    required this.categoryColor,
    required this.typeColor,
    required this.typeLabel,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  final BillType selectedType;
  final BillCategory selectedCategory;
  final List<BillCategory> availableCategories;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final Color Function(BillCategory category) categoryColor;
  final Color Function(BillType type) typeColor;
  final String Function(BillType type) typeLabel;
  final ValueChanged<BillType> onTypeChanged;
  final ValueChanged<BillCategory> onCategoryChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '新增账单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF312B41),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: BillType.values.map((type) {
              final selected = selectedType == type;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: type == BillType.income ? 8 : 0),
                  child: ChoiceChip(
                    label: Center(child: Text(typeLabel(type))),
                    selected: selected,
                    selectedColor: typeColor(type).withValues(alpha: 0.16),
                    onSelected: (_) => onTypeChanged(type),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableCategories.map((category) {
              final selected = selectedCategory == category;
              final color = categoryColor(category);
              return ChoiceChip(
                label: Text(category.label),
                selected: selected,
                selectedColor: color.withValues(alpha: 0.16),
                labelStyle: TextStyle(
                  color: selected ? color : const Color(0xFF5B556F),
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => onCategoryChanged(category),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: CoupleUi.inputDecoration(labelText: '金额'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: CoupleUi.inputDecoration(
              labelText: '备注',
              hintText: '这笔账单的备注，可选填写',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: () {
                onSubmit();
              },
              style: CoupleUi.primaryButtonStyle(),
              child: const Text('保存记录'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({
    required this.records,
    required this.formatAmount,
    required this.formatDate,
    required this.categoryColor,
    required this.typeColor,
    required this.typeLabel,
  });

  final List<BillRecord> records;
  final String Function(double value) formatAmount;
  final String Function(DateTime dateTime) formatDate;
  final Color Function(BillCategory category) categoryColor;
  final Color Function(BillType type) typeColor;
  final String Function(BillType type) typeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '最近记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF312B41),
            ),
          ),
          const SizedBox(height: 10),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '还没有账单记录。',
                  style: TextStyle(color: Color(0xFF8B859A)),
                ),
              ),
            )
          else
            Column(
              children: records.map((record) {
                final typeColorValue = typeColor(record.type);
                final categoryColorValue = categoryColor(record.category);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CoupleUi.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: typeColorValue.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 42,
                        decoration: BoxDecoration(
                          color: typeColorValue,
                          borderRadius: BorderRadius.circular(999),
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
                                  typeLabel(record.type),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF363048),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColorValue.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    record.category.label,
                                    style: TextStyle(
                                      color: categoryColorValue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.note.trim().isEmpty ? '暂无备注' : record.note,
                              style: const TextStyle(
                                color: Color(0xFF6E6880),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(record.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF9A94A9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${record.type == BillType.income ? '+' : '-'}${formatAmount(record.amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: typeColorValue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: CoupleUi.nestedCardDecoration(
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF635C78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

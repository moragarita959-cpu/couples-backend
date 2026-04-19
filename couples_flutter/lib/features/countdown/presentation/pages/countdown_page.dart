import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/countdown_event.dart';

class CountdownPage extends ConsumerStatefulWidget {
  const CountdownPage({super.key});

  @override
  ConsumerState<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends ConsumerState<CountdownPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshCountdown();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshCountdown();
    }
  }

  Future<void> _refreshCountdown() async {
    await ref.read(countdownControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    await ref.read(homeSummaryControllerProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countdownControllerProvider);
    final controller = ref.read(countdownControllerProvider.notifier);
    final distanceState = ref.watch(distanceControllerProvider);
    final distanceController = ref.read(distanceControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F8),
      appBar: AppBar(
        title: const Text('纪念日'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEventEditor(context, event: null),
        backgroundColor: const Color(0xFFE88EA3),
        icon: const Icon(Icons.add),
        label: const Text('新增纪念日'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCountdown,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _LoveDaysCard(
                loveDays: state.loveDays,
                loveStartDate: state.settings.loveStartDate,
                loveDaysOverride: state.settings.loveDaysOverride,
                onEdit: () => _openRelationshipSettings(context),
              ),
              const SizedBox(height: 12),
              _DistanceCard(
                isEnabled: distanceState.isEnabled,
                distanceText: distanceState.distanceText,
                onToggle: () async {
                  await distanceController.toggle();
                  await ref.read(homeSummaryControllerProvider.notifier).load();
                },
                onEditText: () => _openDistanceEditor(context),
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                '纪念日列表',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF493038),
                    ),
              ),
              const SizedBox(height: 8),
              if (state.events.isEmpty)
                const _EmptyEventsCard()
              else
                ...state.events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CountdownEventTile(
                      event: event,
                      remainingDays: controller.getRemainingDays(event.date),
                      onEdit: () => _openEventEditor(context, event: event),
                      onDelete: () => _confirmDelete(event),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEventEditor(
    BuildContext context, {
    CountdownEvent? event,
  }) async {
    final nameController = TextEditingController(text: event?.name ?? '');
    DateTime? selectedDate = event?.date;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime(2100, 12, 31),
              );
              if (picked == null) {
                return;
              }
              setSheetState(() {
                selectedDate = DateTime(picked.year, picked.month, picked.day);
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    event == null ? '新增纪念日' : '编辑纪念日',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      selectedDate == null ? '选择日期' : _formatDate(selectedDate!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final ok = event == null
                          ? await ref
                              .read(countdownControllerProvider.notifier)
                              .add(
                                name: nameController.text,
                                date: selectedDate,
                              )
                          : await ref
                              .read(countdownControllerProvider.notifier)
                              .edit(
                                id: event.id,
                                name: nameController.text,
                                date: selectedDate,
                              );
                      if (!ok || !mounted) {
                        return;
                      }
                      await ref.read(homeSummaryControllerProvider.notifier).load();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE88EA3),
                    ),
                    child: Text(event == null ? '保存纪念日' : '保存修改'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _confirmDelete(CountdownEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除纪念日'),
          content: Text('确认从纪念日中删除“${event.name}”吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(countdownControllerProvider.notifier).remove(event.id);
    await ref.read(homeSummaryControllerProvider.notifier).load();
  }

  Future<void> _openRelationshipSettings(BuildContext context) async {
    final state = ref.read(countdownControllerProvider);
    DateTime? startDate = state.settings.loveStartDate;
    final overrideController = TextEditingController(
      text: state.settings.loveDaysOverride?.toString() ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? DateTime.now(),
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime(2100, 12, 31),
              );
              if (picked == null) {
                return;
              }
              setSheetState(() {
                startDate = DateTime(picked.year, picked.month, picked.day);
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '在一起天数设置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: Text(
                      startDate == null
                          ? '选择恋爱开始日期'
                          : '开始日期：${_formatDate(startDate!)}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: overrideController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '手动覆盖天数（可选）',
                      helperText: '留空则按开始日期自动计算',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final ok = await ref
                          .read(countdownControllerProvider.notifier)
                          .saveRelationshipSettings(
                            loveStartDate: startDate,
                            manualLoveDaysText: overrideController.text,
                          );
                      if (!ok || !mounted) {
                        return;
                      }
                      await ref.read(homeSummaryControllerProvider.notifier).load();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE88EA3),
                    ),
                    child: const Text('保存设置'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    overrideController.dispose();
  }

  Future<void> _openDistanceEditor(BuildContext context) async {
    final controller = TextEditingController(
      text: ref.read(distanceControllerProvider).distanceText,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '距离文案',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '距离显示文案',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(distanceControllerProvider.notifier)
                      .saveDistanceText(controller.text);
                  await ref.read(homeSummaryControllerProvider.notifier).load();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF9C6B78),
                ),
                child: const Text('保存距离文案'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  static String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _LoveDaysCard extends StatelessWidget {
  const _LoveDaysCard({
    required this.loveDays,
    required this.loveStartDate,
    required this.loveDaysOverride,
    required this.onEdit,
  });

  final int loveDays;
  final DateTime? loveStartDate;
  final int? loveDaysOverride;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final subtitle = loveDaysOverride != null
        ? '手动覆盖：$loveDaysOverride 天'
        : loveStartDate == null
            ? '正在使用默认恋爱开始日期'
            : '开始于 ${_CountdownPageState._formatDate(loveStartDate!)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Color(0xFFE87D98)),
              const SizedBox(width: 8),
              Text(
                '在一起天数',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('编辑'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$loveDays 天',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF472E35),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF8D7A82),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceCard extends StatelessWidget {
  const _DistanceCard({
    required this.isEnabled,
    required this.distanceText,
    required this.onToggle,
    required this.onEditText,
  });

  final bool isEnabled;
  final String distanceText;
  final Future<void> Function() onToggle;
  final VoidCallback onEditText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '距离显示',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? distanceText : '当前已在首页隐藏',
                      style: const TextStyle(color: Color(0xFF7F6B74)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onEditText,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('编辑距离文案'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  const _EmptyEventsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '还没有纪念日，新增一个重要日子来开始记录吧。',
        style: TextStyle(color: Color(0xFF7E6D74)),
      ),
    );
  }
}

class _CountdownEventTile extends StatelessWidget {
  const _CountdownEventTile({
    required this.event,
    required this.remainingDays,
    required this.onEdit,
    required this.onDelete,
  });

  final CountdownEvent event;
  final int remainingDays;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final remainingText = remainingDays >= 0 ? '还有 $remainingDays 天' : '已过去 ${-remainingDays} 天';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE88EA3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _CountdownPageState._formatDate(event.date),
                  style: const TextStyle(color: Color(0xFF86737A)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                remainingText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4B2F37),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(value: 'edit', child: Text('编辑')),
                  PopupMenuItem<String>(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

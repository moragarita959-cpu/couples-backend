import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/todo_entry.dart';
import '../../domain/entities/todo_item.dart';
import '../state/todo_state.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshTodos();
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
      _refreshTodos();
    }
  }

  Future<void> _refreshTodos() async {
    await ref.read(todoControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    await ref.read(homeSummaryControllerProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoControllerProvider);
    final controller = ref.read(todoControllerProvider.notifier);

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('双人待办'),
        backgroundColor: CoupleUi.surface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTodoSheet(context),
        backgroundColor: CoupleUi.primary,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('新建待办'),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: CoupleUi.pageBackgroundDecoration(),
          child: RefreshIndicator(
            onRefresh: _refreshTodos,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(CoupleUi.pagePadding),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: CoupleUi.sectionCardDecoration(),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TodoFilter.values.map((item) {
                      return ChoiceChip(
                        label: Text(_filterLabel(item)),
                        selected: state.filter == item,
                        onSelected: (_) => controller.setFilter(item),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: CoupleUi.sectionSpacing),
                _TodoSummaryCard(entries: state.filteredEntries),
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: CoupleUi.sectionSpacing),
                if (state.filteredEntries.isEmpty)
                  Container(
                    decoration: CoupleUi.sectionCardDecoration(),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          '这个分类下还没有待办，点击“新建待办”开始记录吧。',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CoupleUi.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...state.filteredEntries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TodoTile(
                        entry: entry,
                        ownerBadge: _ownerBadge(entry.item.owner),
                        ownerColor: _ownerColor(entry.item.owner),
                        canManage: controller.canManage(entry.item),
                        onMyDoneChanged: (value) {
                          controller.toggleMyDone(entry.item.id, value);
                        },
                        onEdit: () => _openTodoSheet(context, editing: entry.item),
                        onDelete: () => _confirmDeleteTodo(context, entry.item),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTodoSheet(BuildContext context, {TodoItem? editing}) async {
    final titleController = TextEditingController(text: editing?.title ?? '');
    final descriptionController = TextEditingController(
      text: editing?.description ?? '',
    );
    DateTime? dueAt = editing?.dueAt;
    TodoOwner owner = editing?.owner ?? TodoOwner.shared;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CoupleUi.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDueDateTime() async {
              final now = DateTime.now();
              final initialDate = dueAt ?? now;
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: now.subtract(const Duration(days: 30)),
                lastDate: now.add(const Duration(days: 365)),
              );
              if (pickedDate == null || !context.mounted) {
                return;
              }

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: dueAt == null
                    ? const TimeOfDay(hour: 21, minute: 0)
                    : TimeOfDay.fromDateTime(dueAt!),
              );
              if (!context.mounted) {
                return;
              }
              final time = pickedTime ?? const TimeOfDay(hour: 21, minute: 0);
              setSheetState(() {
                dueAt = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  time.hour,
                  time.minute,
                );
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
                children: <Widget>[
                  Text(
                    editing == null ? '创建待办' : '编辑待办',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: CoupleUi.inputDecoration(labelText: '标题'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: CoupleUi.inputDecoration(labelText: '描述'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TodoOwner>(
                    initialValue: owner,
                    decoration: CoupleUi.inputDecoration(labelText: '归属'),
                    items: TodoOwner.values
                        .map(
                          (item) => DropdownMenuItem<TodoOwner>(
                            value: item,
                            child: Text(_ownerLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setSheetState(() {
                        owner = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: pickDueDateTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      dueAt == null
                          ? '选择截止时间'
                          : '${_dateTimeText(dueAt!)} · 提前 30 分钟提醒',
                    ),
                  ),
                  if (dueAt != null)
                    TextButton.icon(
                      onPressed: () {
                        setSheetState(() {
                          dueAt = null;
                        });
                      },
                      icon: const Icon(Icons.event_busy_outlined),
                      label: const Text('清除截止时间'),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final notifier = ref.read(todoControllerProvider.notifier);
                      final ok = editing == null
                          ? await notifier.create(
                              title: titleController.text,
                              description: descriptionController.text,
                              dueAt: dueAt,
                              owner: owner,
                            )
                          : await notifier.updateDetails(
                              item: editing,
                              title: titleController.text,
                              description: descriptionController.text,
                              dueAt: dueAt,
                              owner: owner,
                            );
                      if (!ok || !mounted) {
                        return;
                      }
                      await ref.read(homeSummaryControllerProvider.notifier).load();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: CoupleUi.primaryButtonStyle(),
                    child: Text(editing == null ? '保存待办' : '保存修改'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDeleteTodo(BuildContext context, TodoItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('删除待办'),
          content: Text('确认删除「${item.title}」吗？'),
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
    if (confirmed != true || !mounted) {
      return;
    }
    await ref.read(todoControllerProvider.notifier).delete(item);
    if (!mounted) {
      return;
    }
    await ref.read(homeSummaryControllerProvider.notifier).load();
  }

  static String _filterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.mine:
        return '我的';
      case TodoFilter.partner:
        return 'TA 的';
      case TodoFilter.shared:
        return '共同';
    }
  }

  static String _ownerLabel(TodoOwner owner) {
    switch (owner) {
      case TodoOwner.me:
        return '我的';
      case TodoOwner.partner:
        return 'TA 的';
      case TodoOwner.shared:
        return '共同';
    }
  }

  static String _ownerBadge(TodoOwner owner) {
    switch (owner) {
      case TodoOwner.me:
        return '我';
      case TodoOwner.partner:
        return 'TA';
      case TodoOwner.shared:
        return '一起';
    }
  }

  static Color _ownerColor(TodoOwner owner) {
    switch (owner) {
      case TodoOwner.me:
        return const Color(0xFFE17A97);
      case TodoOwner.partner:
        return const Color(0xFF86A6E8);
      case TodoOwner.shared:
        return const Color(0xFFA46DDA);
    }
  }

  static String _dateTimeText(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hour:$minute';
  }
}

class _TodoSummaryCard extends StatelessWidget {
  const _TodoSummaryCard({required this.entries});

  final List<TodoEntry> entries;

  @override
  Widget build(BuildContext context) {
    final total = entries.length;
    final completed = entries.where((entry) => entry.progress.meDone).length;
    final dueSoon = entries.where((entry) {
      final dueAt = entry.item.dueAt;
      if (dueAt == null || entry.progress.meDone) {
        return false;
      }
      final now = DateTime.now();
      return dueAt.isAfter(now) && dueAt.difference(now) <= const Duration(hours: 12);
    }).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Row(
        children: <Widget>[
          Expanded(child: _MetricChip(label: '当前可见', value: '$total')),
          const SizedBox(width: 8),
          Expanded(child: _MetricChip(label: '我已完成', value: '$completed')),
          const SizedBox(width: 8),
          Expanded(child: _MetricChip(label: '即将到期', value: '$dueSoon')),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: CoupleUi.nestedCardDecoration(),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: CoupleUi.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.entry,
    required this.ownerBadge,
    required this.ownerColor,
    required this.canManage,
    required this.onMyDoneChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoEntry entry;
  final String ownerBadge;
  final Color ownerColor;
  final bool canManage;
  final ValueChanged<bool> onMyDoneChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _mineEditable {
    return entry.item.owner == TodoOwner.me || entry.item.owner == TodoOwner.shared;
  }

  _DueMeta _dueMeta(DateTime? dueAt) {
    if (dueAt == null) {
      return const _DueMeta(
        text: '未设置截止时间',
        color: Color(0xFF8791A8),
      );
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final afterTomorrowStart = todayStart.add(const Duration(days: 2));
    final hour = dueAt.hour.toString().padLeft(2, '0');
    final minute = dueAt.minute.toString().padLeft(2, '0');

    String datePrefix;
    if (dueAt.isAfter(todayStart) && dueAt.isBefore(tomorrowStart)) {
      datePrefix = '今天';
    } else if (dueAt.isAfter(tomorrowStart) && dueAt.isBefore(afterTomorrowStart)) {
      datePrefix = '明天';
    } else {
      final month = dueAt.month.toString().padLeft(2, '0');
      final day = dueAt.day.toString().padLeft(2, '0');
      datePrefix = '$month-$day';
    }

    final dueText = '$datePrefix $hour:$minute';
    if (dueAt.isBefore(now)) {
      return _DueMeta(
        text: '$dueText · 已逾期',
        color: const Color(0xFFC16474),
      );
    }
    if (dueAt.difference(now) <= const Duration(hours: 6)) {
      return _DueMeta(
        text: '$dueText · 即将到期',
        color: const Color(0xFFCD8A53),
      );
    }
    return _DueMeta(
      text: '$dueText · 提前 30 分钟提醒',
      color: const Color(0xFF6F7FA5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueMeta = _dueMeta(entry.item.dueAt);
    return Container(
      decoration: CoupleUi.sectionCardDecoration(
        borderColor: ownerColor.withValues(alpha: 0.22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ownerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ownerBadge,
                    style: TextStyle(
                      color: ownerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (canManage) ...<Widget>[
                  IconButton(
                    tooltip: '编辑',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: '删除',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
            if (entry.item.description.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                entry.item.description,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              dueMeta.text,
              style: TextStyle(
                color: dueMeta.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: entry.progress.meDone,
                      onChanged:
                          _mineEditable ? (value) => onMyDoneChanged(value ?? false) : null,
                    ),
                    Text(_mineEditable ? '我（可操作）' : '我（只读）'),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: entry.progress.partnerDone,
                      onChanged: null,
                    ),
                    const Text('TA（只读）'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DueMeta {
  const _DueMeta({required this.text, required this.color});

  final String text;
  final Color color;
}


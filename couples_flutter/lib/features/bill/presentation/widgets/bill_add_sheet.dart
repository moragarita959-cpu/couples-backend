import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../state/bill_controller.dart';

Future<void> showBillAddSheet({
  required BuildContext context,
  required BillController controller,
  Future<void> Function()? onSaved,
  BillRecord? editing,
}) async {
  BillType type = editing?.type ?? BillType.expense;
  String categoryKey = editing?.categoryKey ?? BillTagCatalog.keysForType(type).first;
  final amountController = TextEditingController(
    text: editing == null ? '' : editing.amount.toStringAsFixed(2),
  );
  final noteController = TextEditingController(text: editing?.note ?? '');
  DateTime selectedDate = editing?.createdAt ?? DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          editing == null ? '记一笔' : '编辑账目',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF302B40),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<BillType>(
                      segments: const <ButtonSegment<BillType>>[
                        ButtonSegment<BillType>(value: BillType.expense, label: Text('支出')),
                        ButtonSegment<BillType>(value: BillType.income, label: Text('收入')),
                      ],
                      selected: <BillType>{type},
                      onSelectionChanged: (s) {
                        setModalState(() {
                          type = s.first;
                          final normalized = BillTagCatalog.normalizeKey(categoryKey);
                          if (!BillTagCatalog.isValidForType(normalized, type)) {
                            categoryKey = BillTagCatalog.keysForType(type).first;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '选择标签',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...BillTagCatalog.parents.where((p) => p.billType == type).map(
                      (parent) {
                        return ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Row(
                            children: <Widget>[
                              Icon(parent.icon, size: 18, color: parent.color),
                              const SizedBox(width: 8),
                              Text(
                                parent.label,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          children: <Widget>[
                            ...parent.children.map(
                              (c) {
                                final childFullKey = '${parent.key}.${c.key}';
                                final selected = categoryKey == childFullKey;
                                final canManage = BillTagCatalog.isCustomChild(
                                  parentKey: parent.key,
                                  childKey: c.key,
                                );
                                return ListTile(
                                  dense: true,
                                  title: Text(c.label),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      if (selected)
                                        Icon(Icons.check_circle, color: parent.color),
                                      if (canManage) ...<Widget>[
                                        IconButton(
                                          tooltip: '编辑标签',
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          onPressed: () async {
                                            final ok = await _askRenameChildTag(
                                              context: context,
                                              parent: parent,
                                              child: c,
                                            );
                                            if (ok == true) {
                                              setModalState(() {});
                                            }
                                          },
                                        ),
                                        IconButton(
                                          tooltip: '删除标签',
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          onPressed: () async {
                                            final ok = await _confirmDeleteChildTag(
                                              context: context,
                                              parent: parent,
                                              child: c,
                                            );
                                            if (ok == true) {
                                              setModalState(() {
                                                if (categoryKey == childFullKey) {
                                                  categoryKey =
                                                      BillTagCatalog.keysForType(type).first;
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () {
                                    setModalState(() {
                                      categoryKey = childFullKey;
                                    });
                                  },
                                );
                              },
                            ),
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.add, size: 18),
                              title: const Text('新增二级标签'),
                              onTap: () async {
                                final added = await _askCreateChildTag(
                                  context: context,
                                  parent: parent,
                                );
                                if (added != null) {
                                  setModalState(() {
                                    categoryKey = added;
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: '金额',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined, size: 18),
                      title: const Text('日期'),
                      subtitle: Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(2100, 12, 31),
                        );
                        if (picked == null) {
                          return;
                        }
                        setModalState(() {
                          selectedDate = picked;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () async {
                        bool ok;
                        if (editing != null) {
                          final amount = double.tryParse(amountController.text.trim());
                          if (amount == null || amount <= 0) {
                            return;
                          }
                          await controller.update(
                            editing.copyWith(
                              type: type,
                              categoryKey: BillTagCatalog.normalizeKey(categoryKey),
                              amount: amount,
                              note: noteController.text.trim(),
                              createdAt: selectedDate,
                              updatedAt: DateTime.now(),
                            ),
                          );
                          ok = true;
                        } else {
                          ok = await controller.create(
                            type: type,
                            categoryKey: categoryKey,
                            amountText: amountController.text,
                            note: noteController.text,
                            createdAt: selectedDate,
                          );
                        }
                        if (ok && ctx.mounted) {
                          await onSaved?.call();
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        }
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<String?> _askCreateChildTag({
  required BuildContext context,
  required BillTagParentDef parent,
}) async {
  final controller = TextEditingController();
  final label = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('新增标签 · ${parent.label}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入二级标签名',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      );
    },
  );
  if (label == null || label.isEmpty) {
    return null;
  }
  final slug = BillTagCatalog.customChildKeyForLabel(label);
  final ok = BillTagCatalog.registerChild(
    parentKey: parent.key,
    childKey: slug,
    label: label,
  );
  final fullKey = '${parent.key}.$slug';
  if (!ok && !BillTagCatalog.isValidForType(fullKey, parent.billType)) {
    return null;
  }
  return fullKey;
}

Future<bool?> _askRenameChildTag({
  required BuildContext context,
  required BillTagParentDef parent,
  required BillTagChildDef child,
}) async {
  final controller = TextEditingController(text: child.label);
  final label = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('编辑标签 · ${parent.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入二级标签名'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
  if (label == null || label.isEmpty) {
    return false;
  }
  return BillTagCatalog.renameChild(
    parentKey: parent.key,
    childKey: child.key,
    label: label,
  );
}

Future<bool?> _confirmDeleteChildTag({
  required BuildContext context,
  required BillTagParentDef parent,
  required BillTagChildDef child,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('删除标签'),
        content: Text('删除「${child.label}」后，历史账目会保留兼容显示。'),
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
  if (confirmed != true) {
    return false;
  }
  return BillTagCatalog.deleteChild(
    parentKey: parent.key,
    childKey: child.key,
  );
}

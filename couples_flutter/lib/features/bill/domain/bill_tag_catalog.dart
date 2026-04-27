import 'package:flutter/material.dart';

import 'bill_types.dart';

/// Stable `parent.child` keys stored in DB / API `category` field.
abstract final class BillTagCatalog {
  static const String _customPrefix = 'custom_';

  static const List<BillTagParentDef> _baseParents = <BillTagParentDef>[
    BillTagParentDef(
      key: 'income',
      label: '收入',
      billType: BillType.income,
      color: Color(0xFF2E9E5C),
      icon: Icons.savings_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('living_allowance', '生活费'),
        BillTagChildDef('scholarship', '奖学金'),
        BillTagChildDef('subsidy', '补助'),
        BillTagChildDef('side_job', '兼职副业'),
        BillTagChildDef('red_packet_transfer', '红包转账'),
        BillTagChildDef('refund_reimburse', '退款报销'),
      ],
    ),
    BillTagParentDef(
      key: 'basic',
      label: '基础开销',
      billType: BillType.expense,
      color: Color(0xFF5B7FD1),
      icon: Icons.home_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('water', '水费'),
        BillTagChildDef('electric', '电费'),
        BillTagChildDef('network', '网费'),
        BillTagChildDef('daily_goods', '日用品'),
        BillTagChildDef('laundry', '洗衣费用'),
      ],
    ),
    BillTagParentDef(
      key: 'comprehensive',
      label: '综合支出',
      billType: BillType.expense,
      color: Color(0xFF8E6BC9),
      icon: Icons.shopping_bag_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('memberships', '各类会员'),
        BillTagChildDef('books', '书本资料'),
        BillTagChildDef('print_copy', '打印复印'),
        BillTagChildDef('exam_enrollment', '考试报名'),
        BillTagChildDef('online_course', '网课培训'),
        BillTagChildDef('investment', '投资理财'),
        BillTagChildDef('online_shopping', '网购消费'),
      ],
    ),
    BillTagParentDef(
      key: 'dining',
      label: '饮食开支',
      billType: BillType.expense,
      color: Color(0xFFE07A4A),
      icon: Icons.restaurant_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('main_meal', '正餐'),
        BillTagChildDef('snacks', '零食饮品'),
        BillTagChildDef('group_meal', '聚餐大餐'),
      ],
    ),
    BillTagParentDef(
      key: 'transport',
      label: '交通出行',
      billType: BillType.expense,
      color: Color(0xFF3A9BC8),
      icon: Icons.directions_bus_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('daily_transport', '日常交通'),
        BillTagChildDef('long_trip', '长途出行'),
      ],
    ),
    BillTagParentDef(
      key: 'leisure',
      label: '娱乐休闲',
      billType: BillType.expense,
      color: Color(0xFFC75BB4),
      icon: Icons.sports_esports_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('game_topup', '游戏充值'),
        BillTagChildDef('show_tickets', '演出门票'),
        BillTagChildDef('leisure_spending', '游玩消费'),
      ],
    ),
    BillTagParentDef(
      key: 'social',
      label: '社交人情',
      billType: BillType.expense,
      color: Color(0xFFD96A8F),
      icon: Icons.card_giftcard_outlined,
      children: <BillTagChildDef>[
        BillTagChildDef('birthday_gift', '生日礼物'),
        BillTagChildDef('cash_gift', '红包礼金'),
      ],
    ),
    BillTagParentDef(
      key: 'other',
      label: '其他',
      billType: BillType.expense,
      color: Color(0xFF7A7689),
      icon: Icons.more_horiz,
      children: <BillTagChildDef>[
        BillTagChildDef('medical', '医疗药品'),
        BillTagChildDef('misc', '杂项支出'),
      ],
    ),
  ];

  static final Map<String, List<BillTagChildDef>> _runtimeChildrenByParent =
      <String, List<BillTagChildDef>>{};

  static List<BillTagParentDef> get parents {
    return _baseParents.map((parent) {
      final extras = _runtimeChildrenByParent[parent.key] ?? const <BillTagChildDef>[];
      if (extras.isEmpty) {
        return parent;
      }
      return BillTagParentDef(
        key: parent.key,
        label: parent.label,
        billType: parent.billType,
        color: parent.color,
        icon: parent.icon,
        children: <BillTagChildDef>[...parent.children, ...extras],
      );
    }).toList(growable: false);
  }

  static bool registerChild({
    required String parentKey,
    required String childKey,
    required String label,
    bool isCustom = true,
  }) {
    final p = parentKey.trim();
    final c = childKey.trim();
    final l = label.trim();
    if (p.isEmpty || c.isEmpty || l.isEmpty || c.contains('.')) {
      return false;
    }
    if (!_parentByKey().containsKey(p)) {
      return false;
    }
    final full = '$p.$c';
    if (_childLabelByFullKey().containsKey(full)) {
      return false;
    }
    final list = _runtimeChildrenByParent.putIfAbsent(p, () => <BillTagChildDef>[]);
    list.add(BillTagChildDef(c, l, isCustom: isCustom));
    return true;
  }

  static String customChildKeyForLabel(String label) {
    final encoded = Uri.encodeComponent(label.trim());
    if (encoded.isEmpty) {
      return '$_customPrefix${DateTime.now().microsecondsSinceEpoch}';
    }
    return '$_customPrefix$encoded';
  }

  static bool isCustomChild({
    required String parentKey,
    required String childKey,
  }) {
    final p = parentKey.trim();
    final c = childKey.trim();
    final baseHasKey = <String>{
      for (final BillTagParentDef parent in _baseParents)
        for (final BillTagChildDef child in parent.children)
          '${parent.key}.${child.key}',
    }.contains('$p.$c');
    if (baseHasKey) {
      return false;
    }
    return c.startsWith(_customPrefix) ||
        (_runtimeChildrenByParent[p] ?? const <BillTagChildDef>[])
            .any((item) => item.key == c && item.isCustom);
  }

  static bool renameChild({
    required String parentKey,
    required String childKey,
    required String label,
  }) {
    final p = parentKey.trim();
    final c = childKey.trim();
    final l = label.trim();
    if (p.isEmpty || c.isEmpty || l.isEmpty) {
      return false;
    }
    if (!isCustomChild(parentKey: p, childKey: c)) {
      return false;
    }
    final list = _runtimeChildrenByParent[p];
    if (list == null) {
      return registerChild(parentKey: p, childKey: c, label: l);
    }
    final index = list.indexWhere((item) => item.key == c);
    if (index < 0) {
      return registerChild(parentKey: p, childKey: c, label: l);
    }
    list[index] = BillTagChildDef(c, l, isCustom: true);
    return true;
  }

  static bool deleteChild({
    required String parentKey,
    required String childKey,
  }) {
    final p = parentKey.trim();
    final c = childKey.trim();
    if (!isCustomChild(parentKey: p, childKey: c)) {
      return false;
    }
    final list = _runtimeChildrenByParent[p];
    if (list == null) {
      return false;
    }
    final before = list.length;
    list.removeWhere((item) => item.key == c);
    if (list.isEmpty) {
      _runtimeChildrenByParent.remove(p);
    }
    return list.length != before;
  }

  static Map<String, BillTagParentDef> _parentByKey() => <String, BillTagParentDef>{
        for (final BillTagParentDef p in parents) p.key: p,
      };

  static Map<String, String> _childLabelByFullKey() => <String, String>{
        for (final BillTagParentDef p in parents)
          for (final BillTagChildDef c in p.children) '${p.key}.${c.key}': c.label,
      };

  static String normalizeKey(String? raw) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) {
      return defaultKey;
    }
    if (_childLabelByFullKey().containsKey(trimmed)) {
      return trimmed;
    }
    final normalized = migrationFromLegacyCategoryName(trimmed);
    _registerUnknownChildIfPossible(normalized);
    return normalized;
  }

  static const String defaultKey = 'other.misc';

  /// Legacy Drift/API stored enum `.name` (e.g. `meals`).
  static String migrationFromLegacyCategoryName(String raw) {
    switch (raw) {
      case 'meals':
        return 'dining.main_meal';
      case 'transport':
        return 'transport.daily_transport';
      case 'entertainment':
        return 'leisure.game_topup';
      case 'shopping':
        return 'comprehensive.online_shopping';
      case 'daily':
        return 'basic.daily_goods';
      case 'housing':
        return 'basic.water';
      case 'travel':
        return 'transport.long_trip';
      case 'medical':
        return 'other.medical';
      case 'salary':
        return 'income.living_allowance';
      case 'bonus':
        return 'income.red_packet_transfer';
      case 'gift':
        return 'social.birthday_gift';
      case 'other':
        return 'other.misc';
      default:
        if (raw.contains('.')) {
          return raw;
        }
        return defaultKey;
    }
  }

  static bool isValidForType(String categoryKey, BillType type) {
    _registerUnknownChildIfPossible(categoryKey);
    final parts = categoryKey.split('.');
    if (parts.isEmpty) {
      return false;
    }
    final parent = _parentByKey()[parts.first];
    return parent != null &&
        parent.billType == type &&
        _childLabelByFullKey().containsKey(categoryKey);
  }

  static Iterable<String> keysForType(BillType type) sync* {
    for (final BillTagParentDef p in parents) {
      if (p.billType != type) {
        continue;
      }
      for (final BillTagChildDef c in p.children) {
        yield '${p.key}.${c.key}';
      }
    }
  }

  static BillTagParentDef? parentOf(String categoryKey) {
    final parts = categoryKey.split('.');
    if (parts.isEmpty) {
      return null;
    }
    return _parentByKey()[parts.first];
  }

  static String displayLabel(String categoryKey) {
    _registerUnknownChildIfPossible(categoryKey);
    final parent = parentOf(categoryKey);
    final childLabel = _childLabelByFullKey()[categoryKey];
    if (parent == null) {
      return categoryKey;
    }
    if (childLabel == null) {
      final parts = categoryKey.split('.');
      if (parts.length == 2 && parts.first == parent.key && parts.last.trim().isNotEmpty) {
        return '${parent.label} · ${parts.last.trim()}';
      }
      return categoryKey;
    }
    return '${parent.label} · $childLabel';
  }

  static Color colorFor(String categoryKey) {
    return parentOf(categoryKey)?.color ?? const Color(0xFF7A7689);
  }

  static IconData iconFor(String categoryKey) {
    return parentOf(categoryKey)?.icon ?? Icons.label_outline;
  }

  static void _registerUnknownChildIfPossible(String categoryKey) {
    final parts = categoryKey.split('.');
    if (parts.length != 2) {
      return;
    }
    final parent = _parentByKey()[parts.first];
    final child = parts.last.trim();
    if (parent == null || child.isEmpty) {
      return;
    }
    if (_childLabelByFullKey().containsKey(categoryKey)) {
      return;
    }
    registerChild(
      parentKey: parent.key,
      childKey: child,
      label: _labelFromChildKey(child),
      isCustom: true,
    );
  }

  static String _labelFromChildKey(String childKey) {
    final child = childKey.trim();
    if (child.startsWith(_customPrefix)) {
      final encoded = child.substring(_customPrefix.length);
      try {
        final decoded = Uri.decodeComponent(encoded).trim();
        if (decoded.isNotEmpty) {
          return decoded;
        }
      } catch (_) {
        // Keep a stable fallback below.
      }
      return '自定义标签';
    }
    final pretty = child.replaceAll('_', ' ').trim();
    return pretty.isEmpty ? '自定义标签' : pretty;
  }

}

class BillTagParentDef {
  const BillTagParentDef({
    required this.key,
    required this.label,
    required this.billType,
    required this.color,
    required this.icon,
    required this.children,
  });

  final String key;
  final String label;
  final BillType billType;
  final Color color;
  final IconData icon;
  final List<BillTagChildDef> children;
}

class BillTagChildDef {
  const BillTagChildDef(
    this.key,
    this.label, {
    this.isCustom = false,
  });

  final String key;
  final String label;
  final bool isCustom;
}

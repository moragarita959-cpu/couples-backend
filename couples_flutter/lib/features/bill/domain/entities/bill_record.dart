enum BillType {
  income,
  expense,
}

enum BillCategory {
  meals,
  transport,
  entertainment,
  shopping,
  daily,
  housing,
  travel,
  medical,
  salary,
  bonus,
  gift,
  other,
}

class BillRecord {
  const BillRecord({
    required this.id,
    required this.coupleId,
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });

  final String id;
  final String coupleId;
  final BillType type;
  final BillCategory category;
  final double amount;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;

  BillRecord copyWith({
    String? id,
    String? coupleId,
    BillType? type,
    BillCategory? category,
    double? amount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) {
    return BillRecord(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}

class BillPeriodSummary {
  const BillPeriodSummary({
    required this.incomeTotal,
    required this.expenseTotal,
    required this.balance,
    required this.expenseByCategory,
    required this.recordCount,
  });

  const BillPeriodSummary.empty()
      : incomeTotal = 0,
        expenseTotal = 0,
        balance = 0,
        expenseByCategory = const <BillCategory, double>{},
        recordCount = 0;

  final double incomeTotal;
  final double expenseTotal;
  final double balance;
  final Map<BillCategory, double> expenseByCategory;
  final int recordCount;
}

class BillSummary {
  const BillSummary({
    required this.overall,
    required this.currentWeek,
    required this.currentMonth,
  });

  const BillSummary.empty()
      : overall = const BillPeriodSummary.empty(),
        currentWeek = const BillPeriodSummary.empty(),
        currentMonth = const BillPeriodSummary.empty();

  final BillPeriodSummary overall;
  final BillPeriodSummary currentWeek;
  final BillPeriodSummary currentMonth;
}

extension BillCategoryX on BillCategory {
  String get label {
    switch (this) {
      case BillCategory.meals:
        return '??';
      case BillCategory.transport:
        return '??';
      case BillCategory.entertainment:
        return '??';
      case BillCategory.shopping:
        return '??';
      case BillCategory.daily:
        return '??';
      case BillCategory.housing:
        return '??';
      case BillCategory.travel:
        return '??';
      case BillCategory.medical:
        return '??';
      case BillCategory.salary:
        return '??';
      case BillCategory.bonus:
        return '??';
      case BillCategory.gift:
        return '??';
      case BillCategory.other:
        return '??';
    }
  }

  static List<BillCategory> availableFor(BillType type) {
    if (type == BillType.income) {
      return const <BillCategory>[
        BillCategory.salary,
        BillCategory.bonus,
        BillCategory.gift,
        BillCategory.other,
      ];
    }
    return const <BillCategory>[
      BillCategory.meals,
      BillCategory.transport,
      BillCategory.entertainment,
      BillCategory.shopping,
      BillCategory.daily,
      BillCategory.housing,
      BillCategory.travel,
      BillCategory.medical,
      BillCategory.other,
    ];
  }
}



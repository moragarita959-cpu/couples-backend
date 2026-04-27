import '../bill_tag_catalog.dart';
import '../bill_types.dart';

export '../bill_types.dart';

class BillRecord {
  const BillRecord({
    required this.id,
    required this.coupleId,
    required this.ownerUserId,
    required this.type,
    required this.categoryKey,
    required this.amount,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });

  final String id;
  final String coupleId;
  final String ownerUserId;
  final BillType type;
  final String categoryKey;
  final double amount;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;

  String get categoryDisplayLabel => BillTagCatalog.displayLabel(categoryKey);

  BillRecord copyWith({
    String? id,
    String? coupleId,
    String? ownerUserId,
    BillType? type,
    String? categoryKey,
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
      ownerUserId: ownerUserId ?? this.ownerUserId,
      type: type ?? this.type,
      categoryKey: categoryKey ?? this.categoryKey,
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
    required this.expenseByCategoryKey,
    required this.recordCount,
  });

  const BillPeriodSummary.empty()
      : incomeTotal = 0,
        expenseTotal = 0,
        balance = 0,
        expenseByCategoryKey = const <String, double>{},
        recordCount = 0;

  final double incomeTotal;
  final double expenseTotal;
  final double balance;
  final Map<String, double> expenseByCategoryKey;
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

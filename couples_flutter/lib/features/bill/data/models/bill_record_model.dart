import '../../domain/entities/bill_record.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class BillRecordModel extends BillRecord {
  const BillRecordModel({
    required super.id,
    required super.coupleId,
    required super.type,
    required super.category,
    required super.amount,
    required super.note,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.pendingSync,
  });

  factory BillRecordModel.fromRow(BillRecordsTableData row) {
    return BillRecordModel(
      id: row.id,
      coupleId: row.coupleId,
      type: row.type == 'income' ? BillType.income : BillType.expense,
      category: _categoryFromRaw(row.category),
      amount: row.amount,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      pendingSync: row.pendingSync,
    );
  }

  factory BillRecordModel.fromEntity(BillRecord item) {
    return BillRecordModel(
      id: item.id,
      coupleId: item.coupleId,
      type: item.type,
      category: item.category,
      amount: item.amount,
      note: item.note,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isDeleted: item.isDeleted,
      pendingSync: item.pendingSync,
    );
  }

  factory BillRecordModel.fromCloudJson(Map<String, dynamic> json) {
    return BillRecordModel(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      type: (json['type'] as String? ?? 'expense') == 'income'
          ? BillType.income
          : BillType.expense,
      category: _categoryFromRaw(json['category'] as String? ?? 'other'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      isDeleted: json['isDeleted'] == true,
      pendingSync: false,
    );
  }

  BillRecordsTableCompanion toCompanion() {
    return BillRecordsTableCompanion.insert(
      id: id,
      coupleId: Value<String>(coupleId),
      type: type == BillType.income ? 'income' : 'expense',
      amount: amount,
      category: Value<String>(_categoryToRaw(category)),
      note: note,
      createdAt: createdAt,
      updatedAt: Value<DateTime>(updatedAt),
      isDeleted: Value<bool>(isDeleted),
      pendingSync: Value<bool>(pendingSync),
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'type': type == BillType.income ? 'income' : 'expense',
      'category': _categoryToRaw(category),
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  @override
  BillRecordModel copyWith({
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
    return BillRecordModel(
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

  static String _categoryToRaw(BillCategory category) => category.name;

  static BillCategory _categoryFromRaw(String raw) {
    return BillCategory.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => BillCategory.other,
    );
  }
}

import '../../domain/bill_tag_catalog.dart';
import '../../domain/entities/bill_record.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class BillRecordModel extends BillRecord {
  const BillRecordModel({
    required super.id,
    required super.coupleId,
    required super.ownerUserId,
    required super.type,
    required super.categoryKey,
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
      ownerUserId: row.ownerUserId,
      type: row.type == 'income' ? BillType.income : BillType.expense,
      categoryKey: BillTagCatalog.normalizeKey(row.categoryKey),
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
      ownerUserId: item.ownerUserId,
      type: item.type,
      categoryKey: BillTagCatalog.normalizeKey(item.categoryKey),
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
      ownerUserId: _stringFromAny(
        json,
        const <String>[
          'ownerUserId',
          'owner_user_id',
          'actorUserId',
          'userId',
          'createdBy',
        ],
      ),
      type: (json['type'] as String? ?? 'expense') == 'income'
          ? BillType.income
          : BillType.expense,
      categoryKey: BillTagCatalog.normalizeKey(json['category'] as String?),
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
      ownerUserId: Value<String>(ownerUserId),
      type: type == BillType.income ? 'income' : 'expense',
      amount: amount,
      categoryKey: Value<String>(BillTagCatalog.normalizeKey(categoryKey)),
      note: note,
      createdAt: createdAt,
      updatedAt: Value<DateTime>(updatedAt),
      isDeleted: Value<bool>(isDeleted),
      pendingSync: Value<bool>(pendingSync),
    );
  }

  Map<String, dynamic> toCloudJson({required String actorUserId}) {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'ownerUserId': ownerUserId,
      'actorUserId': actorUserId,
      'type': type == BillType.income ? 'income' : 'expense',
      'category': BillTagCatalog.normalizeKey(categoryKey),
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
    return BillRecordModel(
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

  static String _stringFromAny(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}

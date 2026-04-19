import '../../domain/entities/countdown_event.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class CountdownEventModel extends CountdownEvent {
  const CountdownEventModel({
    required super.id,
    required super.coupleId,
    required super.name,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.pendingSync,
  });

  factory CountdownEventModel.fromRow(CountdownEventsTableData row) {
    return CountdownEventModel(
      id: row.id,
      coupleId: row.coupleId,
      name: row.name,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      pendingSync: row.pendingSync,
    );
  }

  factory CountdownEventModel.fromEntity(CountdownEvent item) {
    return CountdownEventModel(
      id: item.id,
      coupleId: item.coupleId,
      name: item.name,
      date: item.date,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isDeleted: item.isDeleted,
      pendingSync: item.pendingSync,
    );
  }

  factory CountdownEventModel.fromCloudJson(Map<String, dynamic> json) {
    return CountdownEventModel(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      date: DateTime.parse(json['date'] as String).toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      isDeleted: json['isDeleted'] == true,
      pendingSync: false,
    );
  }

  CountdownEventsTableCompanion toCompanion() {
    return CountdownEventsTableCompanion.insert(
      id: id,
      coupleId: Value<String>(coupleId),
      name: name,
      date: date,
      createdAt: Value<DateTime>(createdAt),
      updatedAt: Value<DateTime>(updatedAt),
      isDeleted: Value<bool>(isDeleted),
      pendingSync: Value<bool>(pendingSync),
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'name': name,
      'date': date.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  @override
  CountdownEventModel copyWith({
    String? id,
    String? coupleId,
    String? name,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) {
    return CountdownEventModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      name: name ?? this.name,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}

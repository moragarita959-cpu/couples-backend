import '../../domain/entities/todo_item.dart';
import '../../../../core/storage/drift/app_database.dart';
import 'package:drift/drift.dart';

class TodoItemModel extends TodoItem {
  const TodoItemModel({
    required super.id,
    required super.coupleId,
    required super.title,
    required super.description,
    required super.dueAt,
    required super.owner,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.pendingSync,
    super.meDone,
    super.partnerDone,
  });

  factory TodoItemModel.fromRow(
    TodosTableData row, {
    required bool meDone,
    required bool partnerDone,
  }) {
    return TodoItemModel(
      id: row.id,
      coupleId: row.coupleId,
      title: row.title,
      description: row.description,
      dueAt: row.dueAt,
      owner: _ownerFromRaw(row.owner),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      pendingSync: row.pendingSync,
      meDone: meDone,
      partnerDone: partnerDone,
    );
  }

  factory TodoItemModel.fromEntity(TodoItem item) {
    return TodoItemModel(
      id: item.id,
      coupleId: item.coupleId,
      title: item.title,
      description: item.description,
      dueAt: item.dueAt,
      owner: item.owner,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      isDeleted: item.isDeleted,
      pendingSync: item.pendingSync,
      meDone: item.meDone,
      partnerDone: item.partnerDone,
    );
  }

  factory TodoItemModel.fromCloudJson(Map<String, dynamic> json) {
    return TodoItemModel(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueAt: json['dueAt'] == null
          ? null
          : DateTime.parse(json['dueAt'] as String).toLocal(),
      owner: _ownerFromRaw(json['owner'] as String? ?? 'shared'),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      isDeleted: json['isDeleted'] == true,
      pendingSync: false,
      meDone: json['meDone'] == true,
      partnerDone: json['partnerDone'] == true,
    );
  }

  TodosTableCompanion toTodoCompanion() {
    return TodosTableCompanion.insert(
      id: id,
      coupleId: Value<String>(coupleId),
      title: title,
      description: description,
      dueAt: Value<DateTime?>(dueAt),
      owner: _ownerToRaw(owner),
      createdAt: createdAt,
      updatedAt: Value<DateTime>(updatedAt),
      isDeleted: Value<bool>(isDeleted),
      pendingSync: Value<bool>(pendingSync),
    );
  }

  TodoProgressTableCompanion toProgressCompanion() {
    return TodoProgressTableCompanion.insert(
      todoId: id,
      meDone: Value<bool>(meDone),
      partnerDone: Value<bool>(partnerDone),
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toCloudJson() {
    return <String, dynamic>{
      'id': id,
      'coupleId': coupleId,
      'title': title,
      'description': description,
      'dueAt': dueAt?.toUtc().toIso8601String(),
      'owner': _ownerToRaw(owner),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      'meDone': meDone,
      'partnerDone': partnerDone,
    };
  }

  @override
  TodoItemModel copyWith({
    String? id,
    String? coupleId,
    String? title,
    String? description,
    Object? dueAt = unsetTodoDueAt,
    TodoOwner? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
    bool? meDone,
    bool? partnerDone,
  }) {
    return TodoItemModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt == unsetTodoDueAt ? this.dueAt : dueAt as DateTime?,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
      meDone: meDone ?? this.meDone,
      partnerDone: partnerDone ?? this.partnerDone,
    );
  }

  static String _ownerToRaw(TodoOwner owner) {
    switch (owner) {
      case TodoOwner.me:
        return 'me';
      case TodoOwner.partner:
        return 'partner';
      case TodoOwner.shared:
        return 'shared';
    }
  }

  static TodoOwner _ownerFromRaw(String raw) {
    switch (raw) {
      case 'me':
        return TodoOwner.me;
      case 'partner':
        return TodoOwner.partner;
      default:
        return TodoOwner.shared;
    }
  }
}

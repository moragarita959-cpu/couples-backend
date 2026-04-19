enum TodoOwner { me, partner, shared }

class TodoItem {
  const TodoItem({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.description,
    required this.dueAt,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
    this.meDone = false,
    this.partnerDone = false,
  });

  final String id;
  final String coupleId;
  final String title;
  final String description;
  final DateTime? dueAt;
  final TodoOwner owner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;
  final bool meDone;
  final bool partnerDone;

  TodoItem copyWith({
    String? id,
    String? coupleId,
    String? title,
    String? description,
    DateTime? dueAt,
    TodoOwner? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
    bool? meDone,
    bool? partnerDone,
  }) {
    return TodoItem(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
      meDone: meDone ?? this.meDone,
      partnerDone: partnerDone ?? this.partnerDone,
    );
  }
}

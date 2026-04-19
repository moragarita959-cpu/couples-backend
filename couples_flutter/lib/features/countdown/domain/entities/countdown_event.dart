class CountdownEvent {
  const CountdownEvent({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });

  final String id;
  final String coupleId;
  final String name;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;

  CountdownEvent copyWith({
    String? id,
    String? coupleId,
    String? name,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) {
    return CountdownEvent(
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

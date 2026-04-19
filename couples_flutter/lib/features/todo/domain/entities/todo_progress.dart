class TodoProgress {
  const TodoProgress({
    required this.todoId,
    required this.meDone,
    required this.partnerDone,
    required this.updatedAt,
  });

  final String todoId;
  final bool meDone;
  final bool partnerDone;
  final DateTime updatedAt;
}

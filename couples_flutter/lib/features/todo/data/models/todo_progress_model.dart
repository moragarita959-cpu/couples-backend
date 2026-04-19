import '../../domain/entities/todo_progress.dart';

class TodoProgressModel extends TodoProgress {
  const TodoProgressModel({
    required super.todoId,
    required super.meDone,
    required super.partnerDone,
    required super.updatedAt,
  });
}

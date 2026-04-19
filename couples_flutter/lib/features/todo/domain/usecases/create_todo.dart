import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class CreateTodo {
  const CreateTodo(this._repository);

  final TodoRepository _repository;

  Future<TodoItem> call({
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  }) {
    return _repository.createTodo(
      title: title,
      description: description,
      dueAt: dueAt,
      owner: owner,
    );
  }
}

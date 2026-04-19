import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class UpdateTodo {
  const UpdateTodo(this._repository);

  final TodoRepository _repository;

  Future<TodoItem> call(TodoItem item) {
    return _repository.update(item);
  }
}

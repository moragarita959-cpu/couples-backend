import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class InsertTodo {
  const InsertTodo(this._repository);

  final TodoRepository _repository;

  Future<TodoItem> call(TodoItem item) {
    return _repository.insert(item);
  }
}

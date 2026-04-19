import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class GetTodos {
  const GetTodos(this._repository);

  final TodoRepository _repository;

  Future<List<TodoItem>> call() {
    return _repository.getTodos();
  }
}

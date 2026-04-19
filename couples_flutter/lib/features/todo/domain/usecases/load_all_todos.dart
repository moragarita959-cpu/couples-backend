import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class LoadAllTodos {
  const LoadAllTodos(this._repository);

  final TodoRepository _repository;

  Future<List<TodoItem>> call({required String coupleId}) {
    return _repository.loadAll(coupleId: coupleId);
  }
}

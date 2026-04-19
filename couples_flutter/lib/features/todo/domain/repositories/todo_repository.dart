import '../entities/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> loadAll({required String coupleId});
  Future<List<TodoItem>> refresh({required String coupleId});
  Future<TodoItem> insert(TodoItem item);
  Future<TodoItem> update(TodoItem item);
  Future<void> delete({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  });

  Future<List<TodoItem>> getTodos();
  Future<TodoItem> createTodo({
    required String title,
    required String description,
    required DateTime? dueAt,
    required TodoOwner owner,
  });
  Future<void> setMyDone(String todoId, bool done);
}

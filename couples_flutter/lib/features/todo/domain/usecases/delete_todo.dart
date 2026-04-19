import '../repositories/todo_repository.dart';

class DeleteTodo {
  const DeleteTodo(this._repository);

  final TodoRepository _repository;

  Future<void> call({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _repository.delete(
      id: id,
      coupleId: coupleId,
      updatedAt: updatedAt,
    );
  }
}

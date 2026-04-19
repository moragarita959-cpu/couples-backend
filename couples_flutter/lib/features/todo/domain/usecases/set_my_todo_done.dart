import '../repositories/todo_repository.dart';

class SetMyTodoDone {
  const SetMyTodoDone(this._repository);

  final TodoRepository _repository;

  Future<void> call(String todoId, bool done) {
    return _repository.setMyDone(todoId, done);
  }
}

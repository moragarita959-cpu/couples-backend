import '../repositories/countdown_repository.dart';

class DeleteEvent {
  const DeleteEvent(this._repository);

  final CountdownRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteEvent(id);
  }
}

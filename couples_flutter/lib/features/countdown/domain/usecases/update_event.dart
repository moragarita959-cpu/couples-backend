import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class UpdateEvent {
  const UpdateEvent(this._repository);

  final CountdownRepository _repository;

  Future<CountdownEvent> call({
    required String id,
    required String name,
    required DateTime date,
  }) {
    return _repository.updateEvent(id, name, date);
  }
}

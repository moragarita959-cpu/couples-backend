import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class AddEvent {
  const AddEvent(this._repository);

  final CountdownRepository _repository;

  Future<CountdownEvent> call(String name, DateTime date) {
    return _repository.addEvent(name, date);
  }
}

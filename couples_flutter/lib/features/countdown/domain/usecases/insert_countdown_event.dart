import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class InsertCountdownEvent {
  const InsertCountdownEvent(this._repository);

  final CountdownRepository _repository;

  Future<CountdownEvent> call(CountdownEvent event) {
    return _repository.insert(event);
  }
}

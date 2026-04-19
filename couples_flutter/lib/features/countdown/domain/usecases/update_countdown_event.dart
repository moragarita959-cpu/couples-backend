import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class UpdateCountdownEvent {
  const UpdateCountdownEvent(this._repository);

  final CountdownRepository _repository;

  Future<CountdownEvent> call(CountdownEvent event) {
    return _repository.update(event);
  }
}

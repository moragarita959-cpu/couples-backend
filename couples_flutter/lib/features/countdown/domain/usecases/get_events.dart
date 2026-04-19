import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class GetEvents {
  const GetEvents(this._repository);

  final CountdownRepository _repository;

  Future<List<CountdownEvent>> call() {
    return _repository.getEvents();
  }
}

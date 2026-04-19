import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class LoadAllCountdownEvents {
  const LoadAllCountdownEvents(this._repository);

  final CountdownRepository _repository;

  Future<List<CountdownEvent>> call({required String coupleId}) {
    return _repository.loadAll(coupleId: coupleId);
  }
}

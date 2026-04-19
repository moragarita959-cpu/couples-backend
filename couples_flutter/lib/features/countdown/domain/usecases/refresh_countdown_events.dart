import '../entities/countdown_event.dart';
import '../repositories/countdown_repository.dart';

class RefreshCountdownEvents {
  const RefreshCountdownEvents(this._repository);

  final CountdownRepository _repository;

  Future<List<CountdownEvent>> call({required String coupleId}) {
    return _repository.refresh(coupleId: coupleId);
  }
}

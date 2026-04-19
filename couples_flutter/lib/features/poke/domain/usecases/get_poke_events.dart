import '../entities/poke_event.dart';
import '../repositories/poke_repository.dart';

class GetPokeEvents {
  const GetPokeEvents(this._repository);

  final PokeRepository _repository;

  Future<List<PokeEvent>> call() {
    return _repository.getPokeEvents();
  }
}

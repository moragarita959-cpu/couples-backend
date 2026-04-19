import '../entities/poke_event.dart';
import '../repositories/poke_repository.dart';

class GetLastPoke {
  const GetLastPoke(this._repository);

  final PokeRepository _repository;

  Future<PokeEvent?> call() {
    return _repository.getLastPoke();
  }
}

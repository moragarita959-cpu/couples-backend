import '../entities/poke_event.dart';
import '../repositories/poke_repository.dart';

class SendPoke {
  const SendPoke(this._repository);

  final PokeRepository _repository;

  Future<PokeEvent> call() {
    return _repository.sendPoke();
  }
}

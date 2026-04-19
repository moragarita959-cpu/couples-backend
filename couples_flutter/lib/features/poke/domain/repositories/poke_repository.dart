import '../entities/poke_event.dart';

abstract class PokeRepository {
  Future<PokeEvent> sendPoke();

  Future<PokeEvent?> getLastPoke();

  Future<List<PokeEvent>> getPokeEvents();
}

import '../../domain/entities/poke_event.dart';
import '../../domain/repositories/poke_repository.dart';
import '../datasources/poke_cloud_data_source.dart';
import '../datasources/poke_local_data_source.dart';

class PokeRepositoryImpl implements PokeRepository {
  const PokeRepositoryImpl(
    this._localDataSource,
    this._cloudDataSource,
    this._resolveCurrentUserId,
    this._resolveCoupleId,
  );

  static const _pokeMessage = '轻轻戳了你一下';

  final PokeLocalDataSource _localDataSource;
  final PokeCloudDataSource _cloudDataSource;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _resolveCoupleId;

  @override
  Future<PokeEvent> sendPoke() async {
    final local = PokeEvent(
      id: 'poke-${DateTime.now().microsecondsSinceEpoch}',
      sender: PokeSender.me,
      createdAt: DateTime.now(),
      message: _pokeMessage,
    );
    await _localDataSource.upsertPokeEvent(local);

    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return local;
    }

    try {
      final event = await _cloudDataSource.sendPoke(
        coupleId: coupleId,
        currentUserId: currentUserId,
        message: _pokeMessage,
      );
      await _localDataSource.upsertPokeEvent(event);
      return event;
    } catch (_) {
      return local;
    }
  }

  @override
  Future<PokeEvent?> getLastPoke() async {
    final events = await getPokeEvents();
    if (events.isEmpty) {
      return null;
    }
    return events.last;
  }

  @override
  Future<List<PokeEvent>> getPokeEvents() async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId != null &&
        coupleId.isNotEmpty &&
        currentUserId != null &&
        currentUserId.isNotEmpty) {
      try {
        final remote = await _cloudDataSource.listPokeEvents(
          coupleId: coupleId,
          currentUserId: currentUserId,
        );
        await _localDataSource.replacePokeEvents(remote);
      } catch (_) {
        // Keep local poke history visible when cloud sync fails.
      }
    }
    return _localDataSource.getPokeEvents();
  }
}

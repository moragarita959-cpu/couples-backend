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

  final PokeLocalDataSource _localDataSource;
  final PokeCloudDataSource _cloudDataSource;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _resolveCoupleId;

  @override
  Future<PokeEvent> sendPoke() async {
    final coupleId = _resolveCoupleId();
    final currentUserId = _resolveCurrentUserId();
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      final local = PokeEvent(
        id: 'poke-${DateTime.now().microsecondsSinceEpoch}',
        sender: PokeSender.me,
        createdAt: DateTime.now(),
        message: '轻轻戳了你一下',
      );
      await _localDataSource.upsertPokeEvent(local);
      return local;
    }

    final event = await _cloudDataSource.sendPoke(
      coupleId: coupleId,
      currentUserId: currentUserId,
      message: '轻轻戳了你一下',
    );
    await _localDataSource.upsertPokeEvent(event);
    return event;
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
      final remote = await _cloudDataSource.listPokeEvents(
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
      await _localDataSource.replacePokeEvents(remote);
    }
    return _localDataSource.getPokeEvents();
  }
}

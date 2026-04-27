import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/feed_event.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_cloud_data_source.dart';
import '../datasources/feed_local_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(
    this._localDataSource, {
    FeedCloudDataSource? cloudDataSource,
    String? Function()? resolveCurrentUserId,
    String? Function()? resolveCoupleId,
  })  : _cloudDataSource = cloudDataSource,
        _resolveCurrentUserId = resolveCurrentUserId,
        _resolveCoupleId = resolveCoupleId,
        _fallbackCloudDataSource = FeedCloudDataSource(ApiClient());

  final FeedLocalDataSource _localDataSource;
  final FeedCloudDataSource? _cloudDataSource;
  final FeedCloudDataSource _fallbackCloudDataSource;
  final String? Function()? _resolveCurrentUserId;
  final String? Function()? _resolveCoupleId;

  @override
  Stream<List<FeedEvent>> watchEvents({int? limit}) {
    unawaited(_syncFromCloud(limit: limit ?? 100));
    return _localDataSource.watchEvents(limit: limit);
  }

  @override
  Future<void> addEvent({
    required FeedEventType eventType,
    required FeedActorSide actorSide,
    required FeedTargetType targetType,
    required String targetId,
    required String summaryText,
  }) async {
    await _localDataSource.addEvent(
      eventType: eventType,
      actorSide: actorSide,
      targetType: targetType,
      targetId: targetId,
      summaryText: summaryText,
    );
    final identity = await _resolveIdentity();
    final currentUserId = identity.$1;
    final coupleId = identity.$2;
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return;
    }
    try {
      await (_cloudDataSource ?? _fallbackCloudDataSource).addEvent(
        coupleId: coupleId,
        currentUserId: currentUserId,
        eventType: eventType,
        targetType: targetType,
        targetId: targetId,
        summaryText: summaryText,
      );
      await _syncFromCloud(limit: 100);
    } catch (_) {
      // Cloud feed sync is best-effort; keep local timeline available.
    }
  }

  Future<void> _syncFromCloud({required int limit}) async {
    final identity = await _resolveIdentity();
    final currentUserId = identity.$1;
    final coupleId = identity.$2;
    if (coupleId == null ||
        coupleId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return;
    }
    final events = await (_cloudDataSource ?? _fallbackCloudDataSource).listEvents(
      coupleId: coupleId,
      currentUserId: currentUserId,
      limit: limit,
    );
    await _localDataSource.upsertEventsFromCloud(events);
  }

  Future<(String? userId, String? coupleId)> _resolveIdentity() async {
    final userId = _resolveCurrentUserId?.call();
    final coupleId = _resolveCoupleId?.call();
    if ((userId != null && userId.isNotEmpty) &&
        (coupleId != null && coupleId.isNotEmpty)) {
      return (userId, coupleId);
    }
    return _localDataSource.loadIdentityContext();
  }
}

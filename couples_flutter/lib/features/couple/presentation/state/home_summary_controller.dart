import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bill/domain/entities/bill_record.dart';
import '../../../bill/domain/repositories/bill_repository.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../countdown/domain/entities/countdown_event.dart';
import '../../../countdown/domain/repositories/countdown_repository.dart';
import '../../../distance/domain/entities/distance_info.dart';
import '../../../distance/domain/usecases/disable_distance.dart';
import '../../../distance/domain/usecases/enable_distance.dart';
import '../../../distance/domain/usecases/get_distance_info.dart';
import '../../../poke/domain/usecases/get_last_poke.dart';
import '../../../poke/domain/usecases/get_poke_events.dart';
import '../../../poke/domain/usecases/send_poke.dart';
import '../../../poke/domain/entities/poke_event.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../../feed/domain/entities/feed_event.dart';
import '../../../todo/domain/entities/todo_item.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../domain/usecases/evaluate_interaction_quality.dart';
import 'home_summary_vm.dart';

class HomeSummaryController extends StateNotifier<HomeSummaryVm> {
  HomeSummaryController(
    this._todoRepository,
    this._billRepository,
    this._countdownRepository,
    this._getDistanceInfo,
    this._enableDistance,
    this._disableDistance,
    this._getLastPoke,
    this._getPokeEvents,
    this._sendPoke,
    this._chatRepository,
    this._evaluateInteractionQuality,
    this._getCountdownLoveDays,
    this._resolveCurrentUserId,
    this._resolveCurrentCoupleId,
    this._resolveCoupleIdentity, {
    AddFeedEvent? addFeedEvent,
  }) : _addFeedEvent = addFeedEvent,
       super(const HomeSummaryVm.initial()) {
    load();
  }

  final TodoRepository _todoRepository;
  final BillRepository _billRepository;
  final CountdownRepository _countdownRepository;
  final GetDistanceInfo _getDistanceInfo;
  final EnableDistance _enableDistance;
  final DisableDistance _disableDistance;
  final GetLastPoke _getLastPoke;
  final GetPokeEvents _getPokeEvents;
  final SendPoke _sendPoke;
  final AddFeedEvent? _addFeedEvent;
  final ChatRepository _chatRepository;
  final EvaluateInteractionQuality _evaluateInteractionQuality;
  final int Function() _getCountdownLoveDays;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _resolveCurrentCoupleId;
  final String Function() _resolveCoupleIdentity;

  static final DateTime _fallbackLoveStart = DateTime(2024, 1, 1);

  /// Suppress duplicate poke rows in the feed when user taps rapidly.
  DateTime? _lastPokeFeedAt;

  Future<void> load() async {
    try {
      final coupleId = _resolveCurrentCoupleId();
      final countdownEvents = await _safeLoad(
        () => coupleId == null || coupleId.isEmpty
            ? Future.value(const <CountdownEvent>[])
            : _countdownRepository.loadAll(coupleId: coupleId),
        const <CountdownEvent>[],
      );
      final todos = await _safeLoad(
        () => coupleId == null || coupleId.isEmpty
            ? Future.value(const <TodoItem>[])
            : _todoRepository.loadAll(coupleId: coupleId),
        const <TodoItem>[],
      );
      final bills = await _safeLoad(
        () => coupleId == null || coupleId.isEmpty
            ? Future.value(const <BillRecord>[])
            : _billRepository.loadAll(coupleId: coupleId),
        const <BillRecord>[],
      );
      final distanceInfo = await _safeLoad(
        _getDistanceInfo.call,
        _distanceInfoFromState(),
      );
      final lastPoke = await _safeLoad(_getLastPoke.call, null);
      final currentUserId = _resolveCurrentUserId();
      final chatMessages = await _safeLoad(
        () => currentUserId == null || currentUserId.isEmpty
            ? Future.value(const <ChatMessage>[])
            : _chatRepository.getMessages(currentUserId: currentUserId),
        const <ChatMessage>[],
      );
      final chatStats = await _safeLoad(
        () => currentUserId == null || currentUserId.isEmpty
            ? Future.value(null)
            : _chatRepository.getChatStats(currentUserId: currentUserId),
        null,
      );
      final pokeEvents = await _safeLoad(
        _getPokeEvents.call,
        const <PokeEvent>[],
      );

      final now = DateTime.now();
      final today = _dateOnly(now);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final interactionSummary = _evaluateInteractionQuality(
        now: now,
        chatMessages: chatMessages,
        pokeEvents: pokeEvents,
      );
      final loveDays = _resolveLoveDays(now);
      final nextEvent = _pickNearestEvent(countdownEvents, now);

      state = state.copyWith(
        today: now,
        coupleIdentity: _resolveCoupleIdentity(),
        loveDays: loveDays,
        todayTodoDoneCount: todos.where((item) {
          return item.meDone &&
              !item.isDeleted &&
              _dateOnly(item.updatedAt).isAtSameMomentAs(today);
        }).length,
        todayCountdownEvents: countdownEvents.where((event) {
          return !event.isDeleted &&
              _dateOnly(event.date).isAtSameMomentAs(today);
        }).toList(),
        weekBillTotal: bills
            .where(
              (item) => !item.isDeleted && !item.createdAt.isBefore(weekStart),
            )
            .where((item) => item.type == BillType.expense)
            .fold<double>(0, (sum, item) => sum + item.amount),
        monthBillTotal: bills
            .where(
              (item) => !item.isDeleted && !item.createdAt.isBefore(monthStart),
            )
            .where((item) => item.type == BillType.expense)
            .fold<double>(0, (sum, item) => sum + item.amount),
        todayInteractionCount: interactionSummary.todayInteractionCount,
        todayPokeCount: interactionSummary.todayPokeCount,
        todayQuality: interactionSummary.todayQuality,
        todayIsEffective: interactionSummary.todayIsEffective,
        effectiveStreakDays: interactionSummary.effectiveStreakDays,
        achievedMilestone: interactionSummary.achievedMilestone,
        nextMilestone: interactionSummary.nextMilestone,
        recent7DaysMeInitiativeCount:
            interactionSummary.recent7DaysMeInitiativeCount,
        recent7DaysPartnerInitiativeCount:
            interactionSummary.recent7DaysPartnerInitiativeCount,
        meActiveRatio: chatStats?.meInitiativeRatio ?? 0,
        partnerActiveRatio: chatStats?.partnerInitiativeRatio ?? 0,
        recent7DaysDominantTimeBucket:
            interactionSummary.recent7DaysDominantTimeBucket,
        recent7DaysInteractionCount:
            interactionSummary.recent7DaysInteractionCount,
        totalChatCharacterCount: chatStats?.totalCharacterCount ?? 0,
        isDistanceEnabled: distanceInfo.isEnabled,
        distanceKm: _parseDistanceKm(distanceInfo.distanceText),
        myLatitude: distanceInfo.myLatitude,
        myLongitude: distanceInfo.myLongitude,
        partnerLatitude: distanceInfo.partnerLatitude,
        partnerLongitude: distanceInfo.partnerLongitude,
        myLocationVisible: distanceInfo.myLocationVisible,
        partnerLocationVisible: distanceInfo.partnerLocationVisible,
        myLocationLabel: distanceInfo.myLocationLabel,
        partnerLocationLabel: distanceInfo.partnerLocationLabel,
        lastPokeTime: lastPoke?.createdAt,
        lastPokeFromPartner: lastPoke?.sender == PokeSender.partner,
        nextEvent: nextEvent,
        isPoking: false,
        justPoked: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '首页数据加载失败');
    }
  }

  Future<T> _safeLoad<T>(Future<T> Function() loader, T fallback) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  DistanceInfo _distanceInfoFromState() {
    return DistanceInfo(
      isEnabled: state.isDistanceEnabled,
      distanceText: state.distanceKm == null ? null : '${state.distanceKm} km',
      myLatitude: state.myLatitude,
      myLongitude: state.myLongitude,
      partnerLatitude: state.partnerLatitude,
      partnerLongitude: state.partnerLongitude,
      myLocationVisible: state.myLocationVisible,
      partnerLocationVisible: state.partnerLocationVisible,
      myLocationLabel: state.myLocationLabel,
      partnerLocationLabel: state.partnerLocationLabel,
    );
  }

  Future<void> toggleDistance() async {
    try {
      final info = state.isDistanceEnabled
          ? await _disableDistance()
          : await _enableDistance();

      state = state.copyWith(
        isDistanceEnabled: info.isEnabled,
        distanceKm: _parseDistanceKm(info.distanceText),
        myLatitude: info.myLatitude,
        myLongitude: info.myLongitude,
        partnerLatitude: info.partnerLatitude,
        partnerLongitude: info.partnerLongitude,
        myLocationVisible: info.myLocationVisible,
        partnerLocationVisible: info.partnerLocationVisible,
        myLocationLabel: info.myLocationLabel,
        partnerLocationLabel: info.partnerLocationLabel,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '距离状态更新失败');
    }
  }

  Future<void> sendPoke() async {
    state = state.copyWith(
      isPoking: true,
      justPoked: false,
      errorMessage: null,
    );

    try {
      final event = await _sendPoke();
      if (_addFeedEvent != null) {
        final nowTs = DateTime.now();
        if (_lastPokeFeedAt == null ||
            nowTs.difference(_lastPokeFeedAt!) >= const Duration(seconds: 2)) {
          await _addFeedEvent(
            eventType: FeedEventType.todoCreated,
            actorSide: FeedActorSide.me,
            targetType: FeedTargetType.todo,
            targetId: event.id,
            summaryText: '你戳了 TA 一下',
          );
          _lastPokeFeedAt = nowTs;
        }
      }
      final now = DateTime.now();
      final currentUserId = _resolveCurrentUserId();
      final chatMessages = currentUserId == null || currentUserId.isEmpty
          ? const <ChatMessage>[]
          : await _chatRepository.getMessages(currentUserId: currentUserId);
      final chatStats = currentUserId == null || currentUserId.isEmpty
          ? null
          : await _chatRepository.getChatStats(currentUserId: currentUserId);
      final pokeEvents = await _getPokeEvents();
      final interactionSummary = _evaluateInteractionQuality(
        now: now,
        chatMessages: chatMessages,
        pokeEvents: pokeEvents,
      );

      state = state.copyWith(
        today: now,
        isPoking: false,
        justPoked: true,
        lastPokeTime: event.createdAt,
        lastPokeFromPartner: false,
        todayInteractionCount: interactionSummary.todayInteractionCount,
        todayPokeCount: interactionSummary.todayPokeCount,
        todayQuality: interactionSummary.todayQuality,
        todayIsEffective: interactionSummary.todayIsEffective,
        effectiveStreakDays: interactionSummary.effectiveStreakDays,
        achievedMilestone: interactionSummary.achievedMilestone,
        nextMilestone: interactionSummary.nextMilestone,
        recent7DaysMeInitiativeCount:
            interactionSummary.recent7DaysMeInitiativeCount,
        recent7DaysPartnerInitiativeCount:
            interactionSummary.recent7DaysPartnerInitiativeCount,
        meActiveRatio: chatStats?.meInitiativeRatio ?? state.meActiveRatio,
        partnerActiveRatio:
            chatStats?.partnerInitiativeRatio ?? state.partnerActiveRatio,
        recent7DaysDominantTimeBucket:
            interactionSummary.recent7DaysDominantTimeBucket,
        recent7DaysInteractionCount:
            interactionSummary.recent7DaysInteractionCount,
        totalChatCharacterCount:
            chatStats?.totalCharacterCount ?? state.totalChatCharacterCount,
        errorMessage: null,
      );

      await Future<void>.delayed(const Duration(milliseconds: 900));
      state = state.copyWith(justPoked: false, errorMessage: null);
    } catch (_) {
      state = state.copyWith(
        isPoking: false,
        justPoked: false,
        errorMessage: '戳一下失败，请稍后再试',
      );
    }
  }

  int _resolveLoveDays(DateTime now) {
    final fromCountdown = _getCountdownLoveDays();
    if (fromCountdown > 0) {
      return fromCountdown;
    }
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(_fallbackLoveStart).inDays;
  }

  CountdownEvent? _pickNearestEvent(List<CountdownEvent> events, DateTime now) {
    if (events.isEmpty) {
      return null;
    }

    final today = _dateOnly(now);
    final sorted = List<CountdownEvent>.from(events)
      ..sort((a, b) {
        final ad = _dateOnly(a.date).difference(today).inDays;
        final bd = _dateOnly(b.date).difference(today).inDays;
        return ad.compareTo(bd);
      });

    for (final event in sorted) {
      final diff = _dateOnly(event.date).difference(today).inDays;
      if (diff >= 0) {
        return event;
      }
    }
    return sorted.first;
  }

  double? _parseDistanceKm(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawText);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

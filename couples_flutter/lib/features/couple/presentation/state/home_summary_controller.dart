import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bill/domain/repositories/bill_repository.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../countdown/domain/entities/countdown_event.dart';
import '../../../countdown/domain/repositories/countdown_repository.dart';
import '../../../distance/domain/usecases/disable_distance.dart';
import '../../../distance/domain/usecases/enable_distance.dart';
import '../../../distance/domain/usecases/get_distance_info.dart';
import '../../../poke/domain/usecases/get_last_poke.dart';
import '../../../poke/domain/usecases/get_poke_events.dart';
import '../../../poke/domain/usecases/send_poke.dart';
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
    this._resolveCoupleIdentity,
  ) : super(const HomeSummaryVm.initial()) {
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
  final ChatRepository _chatRepository;
  final EvaluateInteractionQuality _evaluateInteractionQuality;
  final int Function() _getCountdownLoveDays;
  final String? Function() _resolveCurrentUserId;
  final String? Function() _resolveCurrentCoupleId;
  final String Function() _resolveCoupleIdentity;

  static final DateTime _fallbackLoveStart = DateTime(2024, 1, 1);

  Future<void> load() async {
    try {
      final coupleId = _resolveCurrentCoupleId();
      final countdownEvents =
          coupleId == null || coupleId.isEmpty
              ? const <CountdownEvent>[]
              : await _countdownRepository.loadAll(coupleId: coupleId);
      final todos =
          coupleId == null || coupleId.isEmpty
              ? const []
              : await _todoRepository.loadAll(coupleId: coupleId);
      final bills =
          coupleId == null || coupleId.isEmpty
              ? const []
              : await _billRepository.loadAll(coupleId: coupleId);
      final distanceInfo = await _getDistanceInfo();
      final lastPoke = await _getLastPoke();
      final currentUserId = _resolveCurrentUserId();
      final chatMessages = currentUserId == null || currentUserId.isEmpty
          ? const <ChatMessage>[]
          : await _chatRepository.getMessages(currentUserId: currentUserId);
      final chatStats = currentUserId == null || currentUserId.isEmpty
          ? null
          : await _chatRepository.getChatStats(currentUserId: currentUserId);
      final pokeEvents = await _getPokeEvents();

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
            .where((item) => !item.isDeleted && !item.createdAt.isBefore(weekStart))
            .fold<double>(0, (sum, item) => sum + item.amount),
        monthBillTotal: bills
            .where((item) => !item.isDeleted && !item.createdAt.isBefore(monthStart))
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
        lastPokeTime: lastPoke?.createdAt,
        nextEvent: nextEvent,
        isPoking: false,
        justPoked: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '首页数据加载失败');
    }
  }

  Future<void> toggleDistance() async {
    try {
      final info = state.isDistanceEnabled
          ? await _disableDistance()
          : await _enableDistance();

      state = state.copyWith(
        isDistanceEnabled: info.isEnabled,
        distanceKm: _parseDistanceKm(info.distanceText),
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

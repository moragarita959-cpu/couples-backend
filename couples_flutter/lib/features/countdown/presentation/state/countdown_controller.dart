import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/domain/entities/feed_event.dart';
import '../../../feed/domain/services/feed_summary_builder.dart';
import '../../../feed/domain/usecases/add_feed_event.dart';
import '../../domain/entities/countdown_event.dart';
import '../../domain/entities/countdown_settings.dart';
import '../../domain/usecases/delete_countdown_event.dart';
import '../../domain/usecases/get_countdown_settings.dart';
import '../../domain/usecases/insert_countdown_event.dart';
import '../../domain/usecases/load_all_countdown_events.dart';
import '../../domain/usecases/refresh_countdown_events.dart';
import '../../domain/usecases/save_countdown_settings.dart';
import '../../domain/usecases/update_countdown_event.dart';
import 'countdown_state.dart';

class CountdownController extends StateNotifier<CountdownState> {
  CountdownController(
    this._loadAllEvents,
    this._refreshEvents,
    this._insertEvent,
    this._updateEvent,
    this._deleteEvent,
    this._getSettings,
    this._saveSettings,
    this._addFeedEvent,
    this._resolveCoupleId,
  ) : super(const CountdownState());

  final LoadAllCountdownEvents _loadAllEvents;
  final RefreshCountdownEvents _refreshEvents;
  final InsertCountdownEvent _insertEvent;
  final UpdateCountdownEvent _updateEvent;
  final DeleteCountdownEvent _deleteEvent;
  final GetCountdownSettings _getSettings;
  final SaveCountdownSettings _saveSettings;
  final AddFeedEvent _addFeedEvent;
  final String? Function() _resolveCoupleId;

  static final DateTime _fallbackLoveStartDate = DateTime(2024, 1, 1);

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  int _daysUntil(DateTime targetDate) {
    final now = _dateOnly(DateTime.now());
    final target = _dateOnly(targetDate);
    return target.difference(now).inDays;
  }

  int _calculateLoveDays(CountdownSettings settings) {
    if (settings.loveDaysOverride != null && settings.loveDaysOverride! >= 0) {
      return settings.loveDaysOverride!;
    }
    final now = _dateOnly(DateTime.now());
    final start = _dateOnly(settings.loveStartDate ?? _fallbackLoveStartDate);
    return now.difference(start).inDays;
  }

  Future<void> loadAll() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final events = await _loadAllEvents(coupleId: coupleId);
      final settings = await _getSettings();
      final sorted = List<CountdownEvent>.from(events)
        ..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date)));
      state = state.copyWith(
        events: sorted.where((event) => !event.isDeleted).toList(),
        settings: settings,
        loveDays: _calculateLoveDays(settings),
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '纪念日加载失败');
    }
  }

  Future<void> refresh() async {
    final coupleId = _resolveCoupleId();
    if (coupleId == null || coupleId.isEmpty) {
      return;
    }
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final events = await _refreshEvents(coupleId: coupleId);
      final settings = await _getSettings();
      final sorted = List<CountdownEvent>.from(events)
        ..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date)));
      state = state.copyWith(
        events: sorted.where((event) => !event.isDeleted).toList(),
        settings: settings,
        loveDays: _calculateLoveDays(settings),
        isRefreshing: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isRefreshing: false, errorMessage: '纪念日同步失败');
    }
  }

  Future<bool> add({
    required String name,
    required DateTime? date,
  }) async {
    final coupleId = _resolveCoupleId();
    final trimmedName = name.trim();
    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(errorMessage: '请先绑定情侣关系');
      return false;
    }
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: '请输入纪念日名称');
      return false;
    }
    if (date == null) {
      state = state.copyWith(errorMessage: '请选择日期');
      return false;
    }

    final now = DateTime.now();
    final optimistic = CountdownEvent(
      id: 'countdown-${now.microsecondsSinceEpoch}',
      coupleId: coupleId,
      name: trimmedName,
      date: _dateOnly(date),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      pendingSync: true,
    );

    final nextEvents = [optimistic, ...state.events];
    state = state.copyWith(events: nextEvents, errorMessage: null);
    try {
      final saved = await _insertEvent(optimistic);
      state = state.copyWith(
        events: [
          saved,
          ...state.events.where((event) => event.id != optimistic.id),
        ]..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date))),
      );
      await _addFeedEvent(
        eventType: FeedEventType.countdownCreated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.countdown,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.countdownCreated(name: saved.name),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '新增纪念日失败');
      return false;
    }
  }

  Future<bool> edit({
    required String id,
    required String name,
    required DateTime? date,
  }) async {
    final target = state.events.cast<CountdownEvent?>().firstWhere(
      (event) => event?.id == id,
      orElse: () => null,
    );
    final trimmedName = name.trim();
    if (target == null) {
      return false;
    }
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: '请输入纪念日名称');
      return false;
    }
    if (date == null) {
      state = state.copyWith(errorMessage: '请选择日期');
      return false;
    }

    final optimistic = target.copyWith(
      name: trimmedName,
      date: _dateOnly(date),
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    state = state.copyWith(
      events: [
        for (final event in state.events)
          if (event.id == id) optimistic else event,
      ]..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date))),
      errorMessage: null,
    );

    try {
      final saved = await _updateEvent(optimistic);
      state = state.copyWith(
        events: [
          for (final event in state.events)
            if (event.id == id) saved else event,
        ]..sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date))),
      );
      await _addFeedEvent(
        eventType: FeedEventType.countdownUpdated,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.countdown,
        targetId: saved.id,
        summaryText: FeedSummaryBuilder.countdownUpdated(name: saved.name),
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '更新纪念日失败');
      return false;
    }
  }

  Future<void> remove(String id) async {
    final target = state.events.cast<CountdownEvent?>().firstWhere(
      (event) => event?.id == id,
      orElse: () => null,
    );
    if (target == null) {
      return;
    }
    final deleted = target.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    state = state.copyWith(
      events: [
        for (final event in state.events)
          if (event.id == id) deleted else event,
      ],
      errorMessage: null,
    );
    try {
      await _deleteEvent(
        id: id,
        coupleId: target.coupleId,
        updatedAt: deleted.updatedAt,
      );
      state = state.copyWith(
        events: state.events.where((event) => !event.isDeleted).toList(),
      );
      await _addFeedEvent(
        eventType: FeedEventType.countdownDeleted,
        actorSide: FeedActorSide.me,
        targetType: FeedTargetType.countdown,
        targetId: id,
        summaryText: FeedSummaryBuilder.countdownDeleted(name: target.name),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: '删除纪念日失败');
    }
  }

  Future<bool> saveRelationshipSettings({
    required DateTime? loveStartDate,
    required String manualLoveDaysText,
  }) async {
    final trimmed = manualLoveDaysText.trim();
    int? overrideDays;
    if (trimmed.isNotEmpty) {
      overrideDays = int.tryParse(trimmed);
      if (overrideDays == null || overrideDays < 0) {
        state = state.copyWith(errorMessage: '手动覆盖天数必须是大于等于 0 的整数');
        return false;
      }
    }

    await _saveSettings(
      loveStartDate: loveStartDate == null ? null : _dateOnly(loveStartDate),
      loveDaysOverride: overrideDays,
    );
    final settings = await _getSettings();
    state = state.copyWith(
      settings: settings,
      loveDays: _calculateLoveDays(settings),
      errorMessage: null,
    );
    return true;
  }

  int getRemainingDays(DateTime date) {
    return _daysUntil(date);
  }
}

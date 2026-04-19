import '../../../chat/domain/entities/chat_message.dart';
import '../../../poke/domain/entities/poke_event.dart';
import '../entities/interaction_quality.dart';
import '../entities/interaction_summary.dart';
import '../entities/interaction_time_bucket.dart';

class EvaluateInteractionQuality {
  const EvaluateInteractionQuality();

  static const List<int> _milestones = <int>[7, 30, 100];

  InteractionSummary call({
    required DateTime now,
    required List<ChatMessage> chatMessages,
    required List<PokeEvent> pokeEvents,
  }) {
    final actionsByDay = <DateTime, _DailyActionCounter>{};
    final recent7DaysTimeBuckets = _TimeBucketCounter();

    var recent7DaysMeInitiativeCount = 0;
    var recent7DaysPartnerInitiativeCount = 0;

    for (final message in chatMessages) {
      final day = _dateOnly(message.timestamp);
      final counter = actionsByDay.putIfAbsent(day, _DailyActionCounter.new);
      if (message.sender == ChatSender.partner) {
        counter.partner += 1;
      } else {
        counter.me += 1;
      }

      if (_isWithinRecent7Days(now: now, target: message.timestamp)) {
        if (message.sender == ChatSender.partner) {
          recent7DaysPartnerInitiativeCount += 1;
        } else {
          recent7DaysMeInitiativeCount += 1;
        }
        recent7DaysTimeBuckets.add(message.timestamp);
      }
    }

    for (final poke in pokeEvents) {
      final day = _dateOnly(poke.createdAt);
      final counter = actionsByDay.putIfAbsent(day, _DailyActionCounter.new);
      counter.poke += 1;
      if (poke.sender == PokeSender.partner) {
        counter.partner += 1;
      } else {
        counter.me += 1;
      }

      if (_isWithinRecent7Days(now: now, target: poke.createdAt)) {
        if (poke.sender == PokeSender.partner) {
          recent7DaysPartnerInitiativeCount += 1;
        } else {
          recent7DaysMeInitiativeCount += 1;
        }
        recent7DaysTimeBuckets.add(poke.createdAt);
      }
    }

    final today = _dateOnly(now);
    final todayCounter = actionsByDay[today] ?? _DailyActionCounter.empty();
    final todayQuality = _resolveQuality(todayCounter);
    final todayIsEffective = todayQuality == InteractionQuality.effective;
    final effectiveStreakDays = _calculateEffectiveStreak(
      now: now,
      actionsByDay: actionsByDay,
    );

    final achievedMilestone = _findAchievedMilestone(effectiveStreakDays);
    final nextMilestone = _findNextMilestone(effectiveStreakDays);
    final recent7DaysInteractionCount =
        recent7DaysMeInitiativeCount + recent7DaysPartnerInitiativeCount;

    return InteractionSummary(
      todayInteractionCount: todayCounter.total,
      todayPokeCount: todayCounter.poke,
      todayQuality: todayQuality,
      todayIsEffective: todayIsEffective,
      effectiveStreakDays: effectiveStreakDays,
      todayMeActionCount: todayCounter.me,
      todayPartnerActionCount: todayCounter.partner,
      achievedMilestone: achievedMilestone,
      nextMilestone: nextMilestone,
      recent7DaysMeInitiativeCount: recent7DaysMeInitiativeCount,
      recent7DaysPartnerInitiativeCount: recent7DaysPartnerInitiativeCount,
      recent7DaysDominantTimeBucket: recent7DaysTimeBuckets.dominantBucket,
      recent7DaysInteractionCount: recent7DaysInteractionCount,
    );
  }

  int _calculateEffectiveStreak({
    required DateTime now,
    required Map<DateTime, _DailyActionCounter> actionsByDay,
  }) {
    if (actionsByDay.isEmpty) {
      return 0;
    }

    final today = _dateOnly(now);
    var cursor = today;
    if (_resolveQuality(actionsByDay[cursor] ?? _DailyActionCounter.empty()) !=
        InteractionQuality.effective) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (_resolveQuality(
          actionsByDay[cursor] ?? _DailyActionCounter.empty(),
        ) ==
        InteractionQuality.effective) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  InteractionQuality _resolveQuality(_DailyActionCounter counter) {
    if (counter.total == 0) {
      return InteractionQuality.none;
    }

    final bothActive = counter.me > 0 && counter.partner > 0;
    if (!bothActive) {
      return InteractionQuality.singleSided;
    }

    if (counter.total >= 4 || (counter.me >= 2 && counter.partner >= 2)) {
      return InteractionQuality.effective;
    }
    return InteractionQuality.light;
  }

  bool _isWithinRecent7Days({required DateTime now, required DateTime target}) {
    final today = _dateOnly(now);
    final earliest = today.subtract(const Duration(days: 6));
    final targetDay = _dateOnly(target);
    return !targetDay.isBefore(earliest) && !targetDay.isAfter(today);
  }

  int? _findAchievedMilestone(int streakDays) {
    int? matched;
    for (final m in _milestones) {
      if (streakDays >= m) {
        matched = m;
      }
    }
    return matched;
  }

  int? _findNextMilestone(int streakDays) {
    for (final m in _milestones) {
      if (streakDays < m) {
        return m;
      }
    }
    return null;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _DailyActionCounter {
  _DailyActionCounter({this.me = 0, this.partner = 0, this.poke = 0});

  _DailyActionCounter.empty() : me = 0, partner = 0, poke = 0;

  int me;
  int partner;
  int poke;

  int get total => me + partner;
}

class _TimeBucketCounter {
  int midnightToMorning = 0;
  int morningToNoon = 0;
  int noonToEvening = 0;
  int eveningToMidnight = 0;

  void add(DateTime time) {
    final hour = time.hour;
    if (hour < 6) {
      midnightToMorning += 1;
      return;
    }
    if (hour < 12) {
      morningToNoon += 1;
      return;
    }
    if (hour < 18) {
      noonToEvening += 1;
      return;
    }
    eveningToMidnight += 1;
  }

  InteractionTimeBucket get dominantBucket {
    final counts = <InteractionTimeBucket, int>{
      InteractionTimeBucket.midnightToMorning: midnightToMorning,
      InteractionTimeBucket.morningToNoon: morningToNoon,
      InteractionTimeBucket.noonToEvening: noonToEvening,
      InteractionTimeBucket.eveningToMidnight: eveningToMidnight,
    };

    var bestBucket = InteractionTimeBucket.none;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestBucket = entry.key;
        bestCount = entry.value;
      }
    }
    return bestBucket;
  }
}

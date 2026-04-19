import 'interaction_quality.dart';
import 'interaction_time_bucket.dart';

class InteractionSummary {
  const InteractionSummary({
    required this.todayInteractionCount,
    required this.todayPokeCount,
    required this.todayQuality,
    required this.todayIsEffective,
    required this.effectiveStreakDays,
    required this.todayMeActionCount,
    required this.todayPartnerActionCount,
    required this.achievedMilestone,
    required this.nextMilestone,
    required this.recent7DaysMeInitiativeCount,
    required this.recent7DaysPartnerInitiativeCount,
    required this.recent7DaysDominantTimeBucket,
    required this.recent7DaysInteractionCount,
  });

  final int todayInteractionCount;
  final int todayPokeCount;
  final InteractionQuality todayQuality;
  final bool todayIsEffective;
  final int effectiveStreakDays;
  final int todayMeActionCount;
  final int todayPartnerActionCount;
  final int? achievedMilestone;
  final int? nextMilestone;
  final int recent7DaysMeInitiativeCount;
  final int recent7DaysPartnerInitiativeCount;
  final InteractionTimeBucket recent7DaysDominantTimeBucket;
  final int recent7DaysInteractionCount;
}

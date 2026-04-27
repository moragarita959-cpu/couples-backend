import '../../../countdown/domain/entities/countdown_event.dart';
import '../../domain/entities/interaction_quality.dart';
import '../../domain/entities/interaction_time_bucket.dart';

class HomeSummaryVm {
  const HomeSummaryVm({
    required this.today,
    required this.coupleIdentity,
    required this.loveDays,
    required this.todayTodoDoneCount,
    required this.todayCountdownEvents,
    required this.weekBillTotal,
    required this.monthBillTotal,
    required this.todayInteractionCount,
    required this.todayPokeCount,
    required this.todayQuality,
    required this.todayIsEffective,
    required this.effectiveStreakDays,
    required this.achievedMilestone,
    required this.nextMilestone,
    required this.recent7DaysMeInitiativeCount,
    required this.recent7DaysPartnerInitiativeCount,
    required this.meActiveRatio,
    required this.partnerActiveRatio,
    required this.recent7DaysDominantTimeBucket,
    required this.recent7DaysInteractionCount,
    required this.totalChatCharacterCount,
    required this.isDistanceEnabled,
    required this.distanceKm,
    required this.myLatitude,
    required this.myLongitude,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.myLocationVisible,
    required this.partnerLocationVisible,
    required this.myLocationLabel,
    required this.partnerLocationLabel,
    required this.lastPokeTime,
    required this.lastPokeFromPartner,
    required this.nextEvent,
    required this.isPoking,
    required this.justPoked,
    this.errorMessage,
  });

  const HomeSummaryVm.initial()
    : today = null,
      coupleIdentity = '你 & TA',
      loveDays = 0,
      todayTodoDoneCount = 0,
      todayCountdownEvents = const <CountdownEvent>[],
      weekBillTotal = 0,
      monthBillTotal = 0,
      todayInteractionCount = 0,
      todayPokeCount = 0,
      todayQuality = InteractionQuality.none,
      todayIsEffective = false,
      effectiveStreakDays = 0,
      achievedMilestone = null,
      nextMilestone = 7,
      recent7DaysMeInitiativeCount = 0,
      recent7DaysPartnerInitiativeCount = 0,
      meActiveRatio = 0,
      partnerActiveRatio = 0,
      recent7DaysDominantTimeBucket = InteractionTimeBucket.none,
      recent7DaysInteractionCount = 0,
      totalChatCharacterCount = 0,
      isDistanceEnabled = false,
      distanceKm = null,
      myLatitude = null,
      myLongitude = null,
      partnerLatitude = null,
      partnerLongitude = null,
      myLocationVisible = true,
      partnerLocationVisible = true,
      myLocationLabel = null,
      partnerLocationLabel = null,
      lastPokeTime = null,
      lastPokeFromPartner = false,
      nextEvent = null,
      isPoking = false,
      justPoked = false,
      errorMessage = null;

  final DateTime? today;
  final String coupleIdentity;
  final int loveDays;
  final int todayTodoDoneCount;
  final List<CountdownEvent> todayCountdownEvents;
  final double weekBillTotal;
  final double monthBillTotal;
  final int todayInteractionCount;
  final int todayPokeCount;
  final InteractionQuality todayQuality;
  final bool todayIsEffective;
  final int effectiveStreakDays;
  final int? achievedMilestone;
  final int? nextMilestone;
  final int recent7DaysMeInitiativeCount;
  final int recent7DaysPartnerInitiativeCount;
  final double meActiveRatio;
  final double partnerActiveRatio;
  final InteractionTimeBucket recent7DaysDominantTimeBucket;
  final int recent7DaysInteractionCount;
  final int totalChatCharacterCount;
  final bool isDistanceEnabled;
  final double? distanceKm;
  final double? myLatitude;
  final double? myLongitude;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final bool myLocationVisible;
  final bool partnerLocationVisible;
  final String? myLocationLabel;
  final String? partnerLocationLabel;
  final DateTime? lastPokeTime;
  final bool lastPokeFromPartner;
  final CountdownEvent? nextEvent;
  final bool isPoking;
  final bool justPoked;
  final String? errorMessage;

  static const Object _noChange = Object();

  HomeSummaryVm copyWith({
    Object? today = _noChange,
    String? coupleIdentity,
    int? loveDays,
    int? todayTodoDoneCount,
    List<CountdownEvent>? todayCountdownEvents,
    double? weekBillTotal,
    double? monthBillTotal,
    int? todayInteractionCount,
    int? todayPokeCount,
    InteractionQuality? todayQuality,
    bool? todayIsEffective,
    int? effectiveStreakDays,
    Object? achievedMilestone = _noChange,
    Object? nextMilestone = _noChange,
    int? recent7DaysMeInitiativeCount,
    int? recent7DaysPartnerInitiativeCount,
    double? meActiveRatio,
    double? partnerActiveRatio,
    InteractionTimeBucket? recent7DaysDominantTimeBucket,
    int? recent7DaysInteractionCount,
    int? totalChatCharacterCount,
    bool? isDistanceEnabled,
    Object? distanceKm = _noChange,
    Object? myLatitude = _noChange,
    Object? myLongitude = _noChange,
    Object? partnerLatitude = _noChange,
    Object? partnerLongitude = _noChange,
    bool? myLocationVisible,
    bool? partnerLocationVisible,
    Object? myLocationLabel = _noChange,
    Object? partnerLocationLabel = _noChange,
    Object? lastPokeTime = _noChange,
    bool? lastPokeFromPartner,
    Object? nextEvent = _noChange,
    bool? isPoking,
    bool? justPoked,
    Object? errorMessage = _noChange,
  }) {
    return HomeSummaryVm(
      today: identical(today, _noChange) ? this.today : today as DateTime?,
      coupleIdentity: coupleIdentity ?? this.coupleIdentity,
      loveDays: loveDays ?? this.loveDays,
      todayTodoDoneCount: todayTodoDoneCount ?? this.todayTodoDoneCount,
      todayCountdownEvents: todayCountdownEvents ?? this.todayCountdownEvents,
      weekBillTotal: weekBillTotal ?? this.weekBillTotal,
      monthBillTotal: monthBillTotal ?? this.monthBillTotal,
      todayInteractionCount:
          todayInteractionCount ?? this.todayInteractionCount,
      todayPokeCount: todayPokeCount ?? this.todayPokeCount,
      todayQuality: todayQuality ?? this.todayQuality,
      todayIsEffective: todayIsEffective ?? this.todayIsEffective,
      effectiveStreakDays: effectiveStreakDays ?? this.effectiveStreakDays,
      achievedMilestone: identical(achievedMilestone, _noChange)
          ? this.achievedMilestone
          : achievedMilestone as int?,
      nextMilestone: identical(nextMilestone, _noChange)
          ? this.nextMilestone
          : nextMilestone as int?,
      recent7DaysMeInitiativeCount:
          recent7DaysMeInitiativeCount ?? this.recent7DaysMeInitiativeCount,
      recent7DaysPartnerInitiativeCount:
          recent7DaysPartnerInitiativeCount ??
          this.recent7DaysPartnerInitiativeCount,
      meActiveRatio: meActiveRatio ?? this.meActiveRatio,
      partnerActiveRatio: partnerActiveRatio ?? this.partnerActiveRatio,
      recent7DaysDominantTimeBucket:
          recent7DaysDominantTimeBucket ?? this.recent7DaysDominantTimeBucket,
      recent7DaysInteractionCount:
          recent7DaysInteractionCount ?? this.recent7DaysInteractionCount,
      totalChatCharacterCount:
          totalChatCharacterCount ?? this.totalChatCharacterCount,
      isDistanceEnabled: isDistanceEnabled ?? this.isDistanceEnabled,
      distanceKm: identical(distanceKm, _noChange)
          ? this.distanceKm
          : distanceKm as double?,
      myLatitude: identical(myLatitude, _noChange)
          ? this.myLatitude
          : myLatitude as double?,
      myLongitude: identical(myLongitude, _noChange)
          ? this.myLongitude
          : myLongitude as double?,
      partnerLatitude: identical(partnerLatitude, _noChange)
          ? this.partnerLatitude
          : partnerLatitude as double?,
      partnerLongitude: identical(partnerLongitude, _noChange)
          ? this.partnerLongitude
          : partnerLongitude as double?,
      myLocationVisible: myLocationVisible ?? this.myLocationVisible,
      partnerLocationVisible:
          partnerLocationVisible ?? this.partnerLocationVisible,
      myLocationLabel: identical(myLocationLabel, _noChange)
          ? this.myLocationLabel
          : myLocationLabel as String?,
      partnerLocationLabel: identical(partnerLocationLabel, _noChange)
          ? this.partnerLocationLabel
          : partnerLocationLabel as String?,
      lastPokeTime: identical(lastPokeTime, _noChange)
          ? this.lastPokeTime
          : lastPokeTime as DateTime?,
      lastPokeFromPartner: lastPokeFromPartner ?? this.lastPokeFromPartner,
      nextEvent: identical(nextEvent, _noChange)
          ? this.nextEvent
          : nextEvent as CountdownEvent?,
      isPoking: isPoking ?? this.isPoking,
      justPoked: justPoked ?? this.justPoked,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

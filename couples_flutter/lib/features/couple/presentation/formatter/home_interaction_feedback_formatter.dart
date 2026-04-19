import '../../domain/entities/interaction_quality.dart';
import '../../domain/entities/interaction_time_bucket.dart';

class HomeInteractionFeedbackFormatter {
  const HomeInteractionFeedbackFormatter._();

  static String mainStatusTitle(int effectiveStreakDays) {
    return '连续有效互动 $effectiveStreakDays 天';
  }

  static String mainStatusSubtitle({
    required bool todayIsEffective,
    required InteractionQuality todayQuality,
    required int effectiveStreakDays,
  }) {
    if (todayIsEffective) {
      return '今天已经稳稳接住彼此的回应';
    }
    if (todayQuality == InteractionQuality.singleSided ||
        todayQuality == InteractionQuality.light) {
      return '今天再来一次双向互动，就能把连续记录续上';
    }
    if (effectiveStreakDays > 0) {
      return '今天还没开始，记得把这段连续陪伴留住';
    }
    return '从今天开始，建立新的连续陪伴';
  }

  static String nextStepSuggestion({
    required bool todayIsEffective,
    required InteractionQuality todayQuality,
    required int effectiveStreakDays,
    required int? nextMilestone,
    required InteractionTimeBucket recentBucket,
    required int recentInteractionCount,
  }) {
    if (todayIsEffective) {
      if (nextMilestone != null && effectiveStreakDays < nextMilestone) {
        return '今天已经达成有效互动，再聊一会儿会更接近下个小目标';
      }
      return '今天已经达成有效互动，把这份默契继续保持';
    }

    if (todayQuality == InteractionQuality.singleSided ||
        todayQuality == InteractionQuality.light) {
      return '今天还差一次回应，就能延续你们的连续记录';
    }

    if (recentInteractionCount > 0 &&
        recentBucket == InteractionTimeBucket.eveningToMidnight) {
      return '你们最近常在晚上聊得最投入，今晚也别错过';
    }

    return '先发一句问候吧，今天的关系节奏就会慢慢热起来';
  }

  static String qualityLabel(InteractionQuality quality) {
    switch (quality) {
      case InteractionQuality.none:
        return '还没开始';
      case InteractionQuality.singleSided:
        return '单向互动';
      case InteractionQuality.light:
        return '有来有回';
      case InteractionQuality.effective:
        return '状态很棒';
    }
  }

  static String milestoneText({
    required int effectiveStreakDays,
    required int? achievedMilestone,
    required int? nextMilestone,
  }) {
    if (effectiveStreakDays <= 0) {
      if (nextMilestone != null) {
        return '从今天出发，朝着 $nextMilestone 天的陪伴小目标前进';
      }
      return '从今天出发，开始新的陪伴记录';
    }

    if (achievedMilestone != null && effectiveStreakDays == achievedMilestone) {
      return '你们刚好达成 $achievedMilestone 天连续陪伴，值得纪念';
    }

    if (nextMilestone != null) {
      final remaining = nextMilestone - effectiveStreakDays;
      return '再坚持 $remaining 天，就到下一个陪伴小目标';
    }

    return '已经连续有效互动 $effectiveStreakDays 天，保持得很好';
  }

  static StreakProgressInfo streakProgress({
    required int effectiveStreakDays,
    required int? achievedMilestone,
    required int? nextMilestone,
  }) {
    if (nextMilestone == null) {
      return StreakProgressInfo(
        progress: 1,
        summaryText: '当前连续有效互动 $effectiveStreakDays 天',
        goalText: '你们已经超过主要目标，继续稳稳相爱',
      );
    }

    final start = achievedMilestone ?? 0;
    final denominator = (nextMilestone - start).clamp(1, 9999);
    final rawProgress = (effectiveStreakDays - start) / denominator;
    final progress = rawProgress.clamp(0, 1).toDouble();
    final remaining = (nextMilestone - effectiveStreakDays).clamp(0, 9999);

    return StreakProgressInfo(
      progress: progress,
      summaryText: '当前连续有效互动 $effectiveStreakDays 天',
      goalText: remaining == 0 ? '你们已经到达这个阶段的小目标' : '离这个阶段的小目标还差 $remaining 天',
    );
  }

  static String initiativeSummary({
    required int meCount,
    required int partnerCount,
  }) {
    if (meCount >= partnerCount + 2) {
      return '这几天你更常先开口';
    }
    if (partnerCount >= meCount + 2) {
      return '这几天 TA 更常先来找你';
    }
    return '这几天你们的主动度很均衡';
  }

  static String timeDistributionSummary({
    required InteractionTimeBucket bucket,
    required int totalCount,
  }) {
    if (totalCount <= 0 || bucket == InteractionTimeBucket.none) {
      return '最近互动不多，今天先说一句想你吧';
    }

    switch (bucket) {
      case InteractionTimeBucket.midnightToMorning:
        return '你们最近常在深夜聊到心里去';
      case InteractionTimeBucket.morningToNoon:
        return '你们最近更常在早晨互相打招呼';
      case InteractionTimeBucket.noonToEvening:
        return '你们最近白天的互动最密集';
      case InteractionTimeBucket.eveningToMidnight:
        return '你们最近晚上最有聊天氛围';
      case InteractionTimeBucket.none:
        return '最近互动不多，今天先说一句想你吧';
    }
  }
}

class StreakProgressInfo {
  const StreakProgressInfo({
    required this.progress,
    required this.summaryText,
    required this.goalText,
  });

  final double progress;
  final String summaryText;
  final String goalText;
}

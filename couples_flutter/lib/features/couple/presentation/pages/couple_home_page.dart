import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../formatter/home_interaction_feedback_formatter.dart';
import '../formatter/home_summary_formatter.dart';
import '../state/home_summary_vm.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_grid_menu.dart';
import '../widgets/home_header_section.dart';
import '../widgets/home_info_cards.dart';
import '../widgets/home_interaction_status.dart';
import '../widgets/home_poke_card.dart';
import '../widgets/home_recent_feed_section.dart';

class CoupleHomePage extends ConsumerStatefulWidget {
  const CoupleHomePage({super.key});

  @override
  ConsumerState<CoupleHomePage> createState() => _CoupleHomePageState();
}

class _CoupleHomePageState extends ConsumerState<CoupleHomePage> {
  bool _showHeader = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showHeader = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(homeSummaryControllerProvider);
    final recentFeedAsync = ref.watch(recentFeedEventsStreamProvider);
    final controller = ref.read(homeSummaryControllerProvider.notifier);

    ref.listen<HomeSummaryVm>(homeSummaryControllerProvider, (previous, next) {
      final wasPoked = previous?.justPoked ?? false;
      if (!wasPoked && next.justPoked) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'TA \u60f3\u4f60\u4e86\uff0c\u8f7b\u8f7b\u6233\u4e86\u4f60\u4e00\u4e0b \ud83d\udc97',
              ),
              duration: Duration(milliseconds: 1400),
            ),
          );
      }
    });

    final loveDaysText = HomeSummaryFormatter.formatLoveDays(vm.loveDays);
    final todayText = HomeSummaryFormatter.formatToday(vm.today);
    final distanceText = HomeSummaryFormatter.formatDistance(
      isEnabled: vm.isDistanceEnabled,
      distanceKm: vm.distanceKm,
    );
    final pokeText = HomeSummaryFormatter.formatPokeTime(vm.lastPokeTime);
    final anniversaryText = HomeSummaryFormatter.formatNextAnniversary(
      nextEvent: vm.nextEvent,
      today: vm.today,
    );
    final pokeButtonText = HomeSummaryFormatter.pokeButtonText(
      isPoking: vm.isPoking,
      justPoked: vm.justPoked,
    );
    final qualityLabel = HomeInteractionFeedbackFormatter.qualityLabel(
      vm.todayQuality,
    );
    final mainStatusTitle = HomeInteractionFeedbackFormatter.mainStatusTitle(
      vm.effectiveStreakDays,
    );
    final mainStatusSubtitle =
        HomeInteractionFeedbackFormatter.mainStatusSubtitle(
          todayIsEffective: vm.todayIsEffective,
          todayQuality: vm.todayQuality,
          effectiveStreakDays: vm.effectiveStreakDays,
        );
    final milestoneText = HomeInteractionFeedbackFormatter.milestoneText(
      effectiveStreakDays: vm.effectiveStreakDays,
      achievedMilestone: vm.achievedMilestone,
      nextMilestone: vm.nextMilestone,
    );
    final streakProgressInfo = HomeInteractionFeedbackFormatter.streakProgress(
      effectiveStreakDays: vm.effectiveStreakDays,
      achievedMilestone: vm.achievedMilestone,
      nextMilestone: vm.nextMilestone,
    );
    final initiativeSummaryText =
        HomeInteractionFeedbackFormatter.initiativeSummary(
          meCount: vm.recent7DaysMeInitiativeCount,
          partnerCount: vm.recent7DaysPartnerInitiativeCount,
        );
    final timeDistributionText =
        HomeInteractionFeedbackFormatter.timeDistributionSummary(
          bucket: vm.recent7DaysDominantTimeBucket,
          totalCount: vm.recent7DaysInteractionCount,
        );
    final activeRatioText =
        '主动度占比：我 ${(vm.meActiveRatio * 100).round()}% / TA ${(vm.partnerActiveRatio * 100).round()}%';
    final characterCountText = '累计聊天字数：${vm.totalChatCharacterCount}';
    final nextStepSuggestion =
        HomeInteractionFeedbackFormatter.nextStepSuggestion(
          todayQuality: vm.todayQuality,
          todayIsEffective: vm.todayIsEffective,
          effectiveStreakDays: vm.effectiveStreakDays,
          nextMilestone: vm.nextMilestone,
          recentBucket: vm.recent7DaysDominantTimeBucket,
          recentInteractionCount: vm.recent7DaysInteractionCount,
        );

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      body: SafeArea(
        child: DecoratedBox(
          decoration: CoupleUi.pageBackgroundDecoration(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              CoupleUi.pagePadding,
              14,
              CoupleUi.pagePadding,
              18,
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                offset: _showHeader ? Offset.zero : const Offset(0, 0.05),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOut,
                  opacity: _showHeader ? 1 : 0,
                  child: HomeHeaderSection(
                    title: '\u6211\u4eec\u7684\u5c0f\u7a9d',
                    coupleIdentity: vm.coupleIdentity,
                    subtitle:
                        '\u4eca\u5929\u4e5f\u8981\u597d\u597d\u76f8\u7231',
                    loveDaysText: loveDaysText,
                    todayText: todayText,
                  ),
                ),
              ),
              const SizedBox(height: CoupleUi.sectionSpacing),
              HomeInteractionStatus(
                mainStatusTitle: mainStatusTitle,
                mainStatusSubtitle: mainStatusSubtitle,
                nextStepSuggestion: nextStepSuggestion,
                streakProgressValue: streakProgressInfo.progress,
                streakGoalText: streakProgressInfo.goalText,
                milestoneText: milestoneText,
                todayInteractionCount: vm.todayInteractionCount,
                qualityLabel: qualityLabel,
                initiativeSummaryText: initiativeSummaryText,
                timeDistributionText: timeDistributionText,
                activeRatioText: activeRatioText,
                characterCountText: characterCountText,
              ),
              const SizedBox(height: CoupleUi.sectionSpacing),
              recentFeedAsync.when(
                data: (events) => HomeRecentFeedSection(events: events),
                loading: () => const HomeRecentFeedSection(events: []),
                error: (_, __) => const HomeRecentFeedSection(events: []),
              ),
              const SizedBox(height: CoupleUi.sectionSpacing),
              HomePokeCard(
                justPoked: vm.justPoked,
                pokeButtonText: pokeButtonText,
                lastPokeText: pokeText,
                onPoke: vm.isPoking ? null : controller.sendPoke,
                initialTodayPokeCount: vm.todayPokeCount,
                interactionStreakDays: vm.effectiveStreakDays,
              ),
              const SizedBox(height: CoupleUi.sectionSpacing),
              HomeInfoCards(
                loveDays: vm.loveDays,
                distanceText: distanceText,
                nextAnniversaryText: anniversaryText,
                isDistanceEnabled: vm.isDistanceEnabled,
                onToggleDistance: controller.toggleDistance,
              ),
              const SizedBox(height: 14),
              const HomeGridMenu(),
              const SizedBox(height: 18),
              const HomeFooter(),
              if (vm.errorMessage != null && vm.errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

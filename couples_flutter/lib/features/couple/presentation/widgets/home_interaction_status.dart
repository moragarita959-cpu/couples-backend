import 'package:flutter/material.dart';

class HomeInteractionStatus extends StatelessWidget {
  const HomeInteractionStatus({
    super.key,
    required this.mainStatusTitle,
    required this.mainStatusSubtitle,
    required this.nextStepSuggestion,
    required this.streakProgressValue,
    required this.streakGoalText,
    required this.milestoneText,
    required this.todayInteractionCount,
    required this.qualityLabel,
    required this.initiativeSummaryText,
    required this.timeDistributionText,
    required this.activeRatioText,
    required this.characterCountText,
  });

  final String mainStatusTitle;
  final String mainStatusSubtitle;
  final String nextStepSuggestion;
  final double streakProgressValue;
  final String streakGoalText;
  final String milestoneText;
  final int todayInteractionCount;
  final String qualityLabel;
  final String initiativeSummaryText;
  final String timeDistributionText;
  final String activeRatioText;
  final String characterCountText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MainStatusCard(
            title: mainStatusTitle,
            subtitle: mainStatusSubtitle,
            progress: streakProgressValue,
            goalText: streakGoalText,
          ),
          const SizedBox(height: 10),
          _SuggestionBar(text: nextStepSuggestion),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusPill(
                icon: Icons.favorite_rounded,
                text: '今日状态：$qualityLabel',
                theme: theme,
              ),
              _StatusPill(
                icon: Icons.chat_bubble_outline_rounded,
                text: '今日互动：$todayInteractionCount',
                theme: theme,
              ),
              _StatusPill(
                icon: Icons.pie_chart_outline_rounded,
                text: activeRatioText,
                theme: theme,
              ),
              _StatusPill(
                icon: Icons.text_fields_rounded,
                text: characterCountText,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SummaryStrip(
            milestoneText: milestoneText,
            rhythmText: '$initiativeSummaryText | $timeDistributionText',
          ),
        ],
      ),
    );
  }
}

class _MainStatusCard extends StatelessWidget {
  const _MainStatusCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.goalText,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String goalText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBFD), Color(0xFFFFF3F7)],
        ),
        border: Border.all(color: const Color(0x2CB63E5A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14B63E5A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF8D2D49),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xCC3E2A30),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: const Color(0x17B63E5A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE37492),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            goalText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xB33E2A30),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x29B63E5A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.tips_and_updates_outlined,
              size: 16,
              color: Color(0xFFB85772),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9C3852),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.milestoneText, required this.rhythmText});

  final String milestoneText;
  final String rhythmText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            milestoneText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xB03E2A30),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rhythmText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0x993E2A30),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB65A73)),
          const SizedBox(width: 5),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xB33E2A30),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

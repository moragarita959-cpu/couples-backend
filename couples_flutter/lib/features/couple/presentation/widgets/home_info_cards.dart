import 'package:flutter/material.dart';

class HomeInfoCards extends StatelessWidget {
  const HomeInfoCards({
    super.key,
    required this.loveDays,
    required this.distanceText,
    required this.nextAnniversaryText,
    required this.isDistanceEnabled,
    required this.onToggleDistance,
  });

  final int loveDays;
  final String distanceText;
  final String nextAnniversaryText;
  final bool isDistanceEnabled;
  final VoidCallback onToggleDistance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关系信息',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3E2A30),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _InfoMiniCard(
                title: '恋爱天数',
                value: '第 $loveDays 天',
                helper: '一起走过的日子',
                icon: Icons.favorite_rounded,
                valueColor: const Color(0xFFB63E5A),
                backgroundColor: const Color(0xFFFFF4F8),
                iconColor: const Color(0xFFE85A7A),
                emphasize: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoMiniCard(
                title: '距离',
                value: distanceText,
                helper: isDistanceEnabled ? '已开启首页显示' : '距离功能未开启',
                icon: Icons.social_distance_outlined,
                actionText: isDistanceEnabled ? '关闭' : '开启',
                onActionTap: onToggleDistance,
                iconColor: isDistanceEnabled
                    ? const Color(0xFFE85A7A)
                    : const Color(0xFF9A9A9A),
                backgroundColor: isDistanceEnabled
                    ? Colors.white
                    : const Color(0xFFF8F8F8),
                borderColor: isDistanceEnabled
                    ? const Color(0x22000000)
                    : const Color(0x14000000),
                valueColor: isDistanceEnabled
                    ? const Color(0xFF3E2A30)
                    : const Color(0x883E2A30),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InfoMiniCard(
                title: '最近纪念日',
                value: nextAnniversaryText,
                helper: '下一次想一起庆祝',
                icon: Icons.auto_awesome,
                valueColor: const Color(0xFF8D4B67),
                backgroundColor: const Color(0xFFFFF8FB),
                iconColor: const Color(0xFFD36B8A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoMiniCard extends StatelessWidget {
  const _InfoMiniCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    this.actionText,
    this.onActionTap,
    this.iconColor = const Color(0xFFE85A7A),
    this.valueColor = const Color(0xFF3E2A30),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x1F000000),
    this.emphasize = false,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Color iconColor;
  final Color valueColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 136,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0x8F3E2A30),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                    color: valueColor,
                    height: 1.24,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  helper,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0x783E2A30),
                    fontSize: 11.2,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB63E5A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

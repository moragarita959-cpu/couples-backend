import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';

class HomeGridMenu extends ConsumerWidget {
  const HomeGridMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryControllerProvider);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.38,
      children: [
        _FeatureCard(
          icon: Icons.chat_bubble_outline,
          title: '聊天',
          subtitle: '和 TA 说说话',
          onTap: () => context.push('/chat'),
        ),
        _FeatureCard(
          icon: Icons.receipt_long_outlined,
          title: '记账',
          subtitle:
              '周 ${summary.weekBillTotal.toStringAsFixed(0)} / 月 ${summary.monthBillTotal.toStringAsFixed(0)}',
          onTap: () => context.push('/bill'),
        ),
        _FeatureCard(
          icon: Icons.event_note_outlined,
          title: '倒计时',
          subtitle: summary.todayCountdownEvents.isEmpty
              ? '今天没有事件'
              : '今天 ${summary.todayCountdownEvents.length} 个事件',
          badgeText: summary.todayCountdownEvents.isEmpty
              ? null
              : '${summary.todayCountdownEvents.length}',
          onTap: () => context.push('/countdown'),
        ),
        _FeatureCard(
          icon: Icons.library_music_outlined,
          title: '歌单',
          subtitle: '收藏一起喜欢的歌',
          onTap: () => context.push('/playlist'),
        ),
        _FeatureCard(
          icon: Icons.checklist_rounded,
          title: '待办',
          subtitle: '今日完成 ${summary.todayTodoDoneCount} 项',
          badgeText: summary.todayTodoDoneCount == 0
              ? null
              : '${summary.todayTodoDoneCount}',
          onTap: () => context.push('/todo'),
        ),
        _FeatureCard(
          icon: Icons.calendar_view_week_outlined,
          title: '课表',
          subtitle: '一起看看这周安排',
          onTap: () => context.push('/schedule'),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFEFEFE),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x13000000)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            splashColor: const Color(0x1CE85A7A),
            highlightColor: const Color(0x0EE85A7A),
            onTap: widget.onTap,
            onHighlightChanged: (value) {
              setState(() {
                _pressed = value;
              });
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0x18E85A7A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: const Color(0xC4B64B69),
                          size: 17,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xE63E2A30),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0x843E2A30),
                          fontSize: 11.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.badgeText != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85A7A),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
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

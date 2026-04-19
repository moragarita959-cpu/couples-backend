import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../feed/domain/entities/feed_event.dart';

class HomeRecentFeedSection extends StatelessWidget {
  const HomeRecentFeedSection({
    super.key,
    required this.events,
  });

  final List<FeedEvent> events;

  String _timeText(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x19BA7A89)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dynamic_feed_rounded, size: 18, color: Color(0xFFB15E72)),
              const SizedBox(width: 6),
              const Text(
                '最近动态',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF573B44),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/feed'),
                child: const Text('查看全部'),
              ),
            ],
          ),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '今天还没有新的动态，去一起做点什么吧。',
                style: TextStyle(color: Color(0xFF8A6F79), fontSize: 12.5),
              ),
            )
          else
            ...events.take(2).map((item) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFFCC8396)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.summaryText,
                        style: const TextStyle(
                          color: Color(0xFF583D46),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _timeText(item.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF9E8591),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

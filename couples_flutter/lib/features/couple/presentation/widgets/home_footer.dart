import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';

class HomeFooter extends ConsumerStatefulWidget {
  const HomeFooter({super.key});

  @override
  ConsumerState<HomeFooter> createState() => _HomeFooterState();
}

class _HomeFooterState extends ConsumerState<HomeFooter> {
  static const List<String> _quotes = <String>[
    '\u4eca\u5929\u4e5f\u8981\u597d\u597d\u76f8\u7231\uff0c\u597d\u597d\u751f\u6d3b',
    '\u6709\u4f60\u5728\uff0c\u5e73\u51e1\u65e5\u5b50\u4e5f\u4f1a\u53d1\u5149',
    '\u6bcf\u4e00\u6b21\u8bb0\u5f55\uff0c\u90fd\u662f\u6211\u4eec\u5728\u4e00\u8d77\u7684\u8bc1\u636e',
    '\u5c0f\u5c0f\u7684\u4eca\u5929\uff0c\u7ec4\u6210\u4e86\u6211\u4eec\u7684\u5c06\u6765',
    '\u6162\u6162\u628a\u751f\u6d3b\u88c5\u8fdb\u6211\u4eec\u7684\u5c0f\u7a9d',
  ];

  late final String _fallbackQuote;

  @override
  void initState() {
    super.initState();
    _fallbackQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickAsync = ref.watch(dailySentencePickStreamProvider);
    final feedAsync = ref.watch(recentFeedEventsStreamProvider);

    final fromPick = pickAsync.maybeWhen(
      data: (row) {
        final text = row?.summaryText.trim() ?? '';
        return text.isNotEmpty ? text : null;
      },
      orElse: () => null,
    );
    final fromFeed = feedAsync.maybeWhen(
      data: (events) {
        if (events.isEmpty) {
          return null;
        }
        final t = events.first.summaryText.trim();
        return t.isNotEmpty ? t : null;
      },
      orElse: () => null,
    );

    final line = fromPick ?? fromFeed ?? _fallbackQuote;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Text(
        '\u4eca\u65e5\u4e00\u53e5\uff1a$line',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xB23E2A30),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

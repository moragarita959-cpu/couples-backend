import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/feed_event.dart';
import '../../domain/services/daily_sentence_library.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final Random _random = Random();
  String _selectedTag = DailySentenceLibrary.tags.first;
  DailySentence? _currentSentence;

  @override
  void initState() {
    super.initState();
    _pickSentence();
  }

  void _pickSentence() {
    final pool = DailySentenceLibrary.byTag(_selectedTag);
    if (pool.isEmpty) {
      _currentSentence = null;
      return;
    }
    _currentSentence = pool[_random.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvents = ref.watch(feedEventsStreamProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        title: const Text('动态'),
        backgroundColor: Colors.white,
      ),
      body: asyncEvents.when(
        data: (events) {
          final sections = _buildSections(events);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _DailySentenceCard(
                selectedTag: _selectedTag,
                sentence: _currentSentence,
                onRefresh: () {
                  setState(_pickSentence);
                },
                onTagSelected: (tag) {
                  setState(() {
                    _selectedTag = tag;
                    _pickSentence();
                  });
                },
              ),
              const SizedBox(height: 12),
              if (events.isEmpty)
                const _EmptyFeedCard()
              else
                ...sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.showHeader)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 2),
                            child: Text(
                              section.headerText,
                              style: const TextStyle(
                                color: Color(0xFF9A8793),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        _FeedEventTile(item: section.event),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('动态加载失败')),
      ),
    );
  }
}

class _DailySentenceCard extends StatelessWidget {
  const _DailySentenceCard({
    required this.selectedTag,
    required this.sentence,
    required this.onRefresh,
    required this.onTagSelected,
  });

  final String selectedTag;
  final DailySentence? sentence;
  final VoidCallback onRefresh;
  final ValueChanged<String> onTagSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE07B97)),
              const SizedBox(width: 8),
              Text(
                '今日一句',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '换一句',
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DailySentenceLibrary.tags.map((tag) {
              return ChoiceChip(
                label: Text(tag),
                selected: selectedTag == tag,
                onSelected: (_) => onTagSelected(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            sentence?.text ?? '这个标签下暂时还没有句子。',
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF453139),
            ),
          ),
          if (sentence != null) ...[
            const SizedBox(height: 10),
            Text(
              '标签：${sentence!.tags.join('、')}',
              style: const TextStyle(
                color: Color(0xFF8F7A83),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyFeedCard extends StatelessWidget {
  const _EmptyFeedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '还没有新的动态，等你们的共同记录慢慢填满这里。',
      ),
    );
  }
}

List<_FeedSectionItem> _buildSections(List<FeedEvent> events) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final tomorrowStart = todayStart.add(const Duration(days: 1));

  final result = <_FeedSectionItem>[];
  String? lastSection;

  for (final event in events) {
    final isToday =
        event.createdAt.isAfter(todayStart) && event.createdAt.isBefore(tomorrowStart);
    final currentSection = isToday ? '今天' : '更早之前';
    final showHeader = currentSection != lastSection;
    result.add(
      _FeedSectionItem(
        event: event,
        showHeader: showHeader,
        headerText: currentSection,
      ),
    );
    lastSection = currentSection;
  }
  return result;
}

class _FeedEventTile extends ConsumerWidget {
  const _FeedEventTile({required this.item});

  final FeedEvent item;

  IconData _iconOf(FeedTargetType targetType) {
    switch (targetType) {
      case FeedTargetType.todo:
        return Icons.checklist_rounded;
      case FeedTargetType.bill:
        return Icons.receipt_long_rounded;
      case FeedTargetType.countdown:
        return Icons.event_note_rounded;
      case FeedTargetType.song:
        return Icons.music_note_rounded;
      case FeedTargetType.course:
        return Icons.calendar_view_week_rounded;
    }
  }

  String _timeText(DateTime value) {
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final h = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$m-$d $h:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToSource(context, item.eventType),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E2EC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x16D9758B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconOf(item.targetType),
                  size: 18,
                  color: const Color(0xFFC35E79),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.summaryText,
                      style: const TextStyle(
                        color: Color(0xFF443445),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeText(item.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF8A7A8C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: '设为今日一句',
                    icon: const Icon(Icons.push_pin_outlined, size: 20, color: Color(0xFFB15E72)),
                    onPressed: () async {
                      await ref
                          .read(dailySentencePickLocalDataSourceProvider)
                          .saveFromFeedEvent(item);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已设为首页「今日一句」')),
                      );
                    },
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFFA58D97),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSource(BuildContext context, FeedEventType eventType) {
    final path = switch (eventType) {
      FeedEventType.todoCreated ||
      FeedEventType.todoCompleted ||
      FeedEventType.todoDeleted => '/todo',
      FeedEventType.billCreated ||
      FeedEventType.billUpdated ||
      FeedEventType.billDeleted => '/bill',
      FeedEventType.countdownCreated ||
      FeedEventType.countdownUpdated ||
      FeedEventType.countdownDeleted => '/countdown',
      FeedEventType.songAdded ||
      FeedEventType.songReviewAdded ||
      FeedEventType.songReviewUpdated => '/playlist',
      FeedEventType.courseCreated ||
      FeedEventType.courseUpdated ||
      FeedEventType.courseDeleted => '/schedule',
    };
    context.push(path);
  }
}

class _FeedSectionItem {
  const _FeedSectionItem({
    required this.event,
    required this.showHeader,
    required this.headerText,
  });

  final FeedEvent event;
  final bool showHeader;
  final String headerText;
}


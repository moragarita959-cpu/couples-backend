import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.song,
    required this.expanded,
    required this.preferenceLabel,
    required this.preferenceColor,
    required this.reviewCountLabel,
    required this.previewTags,
    required this.myReview,
    required this.partnerReview,
    required this.relationText,
    required this.totalScore,
    required this.scoreTierText,
    required this.scoreValues,
    required this.reviewController,
    required this.tagController,
    required this.onExpandToggle,
    required this.onLike,
    required this.onDislike,
    required this.onScoreChanged,
    required this.onSubmitReview,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSuggestionTap,
  });

  final Song song;
  final bool expanded;
  final String preferenceLabel;
  final Color preferenceColor;
  final String reviewCountLabel;
  final List<String> previewTags;
  final SongReview? myReview;
  final SongReview? partnerReview;
  final String relationText;
  final int totalScore;
  final String scoreTierText;
  final List<double> scoreValues;
  final TextEditingController reviewController;
  final TextEditingController tagController;
  final VoidCallback onExpandToggle;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final void Function(int index, double value) onScoreChanged;
  final Future<void> Function() onSubmitReview;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<String> onSuggestionTap;

  static const List<String> styleSuggestions = <String>[
    '流行',
    '独立',
    '摇滚',
    'R&B',
    '电子',
    '抒情',
    '梦幻',
    '温柔',
    '深夜',
    '公路感',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalReviews = (myReview != null ? 1 : 0) + (partnerReview != null ? 1 : 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: CoupleUi.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: expanded ? preferenceColor.withValues(alpha: 0.32) : CoupleUi.sectionBorder,
        ),
        boxShadow: CoupleUi.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      song.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF312B42),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C667C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _TinyTag(label: preferenceLabel, color: preferenceColor),
                  const SizedBox(height: 6),
                  _TinyTag(
                    label: reviewCountLabel,
                    color: totalReviews >= 2
                        ? const Color(0xFF6DA28E)
                        : const Color(0xFF8D87A6),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onLike,
                icon: const Icon(Icons.favorite_border, size: 18),
                label: const Text('喜欢'),
              ),
              OutlinedButton.icon(
                onPressed: onDislike,
                icon: const Icon(Icons.heart_broken_outlined, size: 18),
                label: const Text('跳过'),
              ),
              TextButton.icon(
                onPressed: onExpandToggle,
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(expanded ? '收起乐评' : '展开乐评'),
              ),
            ],
          ),
          if (previewTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: previewTags
                  .map(
                    (tag) => _TinyTag(
                      label: '#$tag',
                      color: const Color(0xFF977EA7),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (expanded) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: CoupleUi.nestedCardDecoration(
                color: const Color(0xFFF8F5FB),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '$totalScore / 15',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: preferenceColor,
                          ),
                        ),
                      ),
                      _TinyTag(label: scoreTierText, color: preferenceColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    relationText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF665F78),
                      height: 1.4,
                    ),
                  ),
                  if (myReview != null || partnerReview != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _ReviewNotes(
                      myReview: myReview,
                      partnerReview: partnerReview,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ScoreSlider(
                    label: '氛围感',
                    score: scoreValues[0],
                    color: const Color(0xFF7F97D8),
                    onChanged: (value) => onScoreChanged(0, value),
                  ),
                  const SizedBox(height: 10),
                  _ScoreSlider(
                    label: '共鸣感',
                    score: scoreValues[1],
                    color: const Color(0xFF7FB99C),
                    onChanged: (value) => onScoreChanged(1, value),
                  ),
                  const SizedBox(height: 10),
                  _ScoreSlider(
                    label: '想分享给 TA',
                    score: scoreValues[2],
                    color: const Color(0xFFD89B79),
                    onChanged: (value) => onScoreChanged(2, value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reviewController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: CoupleUi.inputDecoration(
                      labelText: '长评',
                      hintText: '写下你对这首歌的感受、回忆、歌词印象，或它让你想起的瞬间。',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagController,
                    onSubmitted: (_) => onAddTag(),
                    decoration: CoupleUi.inputDecoration(
                      labelText: '曲风标签',
                      hintText: '一次添加一个标签，然后点右侧加号',
                      suffixIcon: IconButton(
                        onPressed: onAddTag,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final suggestion in styleSuggestions)
                        ActionChip(
                          label: Text(suggestion),
                          onPressed: () => onSuggestionTap(suggestion),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                    ],
                  ),
                  if (previewTags.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: previewTags
                          .map(
                            (tag) => InputChip(
                              label: Text('#$tag'),
                              onDeleted: () => onRemoveTag(tag),
                              deleteIconColor: preferenceColor,
                              backgroundColor: preferenceColor.withValues(alpha: 0.12),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {
                        onSubmitReview();
                      },
                      style: CoupleUi.primaryButtonStyle(),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('保存我的乐评'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewNotes extends StatelessWidget {
  const _ReviewNotes({
    required this.myReview,
    required this.partnerReview,
  });

  final SongReview? myReview;
  final SongReview? partnerReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '乐评摘录',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF413B53),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _ReviewSnippetCard(
                title: '我',
                review: myReview,
                color: const Color(0xFFD98596),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ReviewSnippetCard(
                title: 'TA',
                review: partnerReview,
                color: const Color(0xFF7E8EA8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewSnippetCard extends StatelessWidget {
  const _ReviewSnippetCard({
    required this.title,
    required this.review,
    required this.color,
  });

  final String title;
  final SongReview? review;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review?.content ?? '还没有乐评',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              height: 1.4,
              color: Color(0xFF4A445B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.score,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final double score;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF464055),
                ),
              ),
            ),
            Text(
              '${score.round()}/5',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: score,
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

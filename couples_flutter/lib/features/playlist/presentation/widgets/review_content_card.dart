import 'package:flutter/material.dart';

import '../utils/song_review_score_theme.dart';

class ReviewContentCard extends StatelessWidget {
  const ReviewContentCard({
    super.key,
    required this.content,
    required this.theme,
  });

  final String content;
  final SongReviewScoreTheme theme;

  @override
  Widget build(BuildContext context) {
    final displayContent = content.trim().isEmpty ? '暂无内容' : content;
    final paragraphs = content.trim().isEmpty
        ? <String>[displayContent]
        : displayContent
            .split(RegExp(r'\n\s*\n'))
            .where((paragraph) => paragraph.trim().isNotEmpty)
            .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '完整歌评',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...paragraphs.asMap().entries.map((entry) {
            final isLast = entry.key == paragraphs.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: theme.textPrimary.withValues(alpha: 0.96),
                  fontSize: 17.2,
                  height: 1.72,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

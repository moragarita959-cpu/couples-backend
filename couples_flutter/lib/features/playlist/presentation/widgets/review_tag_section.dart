import 'package:flutter/material.dart';

import '../utils/song_review_score_theme.dart';

class ReviewTagSection extends StatelessWidget {
  const ReviewTagSection({
    super.key,
    required this.tags,
    required this.theme,
  });

  final List<String> tags;
  final SongReviewScoreTheme theme;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '标签',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: tags.map((tag) {
              final label = tag.startsWith('#') ? tag : '#$tag';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.chipBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.borderColor.withValues(alpha: 0.94),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

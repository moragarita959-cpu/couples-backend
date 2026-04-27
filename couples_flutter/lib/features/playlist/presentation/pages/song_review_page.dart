import 'package:flutter/material.dart';

import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/genre/genre_catalog.dart';
import '../utils/song_review_score_theme.dart';
import '../widgets/genre_mixed_text.dart';
import '../widgets/review_content_card.dart';
import '../widgets/review_tag_section.dart';
import '../widgets/song_review_hero_card.dart';

class SongReviewPage extends StatelessWidget {
  const SongReviewPage({
    super.key,
    required this.song,
    required this.review,
  });

  final Song song;
  final SongReview review;

  @override
  Widget build(BuildContext context) {
    final isMine = review.author == ReviewAuthor.me;
    final scoreTheme = SongReviewScoreThemeResolver.resolve(review.singleScore);
    final recommenderLabel = isMine ? '我推荐' : 'TA推荐';
    final resolvedGenre = GenreCatalog.resolve(song.genre);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('歌评详情'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scoreTheme.textPrimary,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              scoreTheme.pageBackgroundTop,
              scoreTheme.pageBackgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SongReviewHeroCard(
                  title: song.name,
                  artist: song.artist,
                  recommenderLabel: recommenderLabel,
                  resolvedGenre: resolvedGenre,
                  score: review.singleScore,
                  sharedText: '收藏于歌单 · 双人共享',
                  theme: scoreTheme,
                ),
                const SizedBox(height: 16),
                _MetadataCard(
                  recommenderLabel: recommenderLabel,
                  resolvedGenre: resolvedGenre,
                  scoreLabel: '评分 ${review.singleScore.toStringAsFixed(1)}',
                  theme: scoreTheme,
                ),
                if (review.styleTags.isNotEmpty) const SizedBox(height: 16),
                ReviewTagSection(
                  tags: review.styleTags,
                  theme: scoreTheme,
                ),
                const SizedBox(height: 16),
                ReviewContentCard(
                  content: review.content,
                  theme: scoreTheme,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({
    required this.recommenderLabel,
    required this.resolvedGenre,
    required this.scoreLabel,
    required this.theme,
  });

  final String recommenderLabel;
  final ResolvedGenre resolvedGenre;
  final String scoreLabel;
  final SongReviewScoreTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          _DetailChip(
            icon: Icons.person_outline_rounded,
            theme: theme,
            child: Text(
              recommenderLabel,
              style: TextStyle(
                color: theme.textAccentColor,
                fontSize: 13.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _DetailChip(
            icon: Icons.style_outlined,
            theme: theme,
            child: GenreMixedText(
              text: resolvedGenre.category.mixedLabel,
              chineseFontFamily: resolvedGenre.category.chineseFontFamily,
              englishFontFamily: resolvedGenre.category.englishFontFamily,
              style: TextStyle(
                color: theme.textAccentColor,
                fontSize: 13.1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (resolvedGenre.subTag != null)
            _DetailChip(
              icon: Icons.adjust_rounded,
              theme: theme,
              child: GenreMixedText(
                text: resolvedGenre.subTag!.name,
                chineseFontFamily: resolvedGenre.category.chineseFontFamily,
                englishFontFamily: resolvedGenre.category.englishFontFamily,
                style: TextStyle(
                  color: resolvedGenre.subTag!.color,
                  fontSize: 13.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _DetailChip(
            icon: Icons.stars_rounded,
            theme: theme,
            emphasized: true,
            child: Text(
              scoreLabel,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 13.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.child,
    required this.theme,
    this.emphasized = false,
  });

  final IconData icon;
  final Widget child;
  final SongReviewScoreTheme theme;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = emphasized ? theme.accentColor : theme.textAccentColor;
    final backgroundColor =
        emphasized ? theme.chipBackgroundColor : theme.chipBackgroundColor.withValues(alpha: 0.68);
    final borderColor =
        emphasized ? theme.accentColor.withValues(alpha: 0.28) : theme.borderColor.withValues(alpha: 0.92);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 7),
          child,
        ],
      ),
    );
  }
}

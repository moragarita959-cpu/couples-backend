import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/genre/genre_catalog.dart';
import 'genre_mixed_text.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.song,
    required this.combinedTotal,
    required this.uploadOrdinal,
    required this.onTap,
    this.greekBadgeIndex,
  });

  final Song song;
  final double combinedTotal;
  final int uploadOrdinal;
  final VoidCallback onTap;
  final int? greekBadgeIndex;

  static const double _watermarkSize = 64;
  static const double _watermarkRotation = -0.12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommenderColor = song.recommender == SongRecommender.me
        ? CoupleUi.primaryStrong
        : CoupleUi.partner;
    final recommenderLabel = song.recommender == SongRecommender.me ? '我推荐' : 'TA推荐';
    final scoreColor = CoupleUi.scoreColorCombined31(combinedTotal);
    final elite = combinedTotal >= 28;
    final greek = greekBadgeIndex != null
        ? CoupleUi.greekSymbolForIndex(greekBadgeIndex!)
        : null;
    final resolvedGenre = GenreCatalog.resolve(song.genre);

    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              if (elite)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.92),
                          CoupleUi.primary.withValues(alpha: 0.06),
                          CoupleUi.partner.withValues(alpha: 0.07),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -6,
                bottom: -14,
                child: Transform.rotate(
                  angle: _watermarkRotation,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        '$uploadOrdinal',
                        style: TextStyle(
                          fontSize: _watermarkSize,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.2
                            ..color = recommenderColor.withValues(alpha: 0.14),
                        ),
                      ),
                      Text(
                        '$uploadOrdinal',
                        style: TextStyle(
                          fontSize: _watermarkSize,
                          fontWeight: FontWeight.w900,
                          color: CoupleUi.textPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
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
                              color: CoupleUi.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: CoupleUi.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              _PrimaryGenreChip(category: resolvedGenre.category),
                              if (resolvedGenre.subTag != null)
                                _SecondaryGenreChip(
                                  subTag: resolvedGenre.subTag!,
                                  category: resolvedGenre.category,
                                ),
                              _TinyPill(label: recommenderLabel, color: recommenderColor),
                              if (greek != null)
                                _TinyPill(
                                  label: greek,
                                  color: CoupleUi.warmGold,
                                  glow: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        _TinyPill(
                          label: CoupleUi.combinedScoreLabel(combinedTotal),
                          color: scoreColor,
                          glow: elite,
                        ),
                        const SizedBox(height: 12),
                        const Icon(Icons.chevron_right, color: CoupleUi.textTertiary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: elite
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: CoupleUi.rainbowAccentGradient,
                transform: GradientRotation(math.pi / 6),
              ),
              boxShadow: CoupleUi.softShadow,
            )
          : CoupleUi.musicCardDecoration(
              expanded: false,
              accentColor: recommenderColor,
            ),
      child: elite
          ? Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: const <BoxShadow>[],
                ),
                child: inner,
              ),
            )
          : inner,
    );
  }
}

class _PrimaryGenreChip extends StatelessWidget {
  const _PrimaryGenreChip({required this.category});

  final GenreCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: category.gradient),
        borderRadius: BorderRadius.circular(999),
      ),
      child: GenreMixedText(
        text: category.mixedLabel,
        chineseFontFamily: category.chineseFontFamily,
        englishFontFamily: category.englishFontFamily,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SecondaryGenreChip extends StatelessWidget {
  const _SecondaryGenreChip({
    required this.subTag,
    required this.category,
  });

  final GenreSubTag subTag;
  final GenreCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: subTag.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: subTag.color.withValues(alpha: 0.34)),
      ),
      child: GenreMixedText(
        text: subTag.name,
        chineseFontFamily: category.chineseFontFamily,
        englishFontFamily: category.englishFontFamily,
        style: TextStyle(
          color: subTag.color,
          fontSize: 11.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label, required this.color, this.glow = false});

  final String label;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: glow ? 0.2 : 0.13),
        borderRadius: BorderRadius.circular(999),
        boxShadow: glow
            ? <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.26),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

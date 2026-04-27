import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/genre/genre_catalog.dart';
import '../utils/song_review_score_theme.dart';
import '../utils/song_title_art_style.dart';
import 'genre_mixed_text.dart';
import 'music_hero_painter.dart';

class SongReviewHeroCard extends StatelessWidget {
  const SongReviewHeroCard({
    super.key,
    required this.title,
    required this.artist,
    required this.recommenderLabel,
    required this.resolvedGenre,
    required this.score,
    required this.sharedText,
    required this.theme,
  });

  final String title;
  final String artist;
  final String recommenderLabel;
  final ResolvedGenre resolvedGenre;
  final double score;
  final String sharedText;
  final SongReviewScoreTheme theme;

  @override
  Widget build(BuildContext context) {
    final artStyleData = SongTitleArtStyleResolver.resolve(resolvedGenre.category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final heroHeight = math.max(272.0, math.min(316.0, width * 0.86));

        return Container(
          height: heroHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.09),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: theme.backgroundGradient,
                    border: Border.all(
                      color: theme.borderColor.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: MusicHeroPainter(
                      theme: theme,
                      artStyle: artStyleData.style,
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: _MiniBadge(
                    icon: Icons.library_music_outlined,
                    label: recommenderLabel,
                    color: theme.textSecondary,
                    backgroundColor: theme.cardColor.withValues(alpha: 0.52),
                    borderColor: theme.borderColor.withValues(alpha: 0.68),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: _MiniBadge(
                    icon: Icons.stars_rounded,
                    label: score.toStringAsFixed(1),
                    color: theme.textAccentColor,
                    backgroundColor: theme.cardColor.withValues(alpha: 0.56),
                    borderColor: theme.borderColor.withValues(alpha: 0.72),
                    emphasized: true,
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 72, 26, 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GenreMixedText(
                            text: resolvedGenre.category.mixedLabel,
                            chineseFontFamily: resolvedGenre.category.chineseFontFamily,
                            englishFontFamily: resolvedGenre.category.englishFontFamily,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 15.4,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _HeroTitle(
                              title: title,
                              maxWidth: width - 52,
                              theme: theme,
                              category: resolvedGenre.category,
                              artStyleData: artStyleData,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          artist,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textPrimary.withValues(alpha: 0.86),
                            fontSize: 19.5,
                            fontWeight: FontWeight.w600,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          sharedText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textSecondary.withValues(alpha: 0.82),
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle({
    required this.title,
    required this.maxWidth,
    required this.theme,
    required this.category,
    required this.artStyleData,
  });

  final String title;
  final double maxWidth;
  final SongReviewScoreTheme theme;
  final GenreCategory category;
  final SongTitleArtStyleData artStyleData;

  bool _isMostlyChinese(String text) {
    final chineseMatches = RegExp(r'[\u4E00-\u9FFF]').allMatches(text).length;
    final latinMatches = RegExp(r'[A-Za-z]').allMatches(text).length;
    return chineseMatches >= latinMatches;
  }

  double _titleFontSize(String title, bool isChinese) {
    final trimmed = title.trim();
    if (isChinese) {
      final length = RegExp(r'[\u4E00-\u9FFF]').allMatches(trimmed).length;
      if (length <= 3) {
        return 60 * artStyleData.chineseSizeMultiplier;
      }
      if (length <= 5) {
        return 52 * artStyleData.chineseSizeMultiplier;
      }
      return 42 * artStyleData.chineseSizeMultiplier;
    }

    final length = trimmed.length;
    if (length <= 6) {
      return 66 * artStyleData.englishSizeMultiplier;
    }
    if (length <= 12) {
      return 55 * artStyleData.englishSizeMultiplier;
    }
    return 44 * artStyleData.englishSizeMultiplier;
  }

  TextStyle _titleBaseStyle(bool isChinese, double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      height: artStyleData.lineHeight,
      fontWeight: artStyleData.fontWeight,
      letterSpacing: isChinese
          ? artStyleData.letterSpacing
          : (artStyleData.useSerifForEnglish ? 0.45 : 0.65),
      shadows: artStyleData.shadows
          .map(
            (shadow) => Shadow(
              color: shadow.color,
              blurRadius: shadow.blurRadius,
              offset: shadow.offset,
            ),
          )
          .toList(),
    );
  }

  Shader _titleShader(double fontSize) {
    final colors = <Color>[
      Color.lerp(artStyleData.gradientColors[0], theme.textAccentColor, 0.45) ??
          artStyleData.gradientColors[0],
      Color.lerp(artStyleData.gradientColors[1], theme.accentColor, 0.52) ??
          artStyleData.gradientColors[1],
      Color.lerp(artStyleData.gradientColors[2], theme.accentSoftColor, 0.36) ??
          artStyleData.gradientColors[2],
    ];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: const <double>[0.0, 0.56, 1.0],
    ).createShader(
      Rect.fromLTWH(0, 0, maxWidth, fontSize * 1.45),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedTitle = title.trim().isEmpty ? '未命名曲目' : title.trim();
    final isChinese = _isMostlyChinese(trimmedTitle);
    final fontSize = _titleFontSize(trimmedTitle, isChinese);
    final baseStyle = _titleBaseStyle(isChinese, fontSize).copyWith(
      foreground: Paint()..shader = _titleShader(fontSize),
    );

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: GenreMixedText.buildTextSpans(
          text: trimmedTitle,
          chineseFontFamily: category.chineseFontFamily,
          englishFontFamily: category.englishFontFamily,
          style: baseStyle,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: emphasized ? 10.5 : 10,
          vertical: emphasized ? 6.6 : 6.4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13.5, color: color),
            const SizedBox(width: 5.5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.9,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

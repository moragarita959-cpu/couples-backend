import 'package:flutter/material.dart';

import '../../domain/genre/genre_catalog.dart';

enum SongTitleArtStyle {
  chineseClassic,
  airyElegant,
  electronicModern,
  boldImpact,
  warmPoetic,
  retroJazz,
  premiumDefault,
}

class SongTitleArtStyleData {
  const SongTitleArtStyleData({
    required this.style,
    required this.fontWeight,
    required this.letterSpacing,
    required this.lineHeight,
    required this.gradientColors,
    required this.shadows,
    required this.useSerifForEnglish,
    required this.chineseSizeMultiplier,
    required this.englishSizeMultiplier,
  });

  final SongTitleArtStyle style;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double lineHeight;
  final List<Color> gradientColors;
  final List<BoxShadow> shadows;
  final bool useSerifForEnglish;
  final double chineseSizeMultiplier;
  final double englishSizeMultiplier;
}

class SongTitleArtStyleResolver {
  const SongTitleArtStyleResolver._();

  static SongTitleArtStyleData resolve(GenreCategory category) {
    switch (category.id) {
      case 'guofeng':
      case 'classical':
      case 'opera':
      case 'ost':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.chineseClassic,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8,
          lineHeight: 1.08,
          gradientColors: <Color>[
            Color(0xFF7C5A34),
            Color(0xFFB88C54),
            Color(0xFFCFA971),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x14FFFFFF),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: true,
          chineseSizeMultiplier: 1.02,
          englishSizeMultiplier: 1.0,
        );
      case 'lightmusic':
      case 'ambient':
      case 'newage':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.airyElegant,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          lineHeight: 1.1,
          gradientColors: <Color>[
            Color(0xFF55776E),
            Color(0xFF7EA89C),
            Color(0xFFDCE5DA),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x10FFFFFF),
              blurRadius: 7,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: true,
          chineseSizeMultiplier: 1.04,
          englishSizeMultiplier: 1.05,
        );
      case 'electronic':
      case 'experimental':
      case 'industrial':
      case 'kawaiifuture':
      case 'hyperpop':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.electronicModern,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          lineHeight: 1.04,
          gradientColors: <Color>[
            Color(0xFF39596B),
            Color(0xFF4E8794),
            Color(0xFFA9BBC4),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x0DFFFFFF),
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: false,
          chineseSizeMultiplier: 0.98,
          englishSizeMultiplier: 1.02,
        );
      case 'rock':
      case 'metal':
      case 'punk':
      case 'instrumentalrock':
      case 'mathprog':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.boldImpact,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          lineHeight: 1.02,
          gradientColors: <Color>[
            Color(0xFF3F4957),
            Color(0xFF5D6676),
            Color(0xFF8C7A73),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: false,
          chineseSizeMultiplier: 1.0,
          englishSizeMultiplier: 1.0,
        );
      case 'folk':
      case 'country':
      case 'lofi':
      case 'indie':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.warmPoetic,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.35,
          lineHeight: 1.1,
          gradientColors: <Color>[
            Color(0xFF7C6247),
            Color(0xFFA18867),
            Color(0xFFC8B090),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x10FFFFFF),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: true,
          chineseSizeMultiplier: 1.01,
          englishSizeMultiplier: 1.0,
        );
      case 'jazz':
      case 'blues':
      case 'funk':
      case 'rnb':
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.retroJazz,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
          lineHeight: 1.06,
          gradientColors: <Color>[
            Color(0xFF6A4C3B),
            Color(0xFF9A774E),
            Color(0xFF7C8A92),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: true,
          chineseSizeMultiplier: 1.0,
          englishSizeMultiplier: 1.04,
        );
      default:
        return const SongTitleArtStyleData(
          style: SongTitleArtStyle.premiumDefault,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          lineHeight: 1.08,
          gradientColors: <Color>[
            Color(0xFF5E6157),
            Color(0xFF8A866E),
            Color(0xFFB8B29C),
          ],
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x10FFFFFF),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
          useSerifForEnglish: true,
          chineseSizeMultiplier: 1.0,
          englishSizeMultiplier: 1.0,
        );
    }
  }
}

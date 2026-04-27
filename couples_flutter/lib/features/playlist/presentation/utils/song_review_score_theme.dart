import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';

class SongReviewScoreTheme {
  const SongReviewScoreTheme({
    required this.backgroundGradient,
    required this.accentColor,
    required this.accentSoftColor,
    required this.textAccentColor,
    required this.chipBackgroundColor,
    required this.borderColor,
    required this.pageBackgroundTop,
    required this.pageBackgroundBottom,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  final LinearGradient backgroundGradient;
  final Color accentColor;
  final Color accentSoftColor;
  final Color textAccentColor;
  final Color chipBackgroundColor;
  final Color borderColor;
  final Color pageBackgroundTop;
  final Color pageBackgroundBottom;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
}

class SongReviewScoreThemeResolver {
  const SongReviewScoreThemeResolver._();

  static SongReviewScoreTheme resolve(double score) {
    if (score < 0) {
      return const SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFE9EEF4),
            Color(0xFFDCE5EE),
            Color(0xFFD3DDE8),
          ],
        ),
        accentColor: Color(0xFF687A8E),
        accentSoftColor: Color(0xFFA4B0BE),
        textAccentColor: Color(0xFF475A6D),
        chipBackgroundColor: Color(0xFFF0F4F7),
        borderColor: Color(0xFFD0D9E3),
        pageBackgroundTop: Color(0xFFF5F8FB),
        pageBackgroundBottom: Color(0xFFEAF0F5),
        cardColor: Color(0xFFFAFCFD),
        textPrimary: Color(0xFF2D3742),
        textSecondary: Color(0xFF65717F),
      );
    }

    if (score < 4) {
      return SongReviewScoreTheme(
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFEFF4F8),
            Color(0xFFE5EDF4),
            Color(0xFFDCE7F0),
          ],
        ),
        accentColor: _blend(CoupleUi.scoreColorForSingle(score), const Color(0xFF73879A), 0.45),
        accentSoftColor: const Color(0xFFB7C5D3),
        textAccentColor: const Color(0xFF51687B),
        chipBackgroundColor: const Color(0xFFF2F6F9),
        borderColor: const Color(0xFFD7E0E8),
        pageBackgroundTop: const Color(0xFFF7FAFC),
        pageBackgroundBottom: const Color(0xFFECF2F7),
        cardColor: const Color(0xFFFCFDFE),
        textPrimary: const Color(0xFF2D3946),
        textSecondary: const Color(0xFF697786),
      );
    }

    if (score < 6) {
      return const SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFEDF4F8),
            Color(0xFFE3EEF5),
            Color(0xFFD9E7F1),
          ],
        ),
        accentColor: Color(0xFF6E8FAE),
        accentSoftColor: Color(0xFFA7C0D2),
        textAccentColor: Color(0xFF4A6784),
        chipBackgroundColor: Color(0xFFF0F6FA),
        borderColor: Color(0xFFD3E2EB),
        pageBackgroundTop: Color(0xFFF7FBFD),
        pageBackgroundBottom: Color(0xFFEBF4F8),
        cardColor: Color(0xFFFBFDFE),
        textPrimary: Color(0xFF2A3948),
        textSecondary: Color(0xFF637789),
      );
    }

    if (score < 7.5) {
      return const SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFEBF4F1),
            Color(0xFFE2EEE9),
            Color(0xFFD7E7E2),
          ],
        ),
        accentColor: Color(0xFF6D948A),
        accentSoftColor: Color(0xFFB9CEC5),
        textAccentColor: Color(0xFF4E6C66),
        chipBackgroundColor: Color(0xFFF0F6F3),
        borderColor: Color(0xFFD5E3DD),
        pageBackgroundTop: Color(0xFFF6FBF8),
        pageBackgroundBottom: Color(0xFFEBF4F0),
        cardColor: Color(0xFFFBFDFC),
        textPrimary: Color(0xFF2B3734),
        textSecondary: Color(0xFF647672),
      );
    }

    if (score < 8.5) {
      return const SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF7EFE2),
            Color(0xFFF2E6D4),
            Color(0xFFEADBC5),
          ],
        ),
        accentColor: Color(0xFFB58A53),
        accentSoftColor: Color(0xFFE2CFB2),
        textAccentColor: Color(0xFF7E6037),
        chipBackgroundColor: Color(0xFFFBF2E5),
        borderColor: Color(0xFFE6D7BF),
        pageBackgroundTop: Color(0xFFFCF7EF),
        pageBackgroundBottom: Color(0xFFF5EEDF),
        cardColor: Color(0xFFFFFBF5),
        textPrimary: Color(0xFF372E24),
        textSecondary: Color(0xFF796856),
      );
    }

    if (score < 10) {
      return const SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF5F1E2),
            Color(0xFFEEE8D7),
            Color(0xFFE2E8D7),
          ],
        ),
        accentColor: Color(0xFF8A8F56),
        accentSoftColor: Color(0xFFC5D1AB),
        textAccentColor: Color(0xFF65683D),
        chipBackgroundColor: Color(0xFFF6F3E7),
        borderColor: Color(0xFFDDE1CB),
        pageBackgroundTop: Color(0xFFFCF9F1),
        pageBackgroundBottom: Color(0xFFF3F1E7),
        cardColor: Color(0xFFFFFCF8),
        textPrimary: Color(0xFF343125),
        textSecondary: Color(0xFF706C57),
      );
    }

    if (score < 12) {
      return SongReviewScoreTheme(
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _blend(CoupleUi.warmGold, const Color(0xFFFFF4E0), 0.8),
            const Color(0xFFF3EAD8),
            _blend(CoupleUi.sage, const Color(0xFFE7F0E2), 0.78),
          ],
        ),
        accentColor: const Color(0xFFC1A06B),
        accentSoftColor: const Color(0xFFBCD0B0),
        textAccentColor: const Color(0xFF7B6B49),
        chipBackgroundColor: const Color(0xFFF8F2E8),
        borderColor: const Color(0xFFDDE3D2),
        pageBackgroundTop: const Color(0xFFFCF8F1),
        pageBackgroundBottom: const Color(0xFFF1F4EC),
        cardColor: const Color(0xFFFFFCF8),
        textPrimary: const Color(0xFF322E26),
        textSecondary: const Color(0xFF6B675B),
      );
    }

    return const SongReviewScoreTheme(
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF7EEDC),
          Color(0xFFF1E7D4),
          Color(0xFFF8F4E8),
        ],
      ),
      accentColor: Color(0xFFB88E56),
      accentSoftColor: Color(0xFFECE4CF),
      textAccentColor: Color(0xFF7D6137),
      chipBackgroundColor: Color(0xFFFBF5EA),
      borderColor: Color(0xFFE8DFCC),
      pageBackgroundTop: Color(0xFFFDF8F0),
      pageBackgroundBottom: Color(0xFFF6F1E6),
      cardColor: Color(0xFFFFFCF7),
      textPrimary: Color(0xFF322E28),
      textSecondary: Color(0xFF6F675B),
    );
  }

  static Color _blend(Color a, Color b, double amount) {
    return Color.lerp(a, b, amount) ?? a;
  }
}

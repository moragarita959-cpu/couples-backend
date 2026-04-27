import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';

abstract final class AlbumTheme {
  static const String zhBodyFont = 'NotoSansSC';
  static const String zhTitleFont = 'NotoSerifSC';
  static const String enNumberFont = 'SpaceGrotesk';

  static const Color pageWarm = Color(0xFFFFFBF8);
  static const Color mistPink = Color(0xFFF6E6EE);
  static const Color mistBlue = Color(0xFFE7EEF8);
  static const Color lavender = Color(0xFFEEE8F8);
  static const Color champagne = Color(0xFFD5B27A);
  static const Color cardBorder = Color(0xFFECE4EE);
  static const Color overlayStart = Color(0x11000000);
  static const Color overlayEnd = Color(0x660F0B14);
  static const double radiusLarge = 28;
  static const double radiusMedium = 22;
  static const double radiusSmall = 16;

  static const List<Color> pageGradient = <Color>[
    Color(0xFFFFFCFA),
    Color(0xFFF7F1F8),
    Color(0xFFF1F5FB),
  ];

  static BoxDecoration glassCardDecoration({
    List<Color>? colors,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors ?? <Color>[Colors.white, const Color(0xFFF9F1F6)],
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(radiusLarge),
      border: Border.all(color: cardBorder),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x11000000),
          blurRadius: 30,
          offset: Offset(0, 14),
        ),
      ],
    );
  }

  static BoxDecoration softSectionDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(color: cardBorder),
      boxShadow: CoupleUi.softShadow,
    );
  }

  static BoxDecoration photoOverlay() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.transparent, overlayStart, overlayEnd],
      ),
    );
  }

  static String formatDate(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}.$month.$day';
  }

  static String formatDateTime(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}.$month.$day $hour:$minute';
  }

  static String authorLabel({
    required String authorUserId,
    required String? currentUserId,
  }) {
    return currentUserId != null && authorUserId == currentUserId ? '我' : 'TA';
  }

  static TextStyle titleStyle({
    double size = 24,
    FontWeight weight = FontWeight.w800,
    Color color = CoupleUi.textPrimary,
    double? height,
  }) {
    return TextStyle(
      fontFamily: zhTitleFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle bodyStyle({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = CoupleUi.textSecondary,
    double? height,
  }) {
    return TextStyle(
      fontFamily: zhBodyFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle numberStyle({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color color = CoupleUi.textPrimary,
    double? height,
  }) {
    return TextStyle(
      fontFamily: enNumberFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}

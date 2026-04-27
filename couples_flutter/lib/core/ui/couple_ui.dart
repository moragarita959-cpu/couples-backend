import 'package:flutter/material.dart';

class CoupleUi {
  const CoupleUi._();

  static const Color pageBackground = Color(0xFFF9F5F8);
  static const Color pageBackgroundAccent = Color(0xFFF4EDF7);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF7F1F6);
  static const Color sectionBorder = Color(0xFFE8E0EC);
  static const Color primary = Color(0xFFE28EA0);
  static const Color primaryStrong = Color(0xFFD86F8F);
  static const Color partner = Color(0xFF6F91B8);
  static const Color meSoft = Color(0xFFF8E5EA);
  static const Color partnerSoft = Color(0xFFE7EEF7);
  static const Color sage = Color(0xFF7FA38E);
  static const Color mistBlue = Color(0xFF7898BF);
  static const Color warmGold = Color(0xFFC89A63);
  static const Color quietPurple = Color(0xFF8E83A6);
  static const Color textPrimary = Color(0xFF312B40);
  static const Color textSecondary = Color(0xFF6F6881);
  static const Color textTertiary = Color(0xFF978FA5);
  static const double pagePadding = 12;
  static const double sectionSpacing = 12;
  static const double cardRadius = 20;

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static BoxDecoration sectionCardDecoration({
    Color color = surface,
    Color borderColor = sectionBorder,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: borderColor),
      boxShadow: softShadow,
    );
  }

  static BoxDecoration nestedCardDecoration({
    Color color = surfaceMuted,
    Color borderColor = const Color(0xFFF0E7F2),
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    );
  }

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
      isDense: true,
      filled: true,
      fillColor: surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: sectionBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: sectionBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryStrong, width: 1.2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    );
  }

  static BoxDecoration pageBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFF4EEF8),
          pageBackground,
          Color(0xFFF7F1EF),
        ],
      ),
    );
  }

  static Color scoreColor(int totalScore) {
    if (totalScore <= 8) {
      return quietPurple;
    }
    if (totalScore <= 16) {
      return mistBlue;
    }
    if (totalScore <= 24) {
      return sage;
    }
    return warmGold;
  }

  /// Combined two-person sum in [-30, 30]; color maps **clamped** 0..30 → 31 discrete colors.
  static Color scoreColorCombined31(double combinedTotal) {
    final bucket = combinedTotal.clamp(0, 30).floor().clamp(0, 30);
    return _combinedScorePalette31[bucket];
  }

  /// Label for combined score (never capped at 15).
  static String combinedScoreLabel(double combinedTotal) {
    return combinedTotal.toStringAsFixed(1);
  }

  /// Multi-stop sweep-friendly palette: low → high across pink / rose / coral / gold / mint / blue.
  static const List<Color> _combinedScorePalette31 = <Color>[
    Color(0xFF9A8FB0),
    Color(0xFF9B92B4),
    Color(0xFF9C95B8),
    Color(0xFF9D98BC),
    Color(0xFF9E9BC0),
    Color(0xFFA08EC4),
    Color(0xFFA88ABF),
    Color(0xFFB086BA),
    Color(0xFFB882B5),
    Color(0xFFC07EAF),
    Color(0xFFC87AA9),
    Color(0xFFD076A3),
    Color(0xFFD8729D),
    Color(0xFFE06E97),
    Color(0xFFE86A91),
    Color(0xFFEC6B8A),
    Color(0xFFED7383),
    Color(0xFFEE7B7C),
    Color(0xFFEF8375),
    Color(0xFFF08B6E),
    Color(0xFFF19367),
    Color(0xFFF29B60),
    Color(0xFFE8A45F),
    Color(0xFFD9AD5E),
    Color(0xFFCAB65D),
    Color(0xFFBBBF5C),
    Color(0xFFACC85B),
    Color(0xFF9DC15A),
    Color(0xFF8EBAA9),
    Color(0xFF7FB3B8),
    Color(0xFF6FACC7),
  ];

  static const List<Color> rainbowAccentGradient = <Color>[
    Color(0xFFFF6B9D),
    Color(0xFFFFB347),
    Color(0xFFFFFD7A),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFCAB8FF),
    Color(0xFFFF6B9D),
  ];

  static Color scoreColorForSingle(double score) {
    if (score < 0) {
      return textTertiary;
    }
    final bucket = score.floor().clamp(0, 15);
    const positiveScale = <Color>[
      quietPurple,
      Color(0xFF8B86B8),
      Color(0xFF7F92C1),
      mistBlue,
      Color(0xFF6FA0B8),
      Color(0xFF6BA89F),
      sage,
      Color(0xFF8DA468),
      warmGold,
      Color(0xFFC08E5B),
      Color(0xFFC77967),
      Color(0xFFCA6B7C),
      primaryStrong,
      Color(0xFFB764A5),
      Color(0xFF8A6CCF),
      Color(0xFF6E8BFF),
    ];
    return positiveScale[bucket];
  }

  static String greekSymbolForIndex(int index) {
    const symbols = <String>[
      'α',
      'β',
      'γ',
      'δ',
      'ε',
      'ζ',
      'η',
      'θ',
      'ι',
      'κ',
      'λ',
      'μ',
      'ν',
      'ξ',
      'ο',
      'π',
    ];
    if (index < 0) {
      return symbols.first;
    }
    if (index < symbols.length) {
      return symbols[index];
    }
    return symbols[index % symbols.length];
  }

  static BoxDecoration musicCardDecoration({
    required bool expanded,
    required Color accentColor,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.white,
          accentColor.withValues(alpha: expanded ? 0.13 : 0.06),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: accentColor.withValues(alpha: expanded ? 0.32 : 0.14),
      ),
      boxShadow: softShadow,
    );
  }
}

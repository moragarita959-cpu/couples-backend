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
          pageBackgroundAccent,
          pageBackground,
        ],
      ),
    );
  }
}

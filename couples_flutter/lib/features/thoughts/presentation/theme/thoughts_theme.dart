import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/excerpt_note.dart';
import '../../domain/entities/idea_note.dart';

abstract final class ThoughtsTheme {
  static const String zhBodyFont = 'NotoSansSC';
  static const String zhTitleFont = 'NotoSerifSC';
  static const String enNumberFont = 'SpaceGrotesk';

  static const Color pageTop = Color(0xFFFFF9F4);
  static const Color pageMiddle = Color(0xFFFBEFEE);
  static const Color pageBottom = Color(0xFFF4F1F8);
  static const Color shell = Color(0xFFFFFEFC);
  static const Color paper = Color(0xFFFFFBF8);
  static const Color border = Color(0xFFECDDD6);
  static const Color ink = Color(0xFF3F3333);
  static const Color softInk = Color(0xFF7F6E6B);
  static const Color rose = Color(0xFFE8A4A8);
  static const Color blush = Color(0xFFF8DCDD);
  static const Color cream = Color(0xFFF7E9D1);
  static const Color mist = Color(0xFFDDE7F4);
  static const Color sage = Color(0xFFDDE8D8);
  static const Color lavender = Color(0xFFE6DDF1);
  static const Color sand = Color(0xFFF2E3D4);
  static const Color peach = Color(0xFFF8E0D5);
  static const Color chipFill = Color(0xFFF9F1EE);
  static const Color divider = Color(0xFFF0E5DE);
  static const Color shadow = Color(0x12000000);

  static const List<Color> pageGradient = <Color>[pageTop, pageMiddle, pageBottom];

  static TextStyle title({
    double size = 24,
    FontWeight weight = FontWeight.w800,
    Color color = ink,
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

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = softInk,
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

  static TextStyle number({
    double size = 13,
    FontWeight weight = FontWeight.w700,
    Color color = ink,
  }) {
    return TextStyle(
      fontFamily: enNumberFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static BoxDecoration pageDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: pageGradient,
      ),
    );
  }

  static BoxDecoration surfaceDecoration({
    Color color = shell,
    BorderRadius? radius,
    bool shadowEnabled = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: radius ?? BorderRadius.circular(28),
      border: Border.all(color: border),
      boxShadow: shadowEnabled
          ? const <BoxShadow>[
              BoxShadow(
                color: shadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ]
          : const <BoxShadow>[],
    );
  }

  static BoxDecoration chipDecoration({
    required bool selected,
    Color? tint,
  }) {
    return BoxDecoration(
      color: selected ? (tint ?? blush) : chipFill,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: selected ? rose.withValues(alpha: 0.42) : border,
      ),
      boxShadow: selected
          ? <BoxShadow>[
              BoxShadow(
                color: rose.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : const <BoxShadow>[],
    );
  }

  static BoxDecoration statusBannerDecoration({
    bool isError = false,
  }) {
    final tint = isError ? const Color(0xFFFFEEE8) : const Color(0xFFFFF5EC);
    return BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: border),
    );
  }

  static Color ideaColor(String? style) {
    switch (style) {
      case 'cream':
        return cream;
      case 'lavender':
        return lavender;
      case 'mist':
      case 'blue':
        return mist;
      case 'sage':
      case 'green':
        return sage;
      case 'peach':
        return peach;
      case 'pink':
      default:
        return blush;
    }
  }

  static Color excerptColor(String? style) {
    switch (style) {
      case 'cream':
        return cream;
      case 'mist':
        return mist;
      case 'sage':
        return sage;
      case 'amber':
        return sand;
      case 'rose':
        return peach;
      case 'lavender':
      default:
        return lavender;
    }
  }

  static Color tapeColor(String? style) {
    switch (style) {
      case 'cream':
      case 'amber':
        return const Color(0xFFD8C2A7);
      case 'lavender':
        return const Color(0xFFC5B6DA);
      case 'blue':
      case 'mist':
        return const Color(0xFFBFCFE4);
      case 'green':
      case 'sage':
        return const Color(0xFFC3D4BF);
      case 'rose':
      case 'pink':
      default:
        return const Color(0xFFDDB3B3);
    }
  }

  static Color accentForStyle(String? style) {
    switch (style) {
      case 'paper':
        return const Color(0xFFC7B08B);
      case 'magazine':
        return const Color(0xFF9AA7C1);
      case 'sticky':
        return rose;
      case 'floral':
        return const Color(0xFFB59AB5);
      case 'minimal':
      default:
        return const Color(0xFFCCB6A4);
    }
  }

  static String ideaTypeLabel(String type) {
    switch (type) {
      case IdeaNote.typeMood:
        return '心情';
      case IdeaNote.typeWish:
        return '愿景';
      case IdeaNote.typeIdea:
      default:
        return '想法';
    }
  }

  static String excerptCategoryLabel(String category) {
    switch (category) {
      case ExcerptNote.categoryBook:
        return '书籍';
      case ExcerptNote.categoryMovie:
        return '电影';
      case ExcerptNote.categoryLyric:
        return '歌词';
      case ExcerptNote.categoryCustom:
      default:
        return '随记';
    }
  }

  static String stickerLabel(String style) {
    switch (style) {
      case 'leaf':
        return '枝叶';
      case 'sparkle':
        return '星光';
      case 'music':
        return '音符';
      case 'tape':
        return '胶带';
      case 'flower':
        return '花卉';
      case 'heart':
      default:
        return '爱心';
    }
  }

  static IconData stickerIcon(String? style) {
    switch (style) {
      case 'leaf':
        return Icons.eco_rounded;
      case 'sparkle':
        return Icons.auto_awesome_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'tape':
        return Icons.bookmark_rounded;
      case 'flower':
        return Icons.local_florist_rounded;
      case 'heart':
      default:
        return Icons.favorite_rounded;
    }
  }

  static String layoutLabel(String style) {
    switch (style) {
      case 'pin':
        return '图钉';
      case 'paperclip':
        return '回形针';
      case 'spiral':
        return '螺旋';
      case 'tape':
      default:
        return '胶带';
    }
  }

  static String cardStyleLabel(String style) {
    switch (style) {
      case 'paper':
        return '纸感';
      case 'magazine':
        return '杂志';
      case 'sticky':
        return '便签';
      case 'floral':
        return '花草';
      case 'minimal':
      default:
        return '极简';
    }
  }

  static String ideaLayoutLabel(String style) {
    switch (style) {
      case 'paper':
        return '纸感';
      case 'grid':
        return '格纹';
      case 'photo':
        return '照片感';
      case 'floral':
        return '花边';
      case 'plain':
      default:
        return '纯净';
    }
  }

  static String authorLabel({
    required String authorUserId,
    required String? currentUserId,
  }) {
    return currentUserId != null && authorUserId == currentUserId ? '我' : 'TA';
  }

  static String formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$month-$day';
  }

  static String formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    bool alignLabelWithHint = false,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffix,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.66),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: body(size: 14, color: softInk.withValues(alpha: 0.84)),
      labelStyle: body(size: 13, weight: FontWeight.w700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: rose.withValues(alpha: 0.68), width: 1.2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: rose,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      elevation: 0,
      textStyle: body(size: 15, weight: FontWeight.w700, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  static List<BoxShadow> paperShadow(Color color) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: 0.18),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
      const BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ];
  }

  static BoxDecoration softPanelDecoration({
    EdgeInsetsGeometry? padding,
  }) {
    return CoupleUi.sectionCardDecoration(
      color: Colors.white.withValues(alpha: 0.88),
      borderColor: border,
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/song_review_score_theme.dart';
import '../utils/song_title_art_style.dart';

class MusicHeroPainter extends CustomPainter {
  const MusicHeroPainter({
    required this.theme,
    required this.artStyle,
  });

  final SongReviewScoreTheme theme;
  final SongTitleArtStyle artStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final mainLine = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.1)
      ..strokeWidth = artStyle == SongTitleArtStyle.boldImpact ? 1.45 : 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final softLine = Paint()
      ..color = theme.accentSoftColor.withValues(alpha: 0.13)
      ..strokeWidth = 0.95
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final faintLine = Paint()
      ..color = theme.borderColor.withValues(alpha: 0.2)
      ..strokeWidth = 0.82
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()
      ..color = theme.textAccentColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = theme.accentSoftColor.withValues(alpha: 0.028)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    switch (artStyle) {
      case SongTitleArtStyle.chineseClassic:
        _drawClassicCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.airyElegant:
        _drawAiryCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.electronicModern:
        _drawElectronicCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.boldImpact:
        _drawBoldCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.warmPoetic:
        _drawPoeticCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.retroJazz:
        _drawJazzCurves(canvas, size, mainLine, softLine, faintLine);
      case SongTitleArtStyle.premiumDefault:
        _drawAiryCurves(canvas, size, mainLine, softLine, faintLine);
    }

    final dots = switch (artStyle) {
      SongTitleArtStyle.electronicModern => <Offset>[
          Offset(size.width * 0.16, size.height * 0.18),
          Offset(size.width * 0.34, size.height * 0.67),
          Offset(size.width * 0.58, size.height * 0.2),
          Offset(size.width * 0.78, size.height * 0.34),
        ],
      SongTitleArtStyle.boldImpact => <Offset>[
          Offset(size.width * 0.18, size.height * 0.22),
          Offset(size.width * 0.61, size.height * 0.24),
          Offset(size.width * 0.83, size.height * 0.71),
        ],
      _ => <Offset>[
          Offset(size.width * 0.16, size.height * 0.2),
          Offset(size.width * 0.27, size.height * 0.7),
          Offset(size.width * 0.53, size.height * 0.16),
          Offset(size.width * 0.77, size.height * 0.27),
          Offset(size.width * 0.85, size.height * 0.7),
        ],
    };

    for (var i = 0; i < dots.length; i++) {
      final radius = i.isEven ? 2.6 : 2.1;
      canvas.drawCircle(dots[i], radius * 2.2, glowPaint);
      canvas.drawCircle(dots[i], radius, dotPaint);
    }
  }

  void _drawClassicCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final first = Path()
      ..moveTo(size.width * 0.04, size.height * 0.28)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.11,
        size.width * 0.4,
        size.height * 0.36,
        size.width * 0.61,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.11,
        size.width * 0.9,
        size.height * 0.26,
        size.width * 1.02,
        size.height * 0.2,
      );
    final second = Path()
      ..moveTo(size.width * 0.12, size.height * 0.73)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.61,
        size.width * 0.51,
        size.height * 0.86,
        size.width * 0.76,
        size.height * 0.7,
      );
    canvas.drawPath(first, mainLine);
    canvas.drawPath(second, softLine);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.68, size.height * 0.11, 82, 74),
      -0.3,
      1.0,
      false,
      faintLine,
    );
  }

  void _drawAiryCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final upper = Path()
      ..moveTo(-size.width * 0.08, size.height * 0.24)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.1,
        size.width * 0.3,
        size.height * 0.31,
        size.width * 0.53,
        size.height * 0.2,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.12,
        size.width * 0.88,
        size.height * 0.31,
        size.width * 1.04,
        size.height * 0.18,
      );
    final middle = Path()
      ..moveTo(-size.width * 0.04, size.height * 0.54)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.38,
        size.height * 0.68,
        size.width * 0.62,
        size.height * 0.57,
      )
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.49,
        size.width * 0.94,
        size.height * 0.65,
        size.width * 1.02,
        size.height * 0.55,
      );
    canvas.drawPath(upper, mainLine);
    canvas.drawPath(middle, softLine);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.14, 70, 62),
      -0.2,
      0.9,
      false,
      faintLine,
    );
  }

  void _drawElectronicCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.24)
      ..lineTo(size.width * 0.22, size.height * 0.24)
      ..lineTo(size.width * 0.29, size.height * 0.18)
      ..lineTo(size.width * 0.44, size.height * 0.18)
      ..lineTo(size.width * 0.52, size.height * 0.3)
      ..lineTo(size.width * 0.68, size.height * 0.3)
      ..lineTo(size.width * 0.77, size.height * 0.22)
      ..lineTo(size.width * 0.94, size.height * 0.22);
    final lower = Path()
      ..moveTo(size.width * 0.12, size.height * 0.74)
      ..lineTo(size.width * 0.28, size.height * 0.74)
      ..lineTo(size.width * 0.35, size.height * 0.68)
      ..lineTo(size.width * 0.5, size.height * 0.68)
      ..lineTo(size.width * 0.58, size.height * 0.8)
      ..lineTo(size.width * 0.78, size.height * 0.8);
    canvas.drawPath(path, mainLine);
    canvas.drawPath(lower, softLine);
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.14),
      Offset(size.width * 0.9, size.height * 0.4),
      faintLine,
    );
  }

  void _drawBoldCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final slash = Path()
      ..moveTo(size.width * 0.04, size.height * 0.26)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.18,
        size.width * 0.38,
        size.height * 0.31,
        size.width * 0.62,
        size.height * 0.2,
      )
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.13,
        size.width * 0.93,
        size.height * 0.22,
        size.width * 1.0,
        size.height * 0.18,
      );
    final lower = Path()
      ..moveTo(size.width * 0.16, size.height * 0.78)
      ..cubicTo(
        size.width * 0.31,
        size.height * 0.72,
        size.width * 0.48,
        size.height * 0.84,
        size.width * 0.64,
        size.height * 0.78,
      );
    canvas.drawPath(slash, mainLine);
    canvas.drawPath(lower, softLine);
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.17),
      Offset(size.width * 0.9, size.height * 0.4),
      faintLine,
    );
  }

  void _drawPoeticCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final upper = Path()
      ..moveTo(size.width * 0.03, size.height * 0.27)
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.12,
        size.width * 0.35,
        size.height * 0.32,
        size.width * 0.54,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.71,
        size.height * 0.14,
        size.width * 0.83,
        size.height * 0.25,
        size.width * 0.96,
        size.height * 0.2,
      );
    final lower = Path()
      ..moveTo(size.width * 0.11, size.height * 0.76)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.67,
        size.width * 0.45,
        size.height * 0.86,
        size.width * 0.66,
        size.height * 0.76,
      );
    canvas.drawPath(upper, mainLine);
    canvas.drawPath(lower, softLine);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.74, size.height * 0.17, 62, 54),
      -0.25,
      0.72,
      false,
      faintLine,
    );
  }

  void _drawJazzCurves(
    Canvas canvas,
    Size size,
    Paint mainLine,
    Paint softLine,
    Paint faintLine,
  ) {
    final top = Path()
      ..moveTo(size.width * 0.08, size.height * 0.24)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.12,
        size.width * 0.42,
        size.height * 0.14,
        size.width * 0.49,
        size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.45,
        size.width * 0.8,
        size.height * 0.41,
        size.width * 0.92,
        size.height * 0.2,
      );
    final lower = Path()
      ..moveTo(size.width * 0.18, size.height * 0.76)
      ..cubicTo(
        size.width * 0.33,
        size.height * 0.66,
        size.width * 0.44,
        size.height * 0.88,
        size.width * 0.64,
        size.height * 0.76,
      );
    canvas.drawPath(top, mainLine);
    canvas.drawPath(lower, softLine);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.14, 74, 72),
      -0.1,
      1.1,
      false,
      faintLine,
    );
  }

  @override
  bool shouldRepaint(covariant MusicHeroPainter oldDelegate) {
    return oldDelegate.theme.accentColor != theme.accentColor ||
        oldDelegate.theme.accentSoftColor != theme.accentSoftColor ||
        oldDelegate.theme.borderColor != theme.borderColor ||
        oldDelegate.theme.textAccentColor != theme.textAccentColor ||
        oldDelegate.artStyle != artStyle;
  }
}

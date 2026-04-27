import 'package:flutter/material.dart';

import '../../domain/entities/excerpt_note.dart';
import '../theme/thoughts_theme.dart';

class ExcerptQuoteCard extends StatelessWidget {
  const ExcerptQuoteCard({
    super.key,
    required this.note,
    required this.currentUserId,
    required this.onTap,
    this.large = false,
  });

  final ExcerptNote note;
  final String? currentUserId;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = ThoughtsTheme.excerptColor(note.colorStyle);
    final tape = ThoughtsTheme.tapeColor(note.colorStyle);
    final author = ThoughtsTheme.authorLabel(
      authorUserId: note.authorUserId,
      currentUserId: currentUserId,
    );
    final style = note.cardStyle ?? ExcerptNote.supportedCardStyles.first;
    final radius = large ? 30.0 : 26.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: ThoughtsTheme.border),
            boxShadow: ThoughtsTheme.paperShadow(color),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: CustomPaint(
                    painter: _QuoteCardPainter(style: style, color: color),
                  ),
                ),
              ),
              if (style != 'minimal')
                Positioned(
                  top: 12,
                  left: large ? 84 : 22,
                  child: _QuoteTape(color: tape),
                ),
              if (style == 'floral')
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Icon(
                    Icons.local_florist_rounded,
                    color: ThoughtsTheme.rose.withValues(alpha: 0.55),
                    size: large ? 36 : 26,
                  ),
                ),
              if (style == 'sticky')
                Positioned(
                  top: 0,
                  right: 0,
                  child: _DogEar(color: tape),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  large ? 26 : 20,
                  large ? 38 : 28,
                  large ? 26 : 20,
                  large ? 22 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _SmallPill(
                          text:
                              ThoughtsTheme.excerptCategoryLabel(note.category),
                        ),
                        const Spacer(),
                        if (!large)
                          _SmallPill(
                            text: ThoughtsTheme.cardStyleLabel(style),
                          ),
                      ],
                    ),
                    SizedBox(height: large ? 18 : 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '\u201C',
                          style: ThoughtsTheme.title(
                            size: large ? 56 : 38,
                            color: ThoughtsTheme.accentForStyle(style),
                            height: 0.85,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: large ? 10 : 6),
                            child: Text(
                              note.quoteText,
                              maxLines: large ? null : 4,
                              overflow:
                                  large ? null : TextOverflow.ellipsis,
                              style: ThoughtsTheme.title(
                                size: large ? 22 : 17,
                                height: large ? 1.85 : 1.7,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_sourceLine(note).isNotEmpty) ...<Widget>[
                      SizedBox(height: large ? 18 : 12),
                      Text(
                        _sourceLine(note),
                        style: ThoughtsTheme.body(
                          size: large ? 13 : 12,
                          color: ThoughtsTheme.ink.withValues(alpha: 0.74),
                        ),
                      ),
                    ],
                    if ((note.personalNote ?? '').isNotEmpty) ...<Widget>[
                      SizedBox(height: large ? 16 : 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.46),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          note.personalNote!,
                          maxLines: large ? null : 3,
                          overflow: large ? null : TextOverflow.ellipsis,
                          style: ThoughtsTheme.body(
                            size: large ? 13 : 12,
                            height: 1.65,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: large ? 18 : 12),
                    Row(
                      children: <Widget>[
                        Container(
                          width: large ? 28 : 22,
                          height: large ? 28 : 22,
                          decoration: BoxDecoration(
                            color: author == '我'
                                ? const Color(0xFFF0B9B0)
                                : const Color(0xFFD2D7BA),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            author,
                            style: ThoughtsTheme.body(
                              size: large ? 12 : 10,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ThoughtsTheme.formatDateTime(note.createdAt),
                            style: ThoughtsTheme.number(
                              size: large ? 12 : 10,
                              color: ThoughtsTheme.softInk,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mode_comment_outlined,
                          size: large ? 18 : 16,
                          color: ThoughtsTheme.softInk,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.commentCount}',
                          style: ThoughtsTheme.number(
                            size: large ? 12 : 10,
                            color: ThoughtsTheme.softInk,
                          ),
                        ),
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
  }

  String _sourceLine(ExcerptNote note) {
    final parts = <String>[
      if ((note.sourceTitle ?? '').isNotEmpty) '《${note.sourceTitle!}》',
      if ((note.sourceAuthor ?? '').isNotEmpty) note.sourceAuthor!,
      if ((note.sourceDetail ?? '').isNotEmpty) note.sourceDetail!,
    ];
    if (parts.isEmpty) {
      return '';
    }
    return '—— ${parts.join('  ')}';
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: ThoughtsTheme.body(
          size: 11,
          weight: FontWeight.w700,
          color: ThoughtsTheme.ink,
        ),
      ),
    );
  }
}

class _QuoteTape extends StatelessWidget {
  const _QuoteTape({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        width: 76,
        height: 14,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(4),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogEar extends StatelessWidget {
  const _DogEar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _DogEarClipper(),
      child: Container(
        width: 28,
        height: 28,
        color: color.withValues(alpha: 0.6),
      ),
    );
  }
}

class _DogEarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _QuoteCardPainter extends CustomPainter {
  const _QuoteCardPainter({required this.style, required this.color});

  final String style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = ThoughtsTheme.accentForStyle(style).withValues(alpha: 0.46);
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (style == 'paper') {
      // Subtle horizontal underline mimicking paper grain.
      canvas.drawLine(
        Offset(size.width * 0.12, size.height * 0.72),
        Offset(size.width * 0.88, size.height * 0.72),
        paint,
      );
    } else if (style == 'magazine') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
          const Radius.circular(24),
        ),
        paint,
      );
    } else if (style == 'sticky') {
      final dotPaint = Paint()..color = accent;
      for (var i = 0; i < 6; i++) {
        canvas.drawCircle(Offset(18 + (i * 12), 18), 2, dotPaint);
      }
    } else if (style == 'floral') {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width - 32, size.height - 38),
          radius: 26,
        ),
        2.4,
        1.4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuoteCardPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.color != color;
  }
}

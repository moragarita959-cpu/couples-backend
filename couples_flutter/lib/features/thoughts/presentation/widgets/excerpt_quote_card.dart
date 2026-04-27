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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: ThoughtsTheme.border),
            boxShadow: ThoughtsTheme.paperShadow(color),
          ),
          child: Stack(
            children: <Widget>[
              if (style != 'minimal')
                Positioned(top: 10, left: large ? 84 : 22, child: _QuoteTape(color: tape)),
              Positioned.fill(
                child: CustomPaint(painter: _QuoteCardPainter(style: style)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  large ? 26 : 20,
                  large ? 26 : 20,
                  large ? 26 : 20,
                  large ? 20 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _SmallPill(text: ThoughtsTheme.excerptCategoryLabel(note.category)),
                        const Spacer(),
                        if (!large) _SmallPill(text: ThoughtsTheme.cardStyleLabel(style)),
                      ],
                    ),
                    SizedBox(height: large ? 24 : 16),
                    Text(
                      '“',
                      style: ThoughtsTheme.title(
                        size: large ? 48 : 34,
                        color: ThoughtsTheme.accentForStyle(style),
                        height: 0.9,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Text(
                        note.quoteText,
                        maxLines: large ? null : 4,
                        overflow: large ? null : TextOverflow.ellipsis,
                        textAlign: large ? TextAlign.center : TextAlign.left,
                        style: ThoughtsTheme.title(
                          size: large ? 23 : 18,
                          height: large ? 1.8 : 1.65,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_sourceLine(note).isNotEmpty) ...<Widget>[
                      SizedBox(height: large ? 20 : 14),
                      Text(
                        _sourceLine(note),
                        style: ThoughtsTheme.body(
                          size: large ? 14 : 13,
                          color: ThoughtsTheme.ink.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                    if ((note.personalNote ?? '').isNotEmpty) ...<Widget>[
                      SizedBox(height: large ? 18 : 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Text(
                          note.personalNote!,
                          maxLines: large ? null : 3,
                          overflow: large ? null : TextOverflow.ellipsis,
                          style: ThoughtsTheme.body(
                            size: large ? 14 : 13,
                            height: 1.65,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: large ? 18 : 14),
                    Row(
                      children: <Widget>[
                        Text(
                          author,
                          style: ThoughtsTheme.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ThoughtsTheme.formatDateTime(note.createdAt),
                            style: ThoughtsTheme.number(
                              size: 10,
                              color: ThoughtsTheme.softInk,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.mode_comment_outlined,
                          size: 16,
                          color: ThoughtsTheme.softInk,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.commentCount}',
                          style: ThoughtsTheme.number(
                            size: 10,
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
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
        ),
      ),
    );
  }
}

class _QuoteCardPainter extends CustomPainter {
  const _QuoteCardPainter({required this.style});

  final String style;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = ThoughtsTheme.accentForStyle(style).withValues(alpha: 0.46);
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (style == 'paper') {
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
        Rect.fromCircle(center: Offset(size.width - 32, size.height - 38), radius: 26),
        2.4,
        1.4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuoteCardPainter oldDelegate) {
    return oldDelegate.style != style;
  }
}

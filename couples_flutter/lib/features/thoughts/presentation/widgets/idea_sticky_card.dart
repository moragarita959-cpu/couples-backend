import 'package:flutter/material.dart';

import '../../domain/entities/idea_note.dart';
import '../theme/thoughts_theme.dart';

class IdeaStickyCard extends StatelessWidget {
  const IdeaStickyCard({
    super.key,
    required this.note,
    required this.currentUserId,
    required this.onTap,
    this.expanded = false,
  });

  final IdeaNote note;
  final String? currentUserId;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final color = ThoughtsTheme.ideaColor(note.colorStyle);
    final tape = ThoughtsTheme.tapeColor(note.colorStyle);
    final author = ThoughtsTheme.authorLabel(
      authorUserId: note.authorUserId,
      currentUserId: currentUserId,
    );
    final accent = ThoughtsTheme.accentForStyle(note.layoutStyle);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(expanded ? 30 : 26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(expanded ? 30 : 26),
            border: Border.all(color: ThoughtsTheme.border),
            boxShadow: ThoughtsTheme.paperShadow(color),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(top: 10, left: 26, child: _Tape(color: tape)),
              Positioned.fill(child: CustomPaint(painter: _PaperEdgePainter())),
              Positioned(
                right: 18,
                top: expanded ? 24 : 18,
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: ThoughtsTheme.rose.withValues(alpha: 0.85),
                  size: expanded ? 28 : 22,
                ),
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: Icon(
                  note.layoutStyle == 'photo'
                      ? Icons.stars_rounded
                      : Icons.spa_outlined,
                  color: accent.withValues(alpha: 0.58),
                  size: expanded ? 34 : 26,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  expanded ? 28 : 18,
                  expanded ? 50 : 32,
                  expanded ? 28 : 18,
                  expanded ? 22 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if ((note.title ?? '').isNotEmpty) ...<Widget>[
                      Text(
                        note.title!,
                        style: ThoughtsTheme.title(
                          size: expanded ? 26 : 18,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: expanded ? 14 : 10),
                    ],
                    Text(
                      note.content,
                      maxLines: expanded ? null : 6,
                      overflow: expanded ? null : TextOverflow.fade,
                      style: ThoughtsTheme.body(
                        size: expanded ? 22 : 16,
                        height: expanded ? 1.8 : 1.7,
                        color: ThoughtsTheme.ink,
                      ),
                    ),
                    SizedBox(height: expanded ? 20 : 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetaPill(text: ThoughtsTheme.ideaTypeLabel(note.type)),
                        if ((note.moodTag ?? '').isNotEmpty)
                          _MetaPill(text: note.moodTag!),
                      ],
                    ),
                    if (expanded) const Spacer(),
                    SizedBox(height: expanded ? 26 : 16),
                    Row(
                      children: <Widget>[
                        Container(
                          width: expanded ? 30 : 24,
                          height: expanded ? 30 : 24,
                          decoration: BoxDecoration(
                            color: author == '我'
                                ? const Color(0xFFF0B9B0)
                                : const Color(0xFFD2D7BA),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              author,
                              style: ThoughtsTheme.body(
                                size: expanded ? 12 : 11,
                                weight: FontWeight.w700,
                                color: ThoughtsTheme.ink,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$author  ${ThoughtsTheme.formatDateTime(note.createdAt)}',
                            style: ThoughtsTheme.number(
                              size: expanded ? 12 : 10,
                              color: ThoughtsTheme.softInk,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mode_comment_outlined,
                          size: expanded ? 18 : 16,
                          color: ThoughtsTheme.softInk,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.commentCount}',
                          style: ThoughtsTheme.number(
                            size: expanded ? 12 : 10,
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
}

class _Tape extends StatelessWidget {
  const _Tape({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.04,
      child: Container(
        width: 62,
        height: 15,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
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

class _PaperEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(12, 10)
      ..quadraticBezierTo(size.width * 0.28, 2, size.width * 0.5, 8)
      ..quadraticBezierTo(size.width * 0.72, 14, size.width - 12, 10)
      ..moveTo(10, size.height - 16)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height - 4,
        size.width * 0.55,
        size.height - 14,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height - 22,
        size.width - 12,
        size.height - 10,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

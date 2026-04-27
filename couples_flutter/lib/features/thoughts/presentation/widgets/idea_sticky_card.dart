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
    final layout = note.layoutStyle ?? IdeaNote.supportedLayoutStyles.first;
    final radius = expanded ? 30.0 : 26.0;

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
                    painter: _IdeaPaperPainter(layout: layout),
                  ),
                ),
              ),
              ..._buildLayoutDecoration(layout: layout, tape: tape),
              if (note.stickerStyle != null && note.stickerStyle!.isNotEmpty)
                Positioned(
                  right: expanded ? 22 : 18,
                  bottom: expanded ? 22 : 18,
                  child: _StickerBadge(
                    icon: ThoughtsTheme.stickerIcon(note.stickerStyle),
                    expanded: expanded,
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  expanded ? 28 : 20,
                  _topPaddingForLayout(layout, expanded),
                  expanded ? 28 : 20,
                  expanded ? 22 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if ((note.title ?? '').isNotEmpty) ...<Widget>[
                      Text(
                        note.title!,
                        style: ThoughtsTheme.title(
                          size: expanded ? 24 : 17,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: expanded ? 12 : 8),
                    ],
                    Text(
                      note.content,
                      maxLines: expanded ? null : 6,
                      overflow: expanded ? null : TextOverflow.fade,
                      style: ThoughtsTheme.body(
                        size: expanded ? 18 : 15,
                        height: expanded ? 1.85 : 1.7,
                        color: ThoughtsTheme.ink,
                      ),
                    ),
                    SizedBox(height: expanded ? 18 : 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetaPill(
                          text: ThoughtsTheme.ideaTypeLabel(note.type),
                        ),
                        for (final tag in note.moodTags)
                          _MetaPill(text: tag, leadingHeart: true),
                      ],
                    ),
                    if (expanded) const Spacer(),
                    SizedBox(height: expanded ? 22 : 14),
                    Row(
                      children: <Widget>[
                        Container(
                          width: expanded ? 28 : 22,
                          height: expanded ? 28 : 22,
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
                                size: expanded ? 12 : 10,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ThoughtsTheme.formatDateTime(note.createdAt),
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

  double _topPaddingForLayout(String layout, bool expanded) {
    switch (layout) {
      case 'pin':
      case 'paperclip':
        return expanded ? 38 : 24;
      case 'spiral':
        return expanded ? 46 : 30;
      case 'tape':
      default:
        return expanded ? 42 : 28;
    }
  }

  List<Widget> _buildLayoutDecoration({
    required String layout,
    required Color tape,
  }) {
    switch (layout) {
      case 'pin':
        return <Widget>[
          Positioned(
            top: -6,
            right: 26,
            child: _PinDecoration(),
          ),
        ];
      case 'paperclip':
        return <Widget>[
          Positioned(
            top: -10,
            left: 22,
            child: _PaperclipDecoration(),
          ),
        ];
      case 'spiral':
        return <Widget>[
          Positioned(
            top: 6,
            left: 22,
            right: 22,
            child: _SpiralDecoration(),
          ),
        ];
      case 'tape':
      default:
        return <Widget>[
          Positioned(
            top: 8,
            left: 26,
            child: _TapeDecoration(color: tape),
          ),
        ];
    }
  }
}

class _TapeDecoration extends StatelessWidget {
  const _TapeDecoration({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        width: 70,
        height: 18,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
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

class _PinDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: <Color>[
                Color(0xFFEE6677),
                Color(0xFFB23A4A),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _PaperclipDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Icon(
        Icons.attach_file_rounded,
        size: 34,
        color: const Color(0xFFC9A95B),
        shadows: <Shadow>[
          Shadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _SpiralDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(8, (index) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: ThoughtsTheme.ink.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _StickerBadge extends StatelessWidget {
  const _StickerBadge({required this.icon, required this.expanded});

  final IconData icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? 38 : 30,
      height: expanded ? 38 : 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: expanded ? 22 : 18,
        color: ThoughtsTheme.rose,
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text, this.leadingHeart = false});

  final String text;
  final bool leadingHeart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leadingHeart) ...<Widget>[
            Icon(
              Icons.favorite_rounded,
              size: 11,
              color: ThoughtsTheme.rose.withValues(alpha: 0.86),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: ThoughtsTheme.body(
              size: 11,
              weight: FontWeight.w700,
              color: ThoughtsTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdeaPaperPainter extends CustomPainter {
  const _IdeaPaperPainter({required this.layout});

  final String layout;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = Colors.white.withValues(alpha: 0.18);
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path()
      ..moveTo(14, 14)
      ..quadraticBezierTo(size.width * 0.3, 4, size.width * 0.55, 12)
      ..quadraticBezierTo(size.width * 0.78, 18, size.width - 14, 14)
      ..moveTo(12, size.height - 18)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height - 6,
        size.width * 0.58,
        size.height - 16,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height - 24,
        size.width - 14,
        size.height - 12,
      );
    canvas.drawPath(path, paint);

    if (layout == 'paperclip') {
      final linePaint = Paint()
        ..color = ThoughtsTheme.ink.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      for (var y = size.height * 0.32; y < size.height - 24; y += 22) {
        canvas.drawLine(
          Offset(20, y),
          Offset(size.width - 20, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IdeaPaperPainter oldDelegate) =>
      oldDelegate.layout != layout;
}

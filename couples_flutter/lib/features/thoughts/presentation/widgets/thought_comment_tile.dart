import 'package:flutter/material.dart';

import '../../domain/entities/thought_comment.dart';
import '../theme/thoughts_theme.dart';

class ThoughtCommentTile extends StatelessWidget {
  const ThoughtCommentTile({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  final ThoughtComment comment;
  final String? currentUserId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isMine = comment.authoredBy(currentUserId);
    final bubbleColor = isMine
        ? const Color(0xFFFCE8E5)
        : const Color(0xFFF8F4EF);
    final chipColor = isMine
        ? const Color(0xFFEFB0AE)
        : const Color(0xFFD6D1B2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThoughtsTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isMine ? '我' : 'TA',
                style: ThoughtsTheme.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: ThoughtsTheme.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      isMine ? '我' : 'TA',
                      style: ThoughtsTheme.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: ThoughtsTheme.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ThoughtsTheme.formatDateTime(comment.createdAt),
                      style: ThoughtsTheme.number(
                        size: 10,
                        color: ThoughtsTheme.softInk,
                      ),
                    ),
                    const Spacer(),
                    if (isMine)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: ThoughtsTheme.softInk,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 17,
                        color: ThoughtsTheme.softInk,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.content,
                  style: ThoughtsTheme.body(
                    size: 14,
                    height: 1.65,
                    color: ThoughtsTheme.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

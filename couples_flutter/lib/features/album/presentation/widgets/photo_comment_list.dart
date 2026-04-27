import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/photo_comment.dart';
import 'album_theme.dart';

class PhotoCommentList extends StatelessWidget {
  const PhotoCommentList({
    super.key,
    required this.comments,
    required this.currentUserId,
    required this.onDeleteComment,
  });

  final List<PhotoComment> comments;
  final String? currentUserId;
  final ValueChanged<String> onDeleteComment;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: AlbumTheme.softSectionDecoration(),
        child: const Column(
          children: <Widget>[
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: CoupleUi.textTertiary,
              size: 26,
            ),
            SizedBox(height: 10),
            Text(
              '还没有评论',
              style: TextStyle(
                fontFamily: AlbumTheme.zhTitleFont,
                color: CoupleUi.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '把这一刻的心情也留在这里，让照片变成完整的回忆。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AlbumTheme.zhBodyFont,
                color: CoupleUi.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: comments.map((comment) {
        final isMine = comment.authoredBy(currentUserId);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0E8E8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMine ? CoupleUi.meSoft : CoupleUi.partnerSoft,
                ),
                child: Center(
                  child: Text(
                    isMine ? '我' : 'TA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: CoupleUi.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontFamily: AlbumTheme.zhBodyFont,
                        color: CoupleUi.textPrimary,
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AlbumTheme.formatDateTime(comment.createdAt),
                      style: TextStyle(
                        fontFamily: AlbumTheme.enNumberFont,
                        color: CoupleUi.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isMine ? () => onDeleteComment(comment.id) : null,
                icon: Icon(
                  isMine
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isMine ? CoupleUi.primary : CoupleUi.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

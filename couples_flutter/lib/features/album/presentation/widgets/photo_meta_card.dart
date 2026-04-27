import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/album_photo.dart';
import 'album_theme.dart';

class PhotoMetaCard extends StatelessWidget {
  const PhotoMetaCard({
    super.key,
    required this.photo,
    required this.currentUserId,
  });

  final AlbumPhoto photo;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final uploaderLabel = AlbumTheme.authorLabel(
      authorUserId: photo.uploaderUserId,
      currentUserId: currentUserId,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AlbumTheme.softSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '这一刻',
            style: TextStyle(
              fontFamily: AlbumTheme.zhTitleFont,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: CoupleUi.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ChipLabel(
                icon: Icons.person_outline,
                label: '上传人 $uploaderLabel',
              ),
              _ChipLabel(
                icon: Icons.schedule_outlined,
                label: AlbumTheme.formatDateTime(photo.createdAt),
                allowWrap: true,
              ),
              if (photo.albumTitle != null && photo.albumTitle!.isNotEmpty)
                _ChipLabel(
                  icon: Icons.photo_album_outlined,
                  label: photo.albumTitle!,
                ),
              _ChipLabel(
                icon: Icons.mode_comment_outlined,
                label: '${photo.commentCount} 条评论',
              ),
            ],
          ),
          if (photo.caption.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              photo.caption.trim(),
              style: TextStyle(
                fontFamily: AlbumTheme.zhBodyFont,
                height: 1.5,
                fontSize: 14,
                color: CoupleUi.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({
    required this.icon,
    required this.label,
    this.allowWrap = false,
  });

  final IconData icon;
  final String label;
  final bool allowWrap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CoupleUi.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AlbumTheme.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: allowWrap ? 220 : 320),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: CoupleUi.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: allowWrap ? 2 : 1,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  fontFamily: AlbumTheme.enNumberFont,
                  color: CoupleUi.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

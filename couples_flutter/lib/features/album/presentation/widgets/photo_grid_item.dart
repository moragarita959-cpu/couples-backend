import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/album_photo.dart';
import 'album_image_view.dart';
import 'album_theme.dart';

class PhotoGridItem extends StatelessWidget {
  const PhotoGridItem({
    super.key,
    required this.photo,
    required this.currentUserId,
    required this.onTap,
  });

  final AlbumPhoto photo;
  final String? currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMine = photo.uploadedBy(currentUserId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AlbumTheme.radiusMedium),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AlbumTheme.radiusMedium),
            boxShadow: CoupleUi.softShadow,
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AlbumImageView(
                  localPath: photo.localPath,
                  imageUrl: photo.imageUrl,
                  borderRadius: BorderRadius.circular(AlbumTheme.radiusMedium),
                  placeholderLabel: '照片',
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AlbumTheme.radiusMedium),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Color(0x11000000),
                        Color(0x590D0C14),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isMine
                        ? CoupleUi.meSoft.withValues(alpha: 0.9)
                        : CoupleUi.partnerSoft.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isMine ? '我' : 'TA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: CoupleUi.textPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${photo.commentCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

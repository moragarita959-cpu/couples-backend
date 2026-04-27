import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/album.dart';
import 'album_image_view.dart';
import 'album_theme.dart';

class AlbumGridCard extends StatelessWidget {
  const AlbumGridCard({
    super.key,
    required this.album,
    required this.currentUserId,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Album album;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1E8E8)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: AlbumImageView(
                        localPath: album.coverLocalPath,
                        imageUrl: album.coverPhotoUrl,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        placeholderLabel: '回忆封面',
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: AlbumTheme.photoOverlay(),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 4,
                      child: PopupMenuButton<String>(
                        onSelected: (value) =>
                            value == 'edit' ? onEdit() : onDelete(),
                        itemBuilder: (context) =>
                            const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('编辑相册'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('删除相册'),
                              ),
                            ],
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AlbumTheme.titleStyle(
                        color: CoupleUi.textPrimary,
                        weight: FontWeight.w900,
                        size: 34 / 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${album.photoCount} 张 · ${AlbumTheme.formatDateTime(album.lastPhotoAt ?? album.updatedAt)}',
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      style: AlbumTheme.numberStyle(
                        color: CoupleUi.textTertiary,
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: album.createdBy(currentUserId)
                                ? CoupleUi.meSoft
                                : CoupleUi.partnerSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            album.createdBy(currentUserId) ? '我创建' : 'TA 创建',
                            style: AlbumTheme.bodyStyle(
                              color: CoupleUi.textPrimary,
                              weight: FontWeight.w700,
                              size: 11,
                            ),
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

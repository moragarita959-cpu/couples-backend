import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import 'album_theme.dart';

class AlbumStatsCard extends StatelessWidget {
  const AlbumStatsCard({
    super.key,
    required this.totalAlbums,
    required this.totalPhotos,
    required this.lastUpdatedText,
  });

  final int totalAlbums;
  final int totalPhotos;
  final String lastUpdatedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AlbumTheme.softSectionDecoration(),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatItem(label: '相册数', value: '$totalAlbums'),
          ),
          Expanded(
            child: _StatItem(label: '照片数', value: '$totalPhotos'),
          ),
          Expanded(
            child: _StatItem(
              label: '最近更新',
              value: lastUpdatedText,
              allowWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.allowWrap = false,
  });

  final String label;
  final String value;
  final bool allowWrap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AlbumTheme.bodyStyle(
            color: CoupleUi.textTertiary,
            weight: FontWeight.w700,
            size: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: allowWrap ? 2 : 1,
          softWrap: allowWrap,
          overflow: allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
          style: AlbumTheme.numberStyle(
            color: CoupleUi.textPrimary,
            weight: FontWeight.w900,
            size: 18,
          ),
        ),
      ],
    );
  }
}

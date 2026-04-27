import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import 'album_theme.dart';

class AlbumHeader extends StatelessWidget {
  const AlbumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: AlbumTheme.glassCardDecoration(
        colors: const <Color>[
          Color(0xFFFFFCFB),
          Color(0xFFF9EFF4),
          Color(0xFFF1F4FC),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: CoupleUi.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    height: 1.45,
                    fontSize: 13.5,
                    color: CoupleUi.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onActionTap,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: CoupleUi.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

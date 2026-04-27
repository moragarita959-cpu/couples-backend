import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import 'album_theme.dart';

/// 解析相册/后端返回的 [imageUrl]（含相对 `/media/album/...` + dart-define 的 baseUrl）。
String? albumResolvedNetworkImageUrl(String? imageUrl) {
  final raw = imageUrl?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }
  if (raw.startsWith('/media/album')) {
    const base = String.fromEnvironment('COUPLES_API_BASE_URL', defaultValue: '');
    final b = base.trim();
    if (b.isNotEmpty) {
      return '${b.replaceAll(RegExp(r'/+$'), '')}$raw';
    }
    return null;
  }
  return raw;
}

class AlbumImageView extends StatelessWidget {
  const AlbumImageView({
    super.key,
    this.localPath,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.photo_camera_back_outlined,
    this.placeholderLabel,
  });

  final String? localPath;
  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final String? placeholderLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AlbumTheme.radiusMedium);
    final networkUrl = albumResolvedNetworkImageUrl(imageUrl);

    Widget child;
    if (networkUrl != null) {
      child = Image.network(
        networkUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallbackLocalOrPlaceholder(),
      );
    } else {
      child = _fallbackLocalOrPlaceholder();
    }

    return ClipRRect(
      borderRadius: radius,
      child: child,
    );
  }

  Widget _fallbackLocalOrPlaceholder() {
    final file = _resolveLocalFile();
    if (file != null) {
      return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  File? _resolveLocalFile() {
    final raw = localPath?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final file = File(raw);
    if (!file.existsSync()) {
      return null;
    }
    return file;
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AlbumTheme.mistPink,
            AlbumTheme.lavender,
            AlbumTheme.mistBlue,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              placeholderIcon,
              color: CoupleUi.textSecondary.withValues(alpha: 0.8),
              size: 28,
            ),
            if (placeholderLabel != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                placeholderLabel!,
                style: const TextStyle(
                  color: CoupleUi.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

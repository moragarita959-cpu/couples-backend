import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../state/album_detail_state.dart';
import '../widgets/album_image_view.dart';
import '../widgets/album_theme.dart';
import '../widgets/photo_grid_item.dart';

class AlbumDetailPage extends ConsumerStatefulWidget {
  const AlbumDetailPage({super.key, required this.albumId});

  final String albumId;

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickPhotos() async {
    final controller = ref.read(
      albumDetailControllerProvider(widget.albumId).notifier,
    );
    final images = await _imagePicker.pickMultiImage(imageQuality: 92);
    if (images.isEmpty) {
      return;
    }
    final success = await controller.addPhotos(
      images.map((item) => item.path).toList(),
    );
    if (!mounted) {
      return;
    }
    if (!success) {
      final message =
          ref
              .read(albumDetailControllerProvider(widget.albumId))
              .errorMessage ??
          '添加照片失败';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDeleteAlbum() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除相册'),
          content: const Text('删除后，这个相册里的照片和评论都会一起移除。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final ok = await ref
        .read(albumDetailControllerProvider(widget.albumId).notifier)
        .deleteAlbum();
    if (mounted && ok) {
      context.pop();
      return;
    }
    if (mounted && !ok) {
      final vm = ref.read(albumDetailControllerProvider(widget.albumId));
      final message = vm.cloudSyncMessage ?? vm.errorMessage ?? '删除相册失败';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDeletePhoto(String photoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除照片'),
          content: const Text('这张照片会从当前相册中移除，评论也会一起删除。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    final ok = await ref
        .read(albumDetailControllerProvider(widget.albumId).notifier)
        .deletePhoto(photoId);
    if (!mounted || ok) {
      return;
    }
    final vm = ref.read(albumDetailControllerProvider(widget.albumId));
    final message = vm.cloudSyncMessage ?? vm.errorMessage ?? '删除照片失败';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumDetailControllerProvider(widget.albumId));
    final currentUserId = ref.watch(authControllerProvider).user?.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F6),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const _AlbumDetailBackground(),
            state.isLoading && state.album == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(
                            albumDetailControllerProvider(
                              widget.albumId,
                            ).notifier,
                          )
                          .refreshPhotos();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) =>
                                Opacity(opacity: value, child: child),
                            child: _AlbumHero(
                              state: state,
                              currentUserId: currentUserId,
                              onBack: () => context.pop(),
                              onAddPhoto: _pickPhotos,
                              onDeleteAlbum: _confirmDeleteAlbum,
                            ),
                          ),
                        ),
                        if (state.cloudSyncMessage != null &&
                            state.cloudSyncMessage!.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Text(
                                state.cloudSyncMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB8860B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (state.photos.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _AlbumEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.88,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final photo = state.photos[index];
                                final canDelete = photo.uploadedBy(
                                  currentUserId,
                                );
                                return TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 260 + index * 35,
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    final dy = (1 - value) * 20;
                                    return Transform.translate(
                                      offset: Offset(0, dy),
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: GestureDetector(
                                    onLongPress: canDelete
                                        ? () => _confirmDeletePhoto(photo.id)
                                        : null,
                                    child: PhotoGridItem(
                                      photo: photo,
                                      currentUserId: currentUserId,
                                      onTap: () => context.push(
                                        '/album/photo/${photo.id}',
                                      ),
                                    ),
                                  ),
                                );
                              }, childCount: state.photos.length),
                            ),
                          ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AlbumDetailBackground extends StatelessWidget {
  const _AlbumDetailBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AlbumTheme.pageGradient,
              ),
            ),
          ),
        ),
        Positioned(
          top: 120,
          right: -38,
          child: _glow(const Color(0x3CE3D0FF), 144),
        ),
        Positioned(
          top: 360,
          left: -48,
          child: _glow(const Color(0x30F5C9D2), 160),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _AlbumHero extends StatelessWidget {
  const _AlbumHero({
    required this.state,
    required this.currentUserId,
    required this.onBack,
    required this.onAddPhoto,
    required this.onDeleteAlbum,
  });

  final AlbumDetailState state;
  final String? currentUserId;
  final VoidCallback onBack;
  final VoidCallback onAddPhoto;
  final VoidCallback onDeleteAlbum;

  @override
  Widget build(BuildContext context) {
    final album = state.album;
    return SizedBox(
      height: 380,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AlbumImageView(
              localPath: album?.coverLocalPath,
              imageUrl: album?.coverPhotoUrl,
              borderRadius: BorderRadius.zero,
              placeholderLabel: '回忆正在等待',
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x15000000),
                    Color(0x33000000),
                    Color(0x95090A12),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Row(
              children: <Widget>[
                _circleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                const Spacer(),
                _circleIconButton(
                  icon: Icons.more_horiz_rounded,
                  onTap: onDeleteAlbum,
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  album?.title ?? '相册详情',
                  style: AlbumTheme.titleStyle(
                    size: 46,
                    height: 1,
                    color: Colors.white,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  album?.description.isNotEmpty == true
                      ? album!.description
                      : '一起出发的每个瞬间都值得收藏',
                  style: AlbumTheme.bodyStyle(
                    color: Color(0xF0FFFFFF),
                    size: 20,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: <Widget>[
                    _meta(
                      icon: Icons.photo_outlined,
                      text: '${state.photos.length} 张照片',
                    ),
                    _meta(
                      icon: Icons.person_outline,
                      text: album?.createdBy(currentUserId) == true
                          ? '我创建'
                          : 'TA 创建',
                    ),
                    _meta(
                      icon: Icons.history,
                      text: '更新 ${AlbumTheme.formatDateTime(album?.updatedAt)}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 220,
                  child: FilledButton.icon(
                    onPressed: onAddPhoto,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE798A6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text(
                      '添加照片',
                      style: TextStyle(
                        fontFamily: AlbumTheme.zhBodyFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: CoupleUi.textPrimary),
        ),
      ),
    );
  }

  Widget _meta({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: const Color(0xE6FFFFFF)),
        const SizedBox(width: 4),
        Text(
          text,
          style: AlbumTheme.numberStyle(
            color: Color(0xE6FFFFFF),
            weight: FontWeight.w600,
            size: 14,
          ),
        ),
      ],
    );
  }
}

class _AlbumEmptyState extends StatelessWidget {
  const _AlbumEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AlbumTheme.softSectionDecoration(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.photo_library_outlined,
                size: 34,
                color: CoupleUi.textTertiary,
              ),
              SizedBox(height: 12),
              Text(
                '这个相册还空着',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CoupleUi.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '快添加第一张照片吧，让这段回忆开始有画面。',
                textAlign: TextAlign.center,
                style: TextStyle(color: CoupleUi.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

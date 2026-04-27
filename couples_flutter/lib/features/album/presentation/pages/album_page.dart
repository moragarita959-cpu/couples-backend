import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../widgets/album_grid_card.dart';
import '../widgets/album_stats_card.dart';
import '../widgets/album_theme.dart';

class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key});

  Future<void> _showAlbumEditor(
    BuildContext context,
    WidgetRef ref, {
    String? albumId,
    String? initialTitle,
    String? initialDescription,
  }) async {
    final titleController = TextEditingController(text: initialTitle ?? '');
    final descriptionController = TextEditingController(
      text: initialDescription ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AlbumTheme.glassCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  albumId == null ? '新建相册' : '编辑相册',
                  style: AlbumTheme.titleStyle(
                    size: 20,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  decoration: CoupleUi.inputDecoration(labelText: '相册名称'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: CoupleUi.inputDecoration(
                    labelText: '相册描述',
                    hintText: '比如：旅行、约会、日常、纪念日...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final success = await ref
                              .read(albumControllerProvider.notifier)
                              .saveAlbum(
                                albumId: albumId,
                                title: titleController.text,
                                description: descriptionController.text,
                              );
                          if (!context.mounted) {
                            return;
                          }
                          if (success) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(albumId == null ? '创建' : '保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAlbum(
    BuildContext context,
    WidgetRef ref,
    String albumId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除相册'),
          content: const Text('删除后，里面的照片和评论也会一起删除。'),
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
    if (confirmed == true) {
      final ok = await ref
          .read(albumControllerProvider.notifier)
          .deleteAlbum(albumId);
      if (!ok && context.mounted) {
        final msg =
            ref.read(albumControllerProvider).cloudSyncMessage ?? '删除失败，请稍后重试';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(albumControllerProvider);
    final currentUserId = ref.watch(authControllerProvider).user?.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F6),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const _AlbumPageBackground(),
            RefreshIndicator(
              onRefresh: () async =>
                  ref.read(albumControllerProvider.notifier).refreshAlbums(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '相册',
                                  style: AlbumTheme.titleStyle(
                                    size: 48,
                                    height: 1,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () => _showAlbumEditor(context, ref),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3D5DA),
                                  foregroundColor: const Color(0xFF6B4C54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.add, size: 20),
                                label: Text(
                                  '新建相册',
                                  style: AlbumTheme.bodyStyle(
                                    size: 18,
                                    weight: FontWeight.w800,
                                    color: const Color(0xFF6B4C54),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '把值得记住的时刻，安静收藏起来',
                            style: AlbumTheme.bodyStyle(
                              color: Color(0xFF7D6C6C),
                              size: 18,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AlbumStatsCard(
                            totalAlbums: state.totalAlbums,
                            totalPhotos: state.totalPhotos,
                            lastUpdatedText: AlbumTheme.formatDateTime(
                              state.lastUpdatedAt,
                            ),
                          ),
                          if (state.errorMessage != null &&
                              state.errorMessage!.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          if (state.cloudSyncMessage != null &&
                              state.cloudSyncMessage!.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              state.cloudSyncMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB8860B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading && state.albums.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.albums.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            '还没有相册，点击右上角创建一个吧',
                            style: TextStyle(
                              color: CoupleUi.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final album = state.albums[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 280 + index * 45),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              final dy = (1 - value) * 24;
                              return Transform.translate(
                                offset: Offset(0, dy),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: AlbumGridCard(
                              album: album,
                              currentUserId: currentUserId,
                              onTap: () => context.push('/album/${album.id}'),
                              onEdit: () => _showAlbumEditor(
                                context,
                                ref,
                                albumId: album.id,
                                initialTitle: album.title,
                                initialDescription: album.description,
                              ),
                              onDelete: () =>
                                  _confirmDeleteAlbum(context, ref, album.id),
                            ),
                          );
                        }, childCount: state.albums.length),
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

class _AlbumPageBackground extends StatelessWidget {
  const _AlbumPageBackground();

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
          top: -40,
          right: -30,
          child: _glow(const Color(0x45F6CAD4), 180),
        ),
        Positioned(
          top: 180,
          left: -46,
          child: _glow(const Color(0x40D7E4FF), 150),
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

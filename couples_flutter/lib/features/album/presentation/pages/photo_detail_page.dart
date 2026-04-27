import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../widgets/album_image_view.dart';
import '../widgets/photo_comment_input_bar.dart';
import '../widgets/photo_comment_list.dart';
import '../widgets/photo_meta_card.dart';
import '../widgets/album_theme.dart';

class PhotoDetailPage extends ConsumerStatefulWidget {
  const PhotoDetailPage({super.key, required this.photoId});

  final String photoId;

  @override
  ConsumerState<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends ConsumerState<PhotoDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text;
    final success = await ref
        .read(photoDetailControllerProvider(widget.photoId).notifier)
        .addComment(text);
    if (success) {
      _commentController.clear();
    }
  }

  Future<void> _confirmDeletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除照片'),
          content: const Text('删除后，这张照片以及它的所有评论都会一起移除。'),
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
        .read(photoDetailControllerProvider(widget.photoId).notifier)
        .deletePhoto();
    if (mounted && ok) {
      context.pop();
      return;
    }
    if (mounted && !ok) {
      final vm = ref.read(photoDetailControllerProvider(widget.photoId));
      final message = vm.cloudSyncMessage ?? vm.errorMessage ?? '删除照片失败';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoDetailControllerProvider(widget.photoId));
    final currentUserId = ref.watch(authControllerProvider).user?.userId;
    final photo = state.photo;
    final canDelete = photo?.uploadedBy(currentUserId) ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F8),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const _PhotoDetailBackground(),
            state.isLoading && photo == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(
                                  photoDetailControllerProvider(
                                    widget.photoId,
                                  ).notifier,
                                )
                                .refreshComments();
                          },
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 3 / 4,
                                      child: AlbumImageView(
                                        localPath: photo?.localPath,
                                        imageUrl: photo?.imageUrl,
                                        borderRadius: BorderRadius.zero,
                                        placeholderLabel: '照片详情',
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      top: 10,
                                      child: Row(
                                        children: <Widget>[
                                          _CircleIconButton(
                                            icon: Icons
                                                .arrow_back_ios_new_rounded,
                                            onTap: () => context.pop(),
                                          ),
                                          const Spacer(),
                                          const _CircleIconButton(
                                            icon: Icons.download_outlined,
                                          ),
                                          const SizedBox(width: 8),
                                          if (canDelete)
                                            _CircleIconButton(
                                              icon: Icons.more_horiz_rounded,
                                              onTap: _confirmDeletePhoto,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 14,
                                      bottom: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.45,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          '1/${state.comments.isEmpty ? 1 : 128}',
                                          style: const TextStyle(
                                            fontFamily: 'SpaceGrotesk',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: Container(
                                    key: ValueKey<int>(state.comments.length),
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          if (photo != null)
                                            PhotoMetaCard(
                                              photo: photo,
                                              currentUserId: currentUserId,
                                            ),
                                          const SizedBox(height: 10),
                                          PhotoCommentList(
                                            comments: state.comments,
                                            currentUserId: currentUserId,
                                            onDeleteComment: (commentId) {
                                              ref
                                                  .read(
                                                    photoDetailControllerProvider(
                                                      widget.photoId,
                                                    ).notifier,
                                                  )
                                                  .deleteComment(commentId);
                                            },
                                          ),
                                          if (state.errorMessage != null &&
                                              state.errorMessage!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                state.errorMessage!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          if (state.cloudSyncMessage != null &&
                                              state
                                                  .cloudSyncMessage!
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                state.cloudSyncMessage!,
                                                style: const TextStyle(
                                                  color: Color(0xFFB8860B),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PhotoCommentInputBar(
                        controller: _commentController,
                        isSending: state.isSendingComment,
                        onSend: _sendComment,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _PhotoDetailBackground extends StatelessWidget {
  const _PhotoDetailBackground();

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
          top: -20,
          right: -28,
          child: _glow(const Color(0x30FFD7E1), 130),
        ),
        Positioned(
          top: 380,
          left: -36,
          child: _glow(const Color(0x28D5EAFF), 144),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/idea_sticky_card.dart';
import '../widgets/thought_comment_input_bar.dart';
import '../widgets/thought_comment_tile.dart';

class IdeaDetailPage extends ConsumerWidget {
  const IdeaDetailPage({
    super.key,
    required this.ideaId,
  });

  final String ideaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ideaDetailControllerProvider(ideaId));
    final controller = ref.read(ideaDetailControllerProvider(ideaId).notifier);
    final currentUserId = ref.watch(authControllerProvider).user?.userId;
    final note = state.idea;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('想法详情'),
        actions: <Widget>[
          if (note != null && note.authoredBy(currentUserId))
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/thoughts/idea/edit?ideaId=${note.id}');
                  return;
                }
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('删除想法'),
                      content: const Text('删除后，这条想法和关联评论都会一起移除。'),
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
                    ),
                  );
                  if (confirmed == true &&
                      await controller.deleteIdea() &&
                      context.mounted) {
                    context.pop();
                  }
                }
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'edit', child: Text('编辑')),
                PopupMenuItem<String>(value: 'delete', child: Text('删除')),
              ],
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          top: false,
          child: state.isLoading && note == null
              ? const Center(child: CircularProgressIndicator())
              : note == null
                  ? Center(
                      child: Text(
                        state.errorMessage ?? '这条想法不存在了。',
                        style: ThoughtsTheme.body(size: 15),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: <Widget>[
                        if (state.errorMessage != null) ...<Widget>[
                          _StatusBanner(message: state.errorMessage!, isError: true),
                          const SizedBox(height: 12),
                        ],
                        if (state.cloudSyncMessage != null) ...<Widget>[
                          _StatusBanner(message: state.cloudSyncMessage!),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          height: 420,
                          child: IdeaStickyCard(
                            note: note,
                            currentUserId: currentUserId,
                            onTap: () {},
                            expanded: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: ThoughtsTheme.surfaceDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    '评论区',
                                    style: ThoughtsTheme.title(size: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${state.comments.length})',
                                    style: ThoughtsTheme.number(
                                      size: 14,
                                      color: ThoughtsTheme.softInk,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (state.comments.isEmpty)
                                Text(
                                  '还没有评论，写下一句回应吧。',
                                  style: ThoughtsTheme.body(size: 14),
                                )
                              else
                                ...state.comments.map((comment) {
                                  return ThoughtCommentTile(
                                    comment: comment,
                                    currentUserId: currentUserId,
                                    onDelete: () => controller.deleteComment(comment),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
      bottomNavigationBar: ThoughtCommentInputBar(
        isSending: state.isSendingComment,
        onSend: controller.addComment,
        hintText: '写下你的回应...',
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ThoughtsTheme.statusBannerDecoration(isError: isError),
      child: Text(
        message,
        style: ThoughtsTheme.body(
          size: 13,
          weight: FontWeight.w600,
          color: ThoughtsTheme.ink,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/idea_note.dart';
import '../controllers/thoughts_home_state.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/excerpt_quote_card.dart';
import '../widgets/idea_sticky_card.dart';
import '../widgets/thought_category_chips.dart';
import '../widgets/thoughts_empty_state.dart';
import '../widgets/thoughts_segmented_tabs.dart';

class ThoughtsHomePage extends ConsumerWidget {
  const ThoughtsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thoughtsHomeControllerProvider);
    final controller = ref.read(thoughtsHomeControllerProvider.notifier);
    final currentUserId = ref.watch(authControllerProvider).user?.userId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: controller.refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '想法文摘',
                                        style: ThoughtsTheme.title(
                                          size: 34,
                                          height: 1.06,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '收藏心情、灵感和打动你的文字',
                                        style: ThoughtsTheme.body(
                                          size: 15,
                                          height: 1.55,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _HeaderAction(
                                  icon: state.isSearchVisible
                                      ? Icons.close_rounded
                                      : Icons.search_rounded,
                                  onTap: controller.toggleSearch,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ThoughtsSegmentedTabs(
                              section: state.section,
                              onChanged: controller.selectSection,
                            ),
                            const SizedBox(height: 16),
                            if (state.errorMessage != null) ...<Widget>[
                              _StatusBanner(
                                message: state.errorMessage!,
                                isError: true,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (state.cloudSyncMessage != null) ...<Widget>[
                              _StatusBanner(message: state.cloudSyncMessage!),
                              const SizedBox(height: 12),
                            ],
                            if (state.isSearchVisible) ...<Widget>[
                              Container(
                                decoration: ThoughtsTheme.surfaceDecoration(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  radius: BorderRadius.circular(22),
                                  shadowEnabled: false,
                                ),
                                child: TextField(
                                  onChanged: state.section == ThoughtsSection.ideas
                                      ? controller.updateIdeaQuery
                                      : controller.updateExcerptQuery,
                                  decoration: ThoughtsTheme.inputDecoration(
                                    labelText: '搜索',
                                    hintText: state.section == ThoughtsSection.ideas
                                        ? '搜索标题、便签内容或心情标签'
                                        : '搜索摘录正文、出处、作者或感受',
                                    suffix: const Icon(
                                      Icons.search_rounded,
                                      color: ThoughtsTheme.softInk,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (state.section == ThoughtsSection.ideas)
                              ThoughtCategoryChips<IdeaFilter>(
                                items: const <IdeaFilter>[
                                  IdeaFilter.all,
                                  IdeaFilter.mood,
                                  IdeaFilter.idea,
                                  IdeaFilter.wish,
                                ],
                                selected: state.ideaFilter,
                                labelBuilder: (filter) {
                                  switch (filter) {
                                    case IdeaFilter.mood:
                                      return '心情';
                                    case IdeaFilter.idea:
                                      return '想法';
                                    case IdeaFilter.wish:
                                      return '愿景';
                                    case IdeaFilter.all:
                                      return '全部';
                                  }
                                },
                                onSelected: controller.selectIdeaFilter,
                              )
                            else
                              ThoughtCategoryChips<ExcerptFilter>(
                                items: const <ExcerptFilter>[
                                  ExcerptFilter.all,
                                  ExcerptFilter.book,
                                  ExcerptFilter.movie,
                                  ExcerptFilter.lyric,
                                  ExcerptFilter.custom,
                                ],
                                selected: state.excerptFilter,
                                labelBuilder: (filter) {
                                  switch (filter) {
                                    case ExcerptFilter.book:
                                      return '书籍';
                                    case ExcerptFilter.movie:
                                      return '电影';
                                    case ExcerptFilter.lyric:
                                      return '歌词';
                                    case ExcerptFilter.custom:
                                      return '随记';
                                    case ExcerptFilter.all:
                                      return '全部';
                                  }
                                },
                                onSelected: controller.selectExcerptFilter,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (state.isLoading &&
                        state.ideas.isEmpty &&
                        state.excerpts.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.section == ThoughtsSection.ideas &&
                        state.filteredIdeas.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: ThoughtsEmptyState(
                          title: '还没有便签',
                          subtitle: '写下今天的心情、突然冒出来的灵感，或你们想一起实现的小愿景。',
                          icon: Icons.sticky_note_2_outlined,
                        ),
                      )
                    else if (state.section == ThoughtsSection.excerpts &&
                        state.filteredExcerpts.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: ThoughtsEmptyState(
                          title: '还没有文摘卡片',
                          subtitle: '把一句让你心动的话收藏进来，也可以顺手写下自己的感受。',
                          icon: Icons.auto_stories_outlined,
                        ),
                      )
                    else if (state.section == ThoughtsSection.ideas)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 112),
                          child: _IdeasWaterfall(
                            ideas: state.filteredIdeas,
                            currentUserId: currentUserId,
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 112),
                          child: Column(
                            children: state.filteredExcerpts.map((note) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ExcerptQuoteCard(
                                  note: note,
                                  currentUserId: currentUserId,
                                  onTap: () =>
                                      context.push('/thoughts/excerpt/${note.id}'),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: _QuickCreateFab(
                  expanded: state.isQuickCreateOpen,
                  onMainTap: controller.toggleQuickCreate,
                  onCreateIdea: () {
                    controller.closeQuickCreate();
                    context.push('/thoughts/idea/edit');
                  },
                  onCreateExcerpt: () {
                    controller.closeQuickCreate();
                    context.push('/thoughts/excerpt/edit');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdeasWaterfall extends StatelessWidget {
  const _IdeasWaterfall({
    required this.ideas,
    required this.currentUserId,
  });

  final List<IdeaNote> ideas;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < ideas.length; i++) {
      final note = ideas[i];
      final child = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: IdeaStickyCard(
          note: note,
          currentUserId: currentUserId,
          onTap: () => context.push('/thoughts/idea/${note.id}'),
        ),
      );
      if (i.isEven) {
        left.add(child);
      } else {
        right.add(child);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Column(children: left)),
        const SizedBox(width: 12),
        Expanded(child: Column(children: right)),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: ThoughtsTheme.surfaceDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            radius: BorderRadius.circular(999),
            shadowEnabled: false,
          ),
          child: Icon(icon, color: ThoughtsTheme.ink, size: 20),
        ),
      ),
    );
  }
}

class _QuickCreateFab extends StatelessWidget {
  const _QuickCreateFab({
    required this.expanded,
    required this.onMainTap,
    required this.onCreateIdea,
    required this.onCreateExcerpt,
  });

  final bool expanded;
  final VoidCallback onMainTap;
  final VoidCallback onCreateIdea;
  final VoidCallback onCreateExcerpt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: expanded
              ? Column(
                  key: const ValueKey('menu'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _MiniAction(label: '记文摘', onTap: onCreateExcerpt),
                    const SizedBox(height: 10),
                    _MiniAction(label: '写想法', onTap: onCreateIdea),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        FloatingActionButton(
          onPressed: onMainTap,
          backgroundColor: ThoughtsTheme.rose,
          foregroundColor: Colors.white,
          elevation: 0,
          child: Icon(expanded ? Icons.close_rounded : Icons.add_rounded, size: 30),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: ThoughtsTheme.surfaceDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            radius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: ThoughtsTheme.body(
              size: 14,
              weight: FontWeight.w700,
              color: ThoughtsTheme.ink,
            ),
          ),
        ),
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
          height: 1.5,
        ),
      ),
    );
  }
}

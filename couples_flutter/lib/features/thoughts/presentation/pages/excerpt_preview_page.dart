import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/excerpt_note.dart';
import '../models/excerpt_draft.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/excerpt_quote_card.dart';

class ExcerptPreviewPage extends ConsumerStatefulWidget {
  const ExcerptPreviewPage({super.key, required this.draft});

  final ExcerptDraft draft;

  @override
  ConsumerState<ExcerptPreviewPage> createState() =>
      _ExcerptPreviewPageState();
}

class _ExcerptPreviewPageState extends ConsumerState<ExcerptPreviewPage> {
  late ExcerptDraft _draft;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    final controller = ref.read(thoughtsHomeControllerProvider.notifier);
    final ok = await controller.saveExcerpt(
      excerptId: _draft.excerptId,
      category: _draft.category,
      quoteText: _draft.quoteText,
      sourceTitle: _draft.sourceTitle,
      sourceAuthor: _draft.sourceAuthor,
      sourceDetail: _draft.sourceDetail,
      personalNote: _draft.personalNote,
      cardStyle: _draft.cardStyle,
      colorStyle: _draft.colorStyle,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请稍后再试。')),
      );
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    if (navigator.canPop()) {
      navigator.pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存并发布～')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        ref.watch(authControllerProvider).user?.userId ?? 'me';
    final preview = _draft.toPreviewExcerpt(
      coupleId: 'preview',
      authorUserId: currentUserId,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('预览文摘'),
      ),
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: <Widget>[
                    ExcerptQuoteCard(
                      note: preview,
                      currentUserId: currentUserId,
                      onTap: () {},
                      large: true,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: ThoughtsTheme.surfaceDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '卡片样式',
                            style: ThoughtsTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: ThoughtsTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final value =
                                    ExcerptNote.supportedCardStyles[index];
                                final selected = value == _draft.cardStyle;
                                return _CardStyleTile(
                                  value: value,
                                  selected: selected,
                                  onTap: () => setState(() {
                                    _draft = _draft.copyWith(cardStyle: value);
                                  }),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemCount:
                                  ExcerptNote.supportedCardStyles.length,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            '配色方案',
                            style: ThoughtsTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: ThoughtsTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                ExcerptNote.supportedColorStyles.map((value) {
                              final selected = value == _draft.colorStyle;
                              return _ColorDot(
                                color: ThoughtsTheme.excerptColor(value),
                                selected: selected,
                                onTap: () => setState(() {
                                  _draft = _draft.copyWith(colorStyle: value);
                                }),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '创建完成后可在文摘详情页更换样式。',
                      textAlign: TextAlign.center,
                      style: ThoughtsTheme.body(
                        size: 12,
                        color: ThoughtsTheme.softInk,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: ThoughtsTheme.ink,
                          side: const BorderSide(
                            color: ThoughtsTheme.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('重新编辑'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        style: ThoughtsTheme.primaryButtonStyle(),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('保存并发布'),
                      ),
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

class _CardStyleTile extends StatelessWidget {
  const _CardStyleTile({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? ThoughtsTheme.rose.withValues(alpha: 0.78)
                : ThoughtsTheme.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ThoughtsTheme.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '"',
                    style: ThoughtsTheme.title(
                      size: 24,
                      color: ThoughtsTheme.accentForStyle(value),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ThoughtsTheme.cardStyleLabel(value),
              style: ThoughtsTheme.body(
                size: 11,
                weight: FontWeight.w700,
                color: selected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? ThoughtsTheme.rose : ThoughtsTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
            : null,
      ),
    );
  }
}

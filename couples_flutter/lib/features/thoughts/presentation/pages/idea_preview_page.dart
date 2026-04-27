import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/idea_note.dart';
import '../models/idea_draft.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/idea_sticky_card.dart';

class IdeaPreviewPage extends ConsumerStatefulWidget {
  const IdeaPreviewPage({super.key, required this.draft});

  final IdeaDraft draft;

  @override
  ConsumerState<IdeaPreviewPage> createState() => _IdeaPreviewPageState();
}

class _IdeaPreviewPageState extends ConsumerState<IdeaPreviewPage> {
  late IdeaDraft _draft;
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
    final ok = await controller.saveIdea(
      ideaId: _draft.ideaId,
      type: _draft.type,
      title: _draft.title,
      content: _draft.content,
      moodTags: _draft.moodTags,
      colorStyle: _draft.colorStyle,
      layoutStyle: _draft.layoutStyle,
      stickerStyle: _draft.stickerStyle,
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
      // Pop preview page first.
      navigator.pop();
    }
    if (navigator.canPop()) {
      // Pop edit page so we land back on the home list.
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
    final preview = _draft.toPreviewIdea(
      coupleId: 'preview',
      authorUserId: currentUserId,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('预览想法'),
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
                    SizedBox(
                      height: 380,
                      child: IdeaStickyCard(
                        note: preview,
                        currentUserId: currentUserId,
                        onTap: () {},
                        expanded: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: ThoughtsTheme.surfaceDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '便签颜色',
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
                                IdeaNote.supportedColorStyles.map((value) {
                              final selected = value == _draft.colorStyle;
                              return _CircleSwatch(
                                color: ThoughtsTheme.ideaColor(value),
                                selected: selected,
                                onTap: () => setState(() {
                                  _draft = _draft.copyWith(colorStyle: value);
                                }),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            '贴纸 / 纹理',
                            style: ThoughtsTheme.body(
                              size: 14,
                              weight: FontWeight.w700,
                              color: ThoughtsTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '可选，给便签右下角加一个小图标',
                            style: ThoughtsTheme.body(
                              size: 12,
                              color: ThoughtsTheme.softInk,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              _StickerTile(
                                icon: Icons.block_rounded,
                                label: '不加',
                                selected: _draft.stickerStyle == null,
                                onTap: () => setState(() {
                                  _draft = _draft.copyWith(stickerStyle: null);
                                }),
                              ),
                              for (final style
                                  in IdeaNote.supportedStickerStyles)
                                _StickerTile(
                                  icon: ThoughtsTheme.stickerIcon(style),
                                  label: ThoughtsTheme.stickerLabel(style),
                                  selected: _draft.stickerStyle == style,
                                  onTap: () => setState(() {
                                    _draft =
                                        _draft.copyWith(stickerStyle: style);
                                  }),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '保存后会同步到云端，本地始终保留一份。',
                      textAlign: TextAlign.center,
                      style: ThoughtsTheme.body(
                        size: 12,
                        color: ThoughtsTheme.softInk,
                      ),
                    ),
                  ],
                ),
              ),
              _BottomBar(
                isSaving: _isSaving,
                onCancel: () {
                  // Pop preview, edit page receives the latest draft we set in.
                  context.pop();
                },
                onConfirm: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleSwatch extends StatelessWidget {
  const _CircleSwatch({
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? ThoughtsTheme.rose : ThoughtsTheme.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: ThoughtsTheme.rose.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        alignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
            : null,
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? ThoughtsTheme.blush.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? ThoughtsTheme.rose.withValues(alpha: 0.78)
                : ThoughtsTheme.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 26,
              color: selected ? ThoughtsTheme.rose : ThoughtsTheme.ink,
            ),
            const SizedBox(height: 6),
            Text(
              label,
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

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onCancel,
    required this.onConfirm,
    required this.isSaving,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: ThoughtsTheme.ink,
                side: const BorderSide(color: ThoughtsTheme.border),
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
              onPressed: isSaving ? null : onConfirm,
              style: ThoughtsTheme.primaryButtonStyle(),
              child: isSaving
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
    );
  }
}

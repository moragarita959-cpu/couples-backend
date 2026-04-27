import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/excerpt_note.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/excerpt_quote_card.dart';
import '../widgets/thought_style_selector.dart';

class ExcerptEditPage extends ConsumerStatefulWidget {
  const ExcerptEditPage({
    super.key,
    this.excerptId,
  });

  final String? excerptId;

  @override
  ConsumerState<ExcerptEditPage> createState() => _ExcerptEditPageState();
}

class _ExcerptEditPageState extends ConsumerState<ExcerptEditPage> {
  late final TextEditingController _quoteController;
  late final TextEditingController _sourceTitleController;
  late final TextEditingController _sourceAuthorController;
  late final TextEditingController _sourceDetailController;
  late final TextEditingController _personalNoteController;
  bool _seeded = false;
  String _category = ExcerptNote.categoryBook;
  String _cardStyle = ExcerptNote.supportedCardStyles.first;
  String _colorStyle = ExcerptNote.supportedColorStyles.first;

  bool get _isCreateMode => widget.excerptId == null;

  @override
  void initState() {
    super.initState();
    _quoteController = TextEditingController();
    _sourceTitleController = TextEditingController();
    _sourceAuthorController = TextEditingController();
    _sourceDetailController = TextEditingController();
    _personalNoteController = TextEditingController();
    for (final controller in <TextEditingController>[
      _quoteController,
      _sourceTitleController,
      _sourceAuthorController,
      _sourceDetailController,
      _personalNoteController,
    ]) {
      controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _quoteController,
      _sourceTitleController,
      _sourceAuthorController,
      _sourceDetailController,
      _personalNoteController,
    ]) {
      controller
        ..removeListener(_rebuild)
        ..dispose();
    }
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  void _seed(ExcerptNote? note) {
    if (_seeded || note == null) {
      return;
    }
    _seeded = true;
    _quoteController.text = note.quoteText;
    _sourceTitleController.text = note.sourceTitle ?? '';
    _sourceAuthorController.text = note.sourceAuthor ?? '';
    _sourceDetailController.text = note.sourceDetail ?? '';
    _personalNoteController.text = note.personalNote ?? '';
    _category = note.category;
    _cardStyle = note.cardStyle ?? ExcerptNote.supportedCardStyles.first;
    _colorStyle = note.colorStyle ?? ExcerptNote.supportedColorStyles.first;
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.excerptId == null
        ? null
        : ref.watch(watchExcerptNoteProvider).call(widget.excerptId!);
    final currentUserId = ref.watch(authControllerProvider).user?.userId ?? 'me';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.excerptId == null ? '创建文摘' : '编辑文摘'),
      ),
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          top: false,
          child: StreamBuilder<ExcerptNote?>(
            stream: stream,
            builder: (context, snapshot) {
              final note = snapshot.data;
              _seed(note);
              final preview = ExcerptNote(
                id: widget.excerptId ?? 'preview',
                coupleId: 'preview',
                authorUserId: currentUserId,
                category: _category,
                quoteText: _quoteController.text.trim().isEmpty
                    ? '我想和你一起生活，在某个小镇，共享无尽的黄昏。'
                    : _quoteController.text.trim(),
                sourceTitle: _sourceTitleController.text.trim().isEmpty
                    ? '爱你就像爱生命'
                    : _sourceTitleController.text.trim(),
                sourceAuthor: _sourceAuthorController.text.trim().isEmpty
                    ? '王小波'
                    : _sourceAuthorController.text.trim(),
                sourceDetail: _sourceDetailController.text.trim().isEmpty
                    ? null
                    : _sourceDetailController.text.trim(),
                personalNote: _personalNoteController.text.trim().isEmpty
                    ? '这句话给了我很大的安慰，原来有人也渴望这样平凡而温柔的生活。'
                    : _personalNoteController.text.trim(),
                cardStyle: _cardStyle,
                colorStyle: _colorStyle,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: <Widget>[
                  ExcerptQuoteCard(
                    note: preview,
                    currentUserId: currentUserId,
                    onTap: () {},
                    large: true,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: ThoughtsTheme.surfaceDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '分类',
                          style: ThoughtsTheme.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CategorySelector(
                          currentValue: _category,
                          onChanged: (value) => setState(() => _category = value),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _quoteController,
                          minLines: 5,
                          maxLines: 8,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '摘录正文',
                            hintText: '写下那句打动你的话',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sourceTitleController,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '出处标题',
                            hintText: '例如《爱你就像爱生命》',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sourceAuthorController,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '作者',
                            hintText: '例如 王小波',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sourceDetailController,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '额外出处信息',
                            hintText: '页码、章节、电影名或歌曲名（可选）',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _personalNoteController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '我的感受',
                            hintText: '为什么你想把它留下来？',
                            alignLabelWithHint: true,
                          ),
                        ),
                        if (_isCreateMode) ...<Widget>[
                          const SizedBox(height: 16),
                          ThoughtStyleSelector(
                            title: '卡片样式',
                            options: ExcerptNote.supportedCardStyles,
                            currentValue: _cardStyle,
                            labelBuilder: ThoughtsTheme.cardStyleLabel,
                            onSelected: (value) => setState(() => _cardStyle = value),
                          ),
                          const SizedBox(height: 16),
                          ThoughtStyleSelector(
                            title: '配色方案',
                            options: ExcerptNote.supportedColorStyles,
                            currentValue: _colorStyle,
                            labelBuilder: (value) => value,
                            onSelected: (value) => setState(() => _colorStyle = value),
                            previewBuilder: (value, selected) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: ThoughtsTheme.excerptColor(value),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () async {
                            final success = await ref
                                .read(thoughtsHomeControllerProvider.notifier)
                                .saveExcerpt(
                                  excerptId: widget.excerptId,
                                  category: _category,
                                  quoteText: _quoteController.text,
                                  sourceTitle: _sourceTitleController.text,
                                  sourceAuthor: _sourceAuthorController.text,
                                  sourceDetail: _sourceDetailController.text,
                                  personalNote: _personalNoteController.text,
                                  cardStyle: _cardStyle,
                                  colorStyle: _colorStyle,
                                );
                            if (success && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ThoughtsTheme.primaryButtonStyle(),
                          child: Text(widget.excerptId == null ? '完成创建' : '保存修改'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.currentValue,
    required this.onChanged,
  });

  final String currentValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      ExcerptNote.categoryBook,
      ExcerptNote.categoryMovie,
      ExcerptNote.categoryLyric,
      ExcerptNote.categoryCustom,
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((value) {
        final selected = value == currentValue;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(value),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: ThoughtsTheme.chipDecoration(selected: selected),
            child: Text(
              ThoughtsTheme.excerptCategoryLabel(value),
              style: ThoughtsTheme.body(
                size: 13,
                weight: FontWeight.w700,
                color: selected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

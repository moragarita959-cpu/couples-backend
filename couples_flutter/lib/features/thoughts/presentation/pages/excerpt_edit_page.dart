import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/excerpt_note.dart';
import '../models/excerpt_draft.dart';
import '../theme/thoughts_theme.dart';

const int _kQuoteMax = 200;
const int _kNoteMax = 300;
const int _kSourceTitleMax = 30;
const int _kSourceAuthorMax = 20;
const int _kSourceDetailMax = 30;

class ExcerptEditPage extends ConsumerStatefulWidget {
  const ExcerptEditPage({
    super.key,
    this.excerptId,
    this.initialDraft,
  });

  final String? excerptId;
  final ExcerptDraft? initialDraft;

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
    final draft = widget.initialDraft;
    if (draft != null) {
      _seeded = true;
      _quoteController.text = draft.quoteText;
      _sourceTitleController.text = draft.sourceTitle;
      _sourceAuthorController.text = draft.sourceAuthor;
      _sourceDetailController.text = draft.sourceDetail;
      _personalNoteController.text = draft.personalNote;
      _category = draft.category;
      _cardStyle = draft.cardStyle;
      _colorStyle = draft.colorStyle;
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

  void _seedFromExisting(ExcerptNote? note) {
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

  bool get _canSubmit => _quoteController.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('引文不能为空，先抄一句吧～')),
      );
      return;
    }
    final draft = ExcerptDraft(
      excerptId: widget.excerptId,
      category: _category,
      quoteText: _quoteController.text.trim(),
      sourceTitle: _sourceTitleController.text.trim(),
      sourceAuthor: _sourceAuthorController.text.trim(),
      sourceDetail: _sourceDetailController.text.trim(),
      personalNote: _personalNoteController.text.trim(),
      cardStyle: _cardStyle,
      colorStyle: _colorStyle,
    );
    context.push('/thoughts/excerpt/preview', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.excerptId == null
        ? null
        : ref.watch(watchExcerptNoteProvider).call(widget.excerptId!);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.excerptId == null ? '创建文摘' : '编辑文摘'),
        actions: <Widget>[
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text(
              '完成',
              style: ThoughtsTheme.body(
                size: 15,
                weight: FontWeight.w700,
                color: _canSubmit
                    ? ThoughtsTheme.rose
                    : ThoughtsTheme.softInk.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          top: false,
          child: StreamBuilder<ExcerptNote?>(
            stream: stream,
            builder: (context, snapshot) {
              _seedFromExisting(snapshot.data);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ThoughtsTheme.surfaceDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Label('分类'),
                        const SizedBox(height: 12),
                        _CategorySelector(
                          currentValue: _category,
                          onChanged: (value) =>
                              setState(() => _category = value),
                        ),
                        const SizedBox(height: 22),
                        _CounterRow(
                          label: '引文',
                          current: _quoteController.text.characters.length,
                          max: _kQuoteMax,
                          highlight: true,
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: <Widget>[
                            TextField(
                              controller: _quoteController,
                              minLines: 5,
                              maxLines: 8,
                              maxLength: _kQuoteMax,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(_kQuoteMax),
                              ],
                              decoration: ThoughtsTheme.inputDecoration(
                                hintText: '写下那句打动你的话',
                                alignLabelWithHint: true,
                              ).copyWith(
                                counterText: '',
                                contentPadding: const EdgeInsets.fromLTRB(
                                  32,
                                  18,
                                  18,
                                  18,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              top: 8,
                              child: Text(
                                '"',
                                style: ThoughtsTheme.title(
                                  size: 32,
                                  color: ThoughtsTheme.rose
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _Label('出处'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sourceTitleController,
                          maxLength: _kSourceTitleMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kSourceTitleMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '出处标题，例如《爱你就像爱生命》',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sourceAuthorController,
                          maxLength: _kSourceAuthorMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kSourceAuthorMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '作者，例如 王小波',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sourceDetailController,
                          maxLength: _kSourceDetailMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kSourceDetailMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '页码 / 章节 / 备注（可选）',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 18),
                        _CounterRow(
                          label: '我的感受（可选）',
                          current:
                              _personalNoteController.text.characters.length,
                          max: _kNoteMax,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _personalNoteController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: _kNoteMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kNoteMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '为什么你想把它留下来？',
                            alignLabelWithHint: true,
                          ).copyWith(counterText: ''),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点右上角"完成"进入预览，可以再选卡片样式和配色。',
                    textAlign: TextAlign.center,
                    style: ThoughtsTheme.body(
                      size: 12,
                      color: ThoughtsTheme.softInk,
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ThoughtsTheme.body(
        size: 14,
        weight: FontWeight.w700,
        color: ThoughtsTheme.ink,
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.current,
    required this.max,
    this.highlight = false,
  });

  final String label;
  final int current;
  final int max;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final reachedLimit = current >= max;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: ThoughtsTheme.body(
            size: 14,
            weight: FontWeight.w700,
            color: ThoughtsTheme.ink,
          ),
        ),
        Text(
          '$current/$max',
          style: ThoughtsTheme.number(
            size: 12,
            weight: FontWeight.w700,
            color: reachedLimit
                ? ThoughtsTheme.rose
                : (highlight ? ThoughtsTheme.ink : ThoughtsTheme.softInk),
          ),
        ),
      ],
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ExcerptNote.supportedCategories.map((value) {
        final selected = value == currentValue;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(value),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

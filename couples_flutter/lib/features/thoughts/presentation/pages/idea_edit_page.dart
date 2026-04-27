import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/idea_note.dart';
import '../models/idea_draft.dart';
import '../theme/thoughts_theme.dart';

const int _kIdeaTitleMax = 20;
const int _kIdeaContentMax = 300;

class IdeaEditPage extends ConsumerStatefulWidget {
  const IdeaEditPage({
    super.key,
    this.ideaId,
    this.initialDraft,
  });

  final String? ideaId;

  /// When the user comes back from the preview page via "重新编辑" we restore
  /// their previous draft so they don't lose the current input.
  final IdeaDraft? initialDraft;

  @override
  ConsumerState<IdeaEditPage> createState() => _IdeaEditPageState();
}

class _IdeaEditPageState extends ConsumerState<IdeaEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _seeded = false;
  String _type = IdeaNote.typeIdea;
  final Set<String> _moodTags = <String>{};
  String _colorStyle = IdeaNote.supportedColorStyles.first;
  String _layoutStyle = IdeaNote.supportedLayoutStyles.first;
  String? _stickerStyle;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_rebuild);
    _contentController.addListener(_rebuild);
    final draft = widget.initialDraft;
    if (draft != null) {
      _seeded = true;
      _titleController.text = draft.title;
      _contentController.text = draft.content;
      _type = draft.type;
      _moodTags
        ..clear()
        ..addAll(draft.moodTags);
      _colorStyle = draft.colorStyle;
      _layoutStyle = draft.layoutStyle;
      _stickerStyle = draft.stickerStyle;
    }
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_rebuild)
      ..dispose();
    _contentController
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  void _seedFromExisting(IdeaNote? note) {
    if (_seeded || note == null) {
      return;
    }
    _seeded = true;
    _titleController.text = note.title ?? '';
    _contentController.text = note.content;
    _type = note.type;
    _moodTags
      ..clear()
      ..addAll(note.moodTags);
    _colorStyle = note.colorStyle ?? IdeaNote.supportedColorStyles.first;
    _layoutStyle = note.layoutStyle ?? IdeaNote.supportedLayoutStyles.first;
    _stickerStyle = note.stickerStyle;
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容不能为空，先写点什么吧～')),
      );
      return;
    }
    final draft = IdeaDraft(
      ideaId: widget.ideaId,
      type: _type,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      moodTags: _moodTags.toList(growable: false),
      colorStyle: _colorStyle,
      layoutStyle: _layoutStyle,
      stickerStyle: _stickerStyle,
    );
    context.push('/thoughts/idea/preview', extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.ideaId == null
        ? null
        : ref.watch(watchIdeaNoteProvider).call(widget.ideaId!);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.ideaId == null ? '创建想法' : '编辑想法'),
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
          child: StreamBuilder<IdeaNote?>(
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
                        _SectionLabel('类型'),
                        const SizedBox(height: 12),
                        _IdeaTypeSelector(
                          currentValue: _type,
                          onChanged: (value) => setState(() => _type = value),
                        ),
                        const SizedBox(height: 22),
                        _CounterRow(
                          label: '标题（可选）',
                          current: _titleController.text.characters.length,
                          max: _kIdeaTitleMax,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          maxLength: _kIdeaTitleMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kIdeaTitleMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '给这张便签起一个名字',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 18),
                        _CounterRow(
                          label: '内容',
                          current: _contentController.text.characters.length,
                          max: _kIdeaContentMax,
                          highlight: true,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _contentController,
                          minLines: 5,
                          maxLines: 8,
                          maxLength: _kIdeaContentMax,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(_kIdeaContentMax),
                          ],
                          decoration: ThoughtsTheme.inputDecoration(
                            hintText: '记录今天的心情、有趣想法，或者你们想一起完成的小愿景',
                            alignLabelWithHint: true,
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 22),
                        _SectionLabel('心情标签（多选）'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: IdeaNote.supportedMoodTags.map((tag) {
                            final selected = _moodTags.contains(tag);
                            return _MoodChip(
                              label: tag,
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    _moodTags.remove(tag);
                                  } else {
                                    _moodTags.add(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                        _SectionLabel('便签颜色'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: IdeaNote.supportedColorStyles.map((value) {
                            final selected = value == _colorStyle;
                            return _ColorSwatch(
                              color: ThoughtsTheme.ideaColor(value),
                              selected: selected,
                              onTap: () => setState(() => _colorStyle = value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                        _SectionLabel('便签样式'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final option =
                                  IdeaNote.supportedLayoutStyles[index];
                              final selected = option == _layoutStyle;
                              return _LayoutTile(
                                value: option,
                                selected: selected,
                                onTap: () =>
                                    setState(() => _layoutStyle = option),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemCount: IdeaNote.supportedLayoutStyles.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点右上角"完成"进入预览，可以再调整颜色和贴纸。',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

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

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ThoughtsTheme.chipDecoration(selected: selected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.favorite_rounded,
              size: 14,
              color: selected
                  ? ThoughtsTheme.rose
                  : ThoughtsTheme.softInk.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: ThoughtsTheme.body(
                size: 13,
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

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
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
            color: selected
                ? ThoughtsTheme.rose
                : ThoughtsTheme.border,
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
            ? const Icon(
                Icons.check_rounded,
                size: 20,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

class _LayoutTile extends StatelessWidget {
  const _LayoutTile({
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
        width: 88,
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
              child: _LayoutPreview(value: value),
            ),
            const SizedBox(height: 6),
            Text(
              ThoughtsTheme.layoutLabel(value),
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

class _LayoutPreview extends StatelessWidget {
  const _LayoutPreview({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThoughtsTheme.blush.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: <Widget>[
          if (value == 'tape')
            Positioned(
              top: -6,
              left: 12,
              right: 12,
              child: Container(
                height: 12,
                color: ThoughtsTheme.tapeColor('rose').withValues(alpha: 0.9),
              ),
            ),
          if (value == 'pin')
            const Positioned(
              top: 6,
              right: 8,
              child: Icon(Icons.push_pin_rounded,
                  size: 16, color: Colors.redAccent),
            ),
          if (value == 'paperclip')
            const Positioned(
              top: 4,
              left: 6,
              child: Icon(Icons.attachment_rounded,
                  size: 18, color: Color(0xFFC0A263)),
            ),
          if (value == 'spiral')
            Positioned(
              top: 4,
              left: 6,
              right: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (_) => Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB89A8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IdeaTypeSelector extends StatelessWidget {
  const _IdeaTypeSelector({
    required this.currentValue,
    required this.onChanged,
  });

  final String currentValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const <String>[
      IdeaNote.typeMood,
      IdeaNote.typeIdea,
      IdeaNote.typeWish,
    ];
    return Row(
      children: items.map((value) {
        final selected = value == currentValue;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: value == items.last ? 0 : 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(value),
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: ThoughtsTheme.chipDecoration(selected: selected),
                child: Text(
                  ThoughtsTheme.ideaTypeLabel(value),
                  textAlign: TextAlign.center,
                  style: ThoughtsTheme.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: selected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

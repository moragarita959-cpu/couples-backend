import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/idea_note.dart';
import '../theme/thoughts_theme.dart';
import '../widgets/idea_sticky_card.dart';
import '../widgets/thought_style_selector.dart';

class IdeaEditPage extends ConsumerStatefulWidget {
  const IdeaEditPage({
    super.key,
    this.ideaId,
  });

  final String? ideaId;

  @override
  ConsumerState<IdeaEditPage> createState() => _IdeaEditPageState();
}

class _IdeaEditPageState extends ConsumerState<IdeaEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _seeded = false;
  String _type = IdeaNote.typeIdea;
  String? _moodTag;
  String _colorStyle = IdeaNote.supportedColorStyles.first;
  String _layoutStyle = IdeaNote.supportedLayoutStyles.first;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_rebuild);
    _contentController.addListener(_rebuild);
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

  void _seed(IdeaNote? note) {
    if (_seeded || note == null) {
      return;
    }
    _seeded = true;
    _titleController.text = note.title ?? '';
    _contentController.text = note.content;
    _type = note.type;
    _moodTag = note.moodTag;
    _colorStyle = note.colorStyle ?? IdeaNote.supportedColorStyles.first;
    _layoutStyle = note.layoutStyle ?? IdeaNote.supportedLayoutStyles.first;
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.ideaId == null
        ? null
        : ref.watch(watchIdeaNoteProvider).call(widget.ideaId!);
    final currentUserId = ref.watch(authControllerProvider).user?.userId ?? 'me';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.ideaId == null ? '创建想法' : '编辑想法'),
      ),
      body: DecoratedBox(
        decoration: ThoughtsTheme.pageDecoration(),
        child: SafeArea(
          top: false,
          child: StreamBuilder<IdeaNote?>(
            stream: stream,
            builder: (context, snapshot) {
              final note = snapshot.data;
              _seed(note);
              final preview = IdeaNote(
                id: widget.ideaId ?? 'preview',
                coupleId: 'preview',
                authorUserId: currentUserId,
                type: _type,
                title: _titleController.text.trim().isEmpty
                    ? null
                    : _titleController.text.trim(),
                content: _contentController.text.trim().isEmpty
                    ? '今天有一点想法，想先轻轻写在这里。'
                    : _contentController.text.trim(),
                moodTag: _moodTag,
                colorStyle: _colorStyle,
                layoutStyle: _layoutStyle,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: <Widget>[
                  SizedBox(
                    height: 360,
                    child: IdeaStickyCard(
                      note: preview,
                      currentUserId: currentUserId,
                      onTap: () {},
                      expanded: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: ThoughtsTheme.surfaceDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '类型',
                          style: ThoughtsTheme.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TypeSelector(
                          currentValue: _type,
                          onChanged: (value) => setState(() => _type = value),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '标题（可选）',
                            hintText: '给这张便签起一个名字',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentController,
                          minLines: 5,
                          maxLines: 8,
                          decoration: ThoughtsTheme.inputDecoration(
                            labelText: '内容',
                            hintText: '记录今天的心情、有趣想法，或者你们想一起完成的小愿景',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '心情标签',
                          style: ThoughtsTheme.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: ThoughtsTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: IdeaNote.supportedMoodTags.map((tag) {
                            final selected = _moodTag == tag;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _moodTag = selected ? null : tag;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: ThoughtsTheme.chipDecoration(
                                  selected: selected,
                                ),
                                child: Text(
                                  tag,
                                  style: ThoughtsTheme.body(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: selected
                                        ? ThoughtsTheme.ink
                                        : ThoughtsTheme.softInk,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        ThoughtStyleSelector(
                          title: '便签颜色',
                          options: IdeaNote.supportedColorStyles,
                          currentValue: _colorStyle,
                          labelBuilder: (value) => value,
                          onSelected: (value) => setState(() => _colorStyle = value),
                          previewBuilder: (value, selected) {
                            return Container(
                              decoration: BoxDecoration(
                                color: ThoughtsTheme.ideaColor(value),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ThoughtStyleSelector(
                          title: '排版样式',
                          options: IdeaNote.supportedLayoutStyles,
                          currentValue: _layoutStyle,
                          labelBuilder: ThoughtsTheme.ideaLayoutLabel,
                          onSelected: (value) => setState(() => _layoutStyle = value),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () async {
                            final success = await ref
                                .read(thoughtsHomeControllerProvider.notifier)
                                .saveIdea(
                                  ideaId: widget.ideaId,
                                  type: _type,
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  moodTag: _moodTag,
                                  colorStyle: _colorStyle,
                                  layoutStyle: _layoutStyle,
                                );
                            if (success && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ThoughtsTheme.primaryButtonStyle(),
                          child: Text(widget.ideaId == null ? '完成创建' : '保存修改'),
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

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.currentValue,
    required this.onChanged,
  });

  final String currentValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
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

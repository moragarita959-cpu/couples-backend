import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../../domain/genre/genre_catalog.dart';
import '../widgets/genre_mixed_text.dart';
import 'song_review_page.dart';

class SongDetailPage extends ConsumerStatefulWidget {
  const SongDetailPage({super.key, required this.song});
  final Song song;

  @override
  ConsumerState<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends ConsumerState<SongDetailPage> {
  static const List<String> _tagSuggestions = <String>[
    '回忆感',
    '电子音乐',
    '华语经典',
    '通勤',
    '循环',
    '适合分享',
    '歌词杀',
    '轻快',
    '安静',
  ];

  late final TextEditingController _reviewController;
  late final TextEditingController _customTagController;
  double _score = 0;
  List<String> _selectedTags = <String>[];

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _customTagController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDraft());
  }

  Future<void> _initDraft() async {
    final controller = ref.read(playlistControllerProvider.notifier);
    await controller.loadReviews(widget.song.id);
    final mine = controller.reviewByAuthor(widget.song.id, ReviewAuthor.me);
    if (!mounted) return;
    setState(() {
      _score = mine?.singleScore ?? 0;
      _selectedTags = List<String>.from(mine?.styleTags ?? const <String>[]);
      _reviewController.text = mine?.content ?? '';
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistControllerProvider);
    final controller = ref.read(playlistControllerProvider.notifier);
    final myReview = controller.reviewByAuthor(widget.song.id, ReviewAuthor.me);
    final partnerReview = controller.reviewByAuthor(widget.song.id, ReviewAuthor.partner);
    final total = controller.totalScoreFor(widget.song.id);
    final greekIdx = controller.greekBadgeIndexForSong(widget.song.id);
    final knownTags = <String>{..._tagSuggestions, ...controller.allKnownTags(), ..._selectedTags};
    final tagOptions = knownTags.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final recommenderLabel = widget.song.recommender == SongRecommender.me ? '我推荐' : 'TA推荐';
    final recommenderColor = widget.song.recommender == SongRecommender.me
        ? CoupleUi.primaryStrong
        : CoupleUi.partner;
    final resolvedGenre = GenreCatalog.resolve(widget.song.genre);

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('歌曲详情'),
        backgroundColor: CoupleUi.surface,
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await controller.deleteSong(widget.song);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: '删除',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: CoupleUi.pageBackgroundDecoration(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: CoupleUi.sectionCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.song.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(widget.song.artist, style: const TextStyle(color: CoupleUi.textSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _pill(recommenderLabel, recommenderColor),
                      _primaryGenrePill(resolvedGenre.category),
                      if (resolvedGenre.subTag != null)
                        _subGenrePill(resolvedGenre.category, resolvedGenre.subTag!),
                      _pill(
                        greekIdx != null
                            ? '总分 ${CoupleUi.combinedScoreLabel(total)} · ${CoupleUi.greekSymbolForIndex(greekIdx)}'
                            : '总分 ${CoupleUi.combinedScoreLabel(total)}',
                        CoupleUi.scoreColorCombined31(total),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: CoupleUi.sectionCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text('我的评分', style: TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Text(
                        _score.toStringAsFixed(1),
                        style: TextStyle(
                          color: CoupleUi.scoreColorForSingle(_score),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _score,
                    min: -15,
                    max: 15,
                    divisions: 300,
                    onChanged: (value) => setState(() => _score = value),
                  ),
                  const SizedBox(height: 6),
                  const Text('选择我的标签', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tagOptions.map((tag) {
                      final selected = _selectedTags.contains(tag);
                      return FilterChip(
                        selected: selected,
                        label: Text(tag),
                        onSelected: (_) => setState(() {
                          if (selected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _customTagController,
                          decoration: CoupleUi.inputDecoration(
                            labelText: '新增自定义标签',
                            hintText: '输入后点添加',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final tag = _customTagController.text.trim();
                          if (tag.isEmpty) {
                            return;
                          }
                          setState(() {
                            if (!_selectedTags.any((e) => e.toLowerCase() == tag.toLowerCase())) {
                              _selectedTags.add(tag);
                            }
                            _customTagController.clear();
                          });
                        },
                        style: CoupleUi.primaryButtonStyle(),
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: CoupleUi.inputDecoration(
                      labelText: '我的歌评',
                      hintText: '写下完整歌评，列表页不再展开显示',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: state.isSubmittingSong
                          ? null
                          : () async {
                              await controller.addOrUpdateReview(
                                songId: widget.song.id,
                                content: _reviewController.text,
                                styleTags: _selectedTags,
                                singleScore: _score,
                              );
                            },
                      style: CoupleUi.primaryButtonStyle(),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: CoupleUi.sectionCardDecoration(),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('我的歌评'),
                    subtitle: Text(myReview?.content.trim().isEmpty ?? true ? '暂无歌评' : '点击查看完整内容'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: myReview == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => SongReviewPage(song: widget.song, review: myReview),
                              ),
                            ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('TA的歌评'),
                    subtitle: Text(partnerReview?.content.trim().isEmpty ?? true ? '暂无歌评' : '点击查看完整内容'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: partnerReview == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => SongReviewPage(song: widget.song, review: partnerReview),
                              ),
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

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }

  Widget _primaryGenrePill(GenreCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: category.gradient),
        borderRadius: BorderRadius.circular(999),
      ),
      child: GenreMixedText(
        text: category.mixedLabel,
        chineseFontFamily: category.chineseFontFamily,
        englishFontFamily: category.englishFontFamily,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12.2,
        ),
      ),
    );
  }

  Widget _subGenrePill(GenreCategory category, GenreSubTag subTag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: subTag.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: subTag.color.withValues(alpha: 0.3)),
      ),
      child: GenreMixedText(
        text: subTag.name,
        chineseFontFamily: category.chineseFontFamily,
        englishFontFamily: category.englishFontFamily,
        style: TextStyle(
          color: subTag.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

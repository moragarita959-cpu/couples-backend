import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/genre/genre_catalog.dart';
import '../widgets/genre_mixed_text.dart';
import 'song_detail_page.dart';

class TagSearchPage extends ConsumerStatefulWidget {
  const TagSearchPage({super.key});

  @override
  ConsumerState<TagSearchPage> createState() => _TagSearchPageState();
}

enum _SearchMode {
  tag,
  genre,
  all,
}

class _TagSearchPageState extends ConsumerState<TagSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  _SearchMode _mode = _SearchMode.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  bool _matchesGenre(Song song, String query) {
    final resolved = GenreCatalog.resolve(song.genre);
    final normalized = query.toLowerCase();
    final haystacks = <String>[
      resolved.category.name,
      resolved.category.englishName,
      resolved.category.mixedLabel,
      if (resolved.subTag != null) resolved.subTag!.name,
    ].map((e) => e.toLowerCase());
    return haystacks.any((value) => value.contains(normalized));
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(playlistControllerProvider.notifier);
    final state = ref.watch(playlistControllerProvider);

    final tagSuggestions = controller
        .allKnownTags()
        .where((tag) => _query.isEmpty || tag.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final genreSuggestions = GenreCatalog.categories
        .where((category) {
          if (_query.isEmpty) {
            return true;
          }
          final normalized = _query.toLowerCase();
          return category.name.toLowerCase().contains(normalized) ||
              category.englishName.toLowerCase().contains(normalized) ||
              category.children.any(
                (child) => child.name.toLowerCase().contains(normalized),
              );
        })
        .toList();

    final tagResults = controller.songsByTagQuery(_query);
    final genreResults = state.songs
        .where((song) => _query.isEmpty || _matchesGenre(song, _query))
        .toList();

    final results = switch (_mode) {
      _SearchMode.tag => tagResults,
      _SearchMode.genre => genreResults,
      _SearchMode.all => {
          ...<Song>[...tagResults, ...genreResults],
        }.toList(),
    };

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('标签与曲风检索'),
        backgroundColor: CoupleUi.surface,
      ),
      body: DecoratedBox(
        decoration: CoupleUi.pageBackgroundDecoration(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            SegmentedButton<_SearchMode>(
              segments: const <ButtonSegment<_SearchMode>>[
                ButtonSegment<_SearchMode>(
                  value: _SearchMode.all,
                  label: Text('全部'),
                ),
                ButtonSegment<_SearchMode>(
                  value: _SearchMode.tag,
                  label: Text('标签'),
                ),
                ButtonSegment<_SearchMode>(
                  value: _SearchMode.genre,
                  label: Text('曲风'),
                ),
              ],
              selected: <_SearchMode>{_mode},
              onSelectionChanged: (next) => setState(() => _mode = next.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _queryController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: CoupleUi.inputDecoration(
                labelText: '搜索标签或曲风',
                hintText: '支持模糊匹配，例如：通勤 / 古风 / J-Pop',
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if ((_mode == _SearchMode.all || _mode == _SearchMode.tag) &&
                tagSuggestions.isNotEmpty) ...<Widget>[
              const Text(
                '标签建议',
                style: TextStyle(
                  color: CoupleUi.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tagSuggestions
                    .map(
                      (tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          _queryController.text = tag;
                          setState(() => _query = tag);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if ((_mode == _SearchMode.all || _mode == _SearchMode.genre) &&
                genreSuggestions.isNotEmpty) ...<Widget>[
              const Text(
                '曲风建议',
                style: TextStyle(
                  color: CoupleUi.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genreSuggestions
                    .map(
                      (category) => ActionChip(
                        label: GenreMixedText(
                          text: category.mixedLabel,
                          chineseFontFamily: category.chineseFontFamily,
                          englishFontFamily: category.englishFontFamily,
                          style: const TextStyle(
                            fontSize: 12.2,
                            fontWeight: FontWeight.w700,
                            color: CoupleUi.textPrimary,
                          ),
                        ),
                        onPressed: () {
                          _queryController.text = category.name;
                          setState(() => _query = category.name);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              '结果 ${results.length} 首',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (_query.isEmpty)
              const Text(
                '输入标签或曲风后开始检索。',
                style: TextStyle(color: CoupleUi.textSecondary),
              )
            else if (results.isEmpty)
              const Text(
                '没有匹配歌曲',
                style: TextStyle(color: CoupleUi.textSecondary),
              )
            else
              ...results.map((song) => _ResultTile(song: song)),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final resolvedGenre = GenreCatalog.resolve(song.genre);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: CoupleUi.sectionCardDecoration(),
      child: ListTile(
        title: Text(song.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            GenreMixedText(
              text: resolvedGenre.subTag == null
                  ? resolvedGenre.category.mixedLabel
                  : '${resolvedGenre.category.name} ${resolvedGenre.subTag!.name}',
              chineseFontFamily: resolvedGenre.category.chineseFontFamily,
              englishFontFamily: resolvedGenre.category.englishFontFamily,
              style: TextStyle(
                color: resolvedGenre.category.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SongDetailPage(song: song),
            ),
          );
        },
      ),
    );
  }
}

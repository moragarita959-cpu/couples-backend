import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/genre/genre_catalog.dart';
import '../state/playlist_state.dart';
import '../widgets/genre_mixed_text.dart';
import '../widgets/playlist_card.dart';
import 'song_detail_page.dart';
import 'tag_search_page.dart';

class PlaylistPage extends ConsumerStatefulWidget {
  const PlaylistPage({super.key});

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage>
    with WidgetsBindingObserver {
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  String _selectedPrimaryGenreId = GenreCatalog.categories.first.id;
  String? _selectedSecondaryGenreId;
  String? _filterPrimaryGenreId;
  String? _filterSecondaryGenreId;

  Future<void> _refreshPlaylist() async {
    await ref.read(playlistControllerProvider.notifier).load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(playlistControllerProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _songNameController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.read(playlistControllerProvider.notifier).load();
    }
  }

  String _sortLabel(PlaylistSortMode mode) {
    switch (mode) {
      case PlaylistSortMode.time:
        return '按时间';
      case PlaylistSortMode.score:
        return '按评分';
      case PlaylistSortMode.alphabet:
        return '按字母';
    }
  }

  String _periodLabel(PlaylistRankingPeriod period) {
    switch (period) {
      case PlaylistRankingPeriod.week:
        return '周榜';
      case PlaylistRankingPeriod.month:
        return '月榜';
      case PlaylistRankingPeriod.year:
        return '年榜';
    }
  }

  String _scopeLabel(PlaylistRankingScope scope) {
    switch (scope) {
      case PlaylistRankingScope.total:
        return '总分';
      case PlaylistRankingScope.me:
        return '我';
      case PlaylistRankingScope.partner:
        return 'TA';
    }
  }

  List<Song> _filteredSongs(List<Song> songs) {
    return songs.where((song) {
      final resolved = GenreCatalog.resolve(song.genre);
      if (_filterPrimaryGenreId != null &&
          resolved.category.id != _filterPrimaryGenreId) {
        return false;
      }
      if (_filterSecondaryGenreId != null &&
          resolved.subTag?.id != _filterSecondaryGenreId) {
        return false;
      }
      return true;
    }).toList();
  }

  String _genreFilterLabel() {
    if (_filterPrimaryGenreId == null) {
      return '全部曲风';
    }
    final primary = GenreCatalog.categoryById(_filterPrimaryGenreId!);
    if (_filterSecondaryGenreId == null) {
      return primary.name;
    }
    GenreSubTag? secondary;
    for (final child in primary.children) {
      if (child.id == _filterSecondaryGenreId) {
        secondary = child;
        break;
      }
    }
    return secondary == null ? primary.name : '${primary.name} · ${secondary.name}';
  }

  Future<void> _showGenreFilterSheet() async {
    var selectedPrimaryId = _filterPrimaryGenreId;
    var selectedSecondaryId = _filterSecondaryGenreId;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedPrimary = selectedPrimaryId == null
                ? null
                : GenreCatalog.categoryById(selectedPrimaryId!);
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: CoupleUi.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: CoupleUi.softShadow,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            '曲风筛选',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: CoupleUi.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterPrimaryGenreId = null;
                              _filterSecondaryGenreId = null;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ChoiceChip(
                          label: const Text('全部'),
                          selected: selectedPrimaryId == null,
                          onSelected: (_) {
                            setSheetState(() {
                              selectedPrimaryId = null;
                              selectedSecondaryId = null;
                            });
                          },
                        ),
                        ...GenreCatalog.categories.map((category) {
                          final selected = selectedPrimaryId == category.id;
                          return ChoiceChip(
                            selected: selected,
                            selectedColor:
                                category.primaryColor.withValues(alpha: 0.18),
                            onSelected: (_) {
                              setSheetState(() {
                                selectedPrimaryId = selected ? null : category.id;
                                selectedSecondaryId = null;
                              });
                            },
                            label: GenreMixedText(
                              text: category.mixedLabel,
                              chineseFontFamily: category.chineseFontFamily,
                              englishFontFamily: category.englishFontFamily,
                              style: TextStyle(
                                color: selected
                                    ? category.primaryColor
                                    : CoupleUi.textPrimary,
                                fontSize: 12.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    if (selectedPrimary != null &&
                        selectedPrimary.children.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedPrimary.children.map((child) {
                          final selected = selectedSecondaryId == child.id;
                          return FilterChip(
                            selected: selected,
                            selectedColor: child.color.withValues(alpha: 0.14),
                            side: BorderSide(
                              color: selected
                                  ? child.color.withValues(alpha: 0.38)
                                  : CoupleUi.sectionBorder,
                            ),
                            onSelected: (_) {
                              setSheetState(() {
                                selectedSecondaryId = selected ? null : child.id;
                              });
                            },
                            label: GenreMixedText(
                              text: child.name,
                              chineseFontFamily: selectedPrimary.chineseFontFamily,
                              englishFontFamily: selectedPrimary.englishFontFamily,
                              style: TextStyle(
                                color: selected ? child.color : CoupleUi.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _filterPrimaryGenreId = selectedPrimaryId;
                            _filterSecondaryGenreId = selectedSecondaryId;
                          });
                          Navigator.of(context).pop();
                        },
                        style: CoupleUi.primaryButtonStyle(),
                        child: const Text('应用筛选'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddSongSheet() async {
    var selectedPrimaryId = _selectedPrimaryGenreId;
    var selectedSecondaryId = _selectedSecondaryGenreId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(playlistControllerProvider);
            final controller = ref.read(playlistControllerProvider.notifier);
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final primary = GenreCatalog.categoryById(selectedPrimaryId);
                final children = primary.children;

                Future<void> submit() async {
                  final genreValue =
                      GenreCatalog.encode(selectedPrimaryId, selectedSecondaryId);
                  final ok = await controller.addSong(
                    name: _songNameController.text,
                    artist: _artistController.text,
                    genre: genreValue,
                  );
                  if (!ok || !context.mounted) {
                    return;
                  }
                  _songNameController.clear();
                  _artistController.clear();
                  setState(() {
                    _selectedPrimaryGenreId = selectedPrimaryId;
                    _selectedSecondaryGenreId = selectedSecondaryId;
                  });
                  Navigator.of(context).pop();
                }

                return Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    decoration: BoxDecoration(
                      color: CoupleUi.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: CoupleUi.softShadow,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: Text(
                                  '添加一首歌',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: CoupleUi.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _songNameController,
                            textInputAction: TextInputAction.next,
                            decoration: CoupleUi.inputDecoration(labelText: '歌名'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _artistController,
                            textInputAction: TextInputAction.next,
                            decoration: CoupleUi.inputDecoration(labelText: '歌手'),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '一级曲风',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: CoupleUi.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: GenreCatalog.categories.map((category) {
                              final selected = selectedPrimaryId == category.id;
                              return ChoiceChip(
                                selected: selected,
                                onSelected: (_) {
                                  setSheetState(() {
                                    selectedPrimaryId = category.id;
                                    selectedSecondaryId = null;
                                  });
                                },
                                selectedColor:
                                    category.primaryColor.withValues(alpha: 0.18),
                                label: GenreMixedText(
                                  text: category.mixedLabel,
                                  chineseFontFamily: category.chineseFontFamily,
                                  englishFontFamily: category.englishFontFamily,
                                  style: TextStyle(
                                    color: selected
                                        ? category.primaryColor
                                        : CoupleUi.textPrimary,
                                    fontSize: 12.4,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              const Text(
                                '二级曲风',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: CoupleUi.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: selectedSecondaryId == null
                                    ? null
                                    : () => setSheetState(
                                          () => selectedSecondaryId = null,
                                        ),
                                child: const Text('仅使用一级'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (children.isEmpty)
                            const Text(
                              '当前一级曲风没有二级分类，可直接保存。',
                              style: TextStyle(color: CoupleUi.textSecondary),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: children.map((child) {
                                final selected = selectedSecondaryId == child.id;
                                return FilterChip(
                                  selected: selected,
                                  selectedColor:
                                      child.color.withValues(alpha: 0.14),
                                  side: BorderSide(
                                    color: selected
                                        ? child.color.withValues(alpha: 0.38)
                                        : CoupleUi.sectionBorder,
                                  ),
                                  onSelected: (_) {
                                    setSheetState(() {
                                      selectedSecondaryId =
                                          selected ? null : child.id;
                                    });
                                  },
                                  label: GenreMixedText(
                                    text: child.name,
                                    chineseFontFamily: primary.chineseFontFamily,
                                    englishFontFamily: primary.englishFontFamily,
                                    style: TextStyle(
                                      color: selected
                                          ? child.color
                                          : CoupleUi.textPrimary,
                                      fontSize: 12.1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          if (state.errorMessage != null &&
                              state.errorMessage!.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 10),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFC45A68),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state.isSubmittingSong ? null : submit,
                              style: CoupleUi.primaryButtonStyle(),
                              icon: state.isSubmittingSong
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.library_add_outlined),
                              label: Text(
                                state.isSubmittingSong ? '保存中...' : '保存到歌单',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRankingSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(playlistControllerProvider);
            final controller = ref.read(playlistControllerProvider.notifier);
            final entries = controller.rankingsFor(
              state.rankingPeriod,
              scope: state.rankingScope,
            );
            final eliteChips = <Song>[
              ...state.songs.where((song) => !song.isDeleted),
            ]..sort((a, b) {
                final byTime = a.createdAt.compareTo(b.createdAt);
                if (byTime != 0) {
                  return byTime;
                }
                return a.id.compareTo(b.id);
              });
            eliteChips.removeWhere(
              (song) => controller.totalScoreFor(song.id) < 28,
            );
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: CoupleUi.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: CoupleUi.softShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          '双人歌曲排行榜',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: CoupleUi.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<PlaylistRankingPeriod>(
                    segments: PlaylistRankingPeriod.values
                        .map(
                          (period) => ButtonSegment<PlaylistRankingPeriod>(
                            value: period,
                            label: Text(_periodLabel(period)),
                          ),
                        )
                        .toList(),
                    selected: <PlaylistRankingPeriod>{state.rankingPeriod},
                    onSelectionChanged: (next) {
                      controller.setRankingPeriod(next.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<PlaylistRankingScope>(
                    segments: PlaylistRankingScope.values
                        .map(
                          (scope) => ButtonSegment<PlaylistRankingScope>(
                            value: scope,
                            label: Text(_scopeLabel(scope)),
                          ),
                        )
                        .toList(),
                    selected: <PlaylistRankingScope>{state.rankingScope},
                    onSelectionChanged: (next) {
                      controller.setRankingScope(next.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  if (eliteChips.isNotEmpty) ...<Widget>[
                    const Text(
                      '高分展示（总分 ≥ 28）',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: CoupleUi.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final song in eliteChips)
                          Chip(
                            backgroundColor:
                                CoupleUi.primary.withValues(alpha: 0.14),
                            side: BorderSide.none,
                            label: Text(
                              '${CoupleUi.greekSymbolForIndex(controller.greekBadgeIndexForSong(song.id)!)} ${song.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Center(
                        child: Text(
                          '这个时间段还没有评分，先一起给喜欢的歌打个分吧。',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CoupleUi.textSecondary),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: ListView.separated(
                          key: ValueKey<String>(
                            '${state.rankingPeriod.name}-${state.rankingScope.name}',
                          ),
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 14),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final displayScore = switch (state.rankingScope) {
                              PlaylistRankingScope.total => entry.totalScore,
                              PlaylistRankingScope.me => entry.myScore,
                              PlaylistRankingScope.partner => entry.partnerScore,
                            };
                            final fullCombined =
                                controller.totalScoreFor(entry.song.id);
                            final greekIdx =
                                controller.greekBadgeIndexForSong(entry.song.id);
                            final color =
                                state.rankingScope == PlaylistRankingScope.total
                                    ? CoupleUi.scoreColorCombined31(displayScore)
                                    : CoupleUi.scoreColorForSingle(displayScore);
                            final trailingLabel =
                                fullCombined >= 28 && greekIdx != null
                                    ? CoupleUi.greekSymbolForIndex(greekIdx)
                                    : '${displayScore.toStringAsFixed(1)}分';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.14),
                                child: Text(
                                  '${entry.rank}',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              title: Text(
                                entry.song.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              subtitle: Text(
                                '${entry.song.artist} · 我 ${entry.myScore.toStringAsFixed(1)} / TA ${entry.partnerScore.toStringAsFixed(1)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                trailingLabel,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistControllerProvider);
    final controller = ref.read(playlistControllerProvider.notifier);
    final songs = _filteredSongs(controller.sortedSongs());
    final uploadOrdinals = controller.uploadOrdinalBySongId();

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('双人歌单'),
        backgroundColor: CoupleUi.surface,
        actions: <Widget>[
          PopupMenuButton<_PlaylistMenuAction>(
            tooltip: '更多',
            icon: const Icon(Icons.more_horiz),
            onSelected: (action) {
              switch (action) {
                case _PlaylistMenuAction.sortTime:
                  controller.setSortMode(PlaylistSortMode.time);
                case _PlaylistMenuAction.sortScore:
                  controller.setSortMode(PlaylistSortMode.score);
                case _PlaylistMenuAction.sortAlphabet:
                  controller.setSortMode(PlaylistSortMode.alphabet);
                case _PlaylistMenuAction.ranking:
                  _showRankingSheet();
                case _PlaylistMenuAction.tagSearch:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TagSearchPage(),
                    ),
                  );
                case _PlaylistMenuAction.genreFilter:
                  _showGenreFilterSheet();
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<_PlaylistMenuAction>>[
              PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.sortTime,
                child: _MenuRow(
                  label: '按时间',
                  selected: state.sortMode == PlaylistSortMode.time,
                ),
              ),
              PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.sortScore,
                child: _MenuRow(
                  label: '按评分',
                  selected: state.sortMode == PlaylistSortMode.score,
                ),
              ),
              PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.sortAlphabet,
                child: _MenuRow(
                  label: '按字母',
                  selected: state.sortMode == PlaylistSortMode.alphabet,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.genreFilter,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.tune_outlined),
                    const SizedBox(width: 10),
                    Expanded(child: Text('曲风筛选 · ${_genreFilterLabel()}')),
                  ],
                ),
              ),
              const PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.ranking,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.leaderboard_outlined),
                    SizedBox(width: 10),
                    Text('排行榜'),
                  ],
                ),
              ),
              const PopupMenuItem<_PlaylistMenuAction>(
                value: _PlaylistMenuAction.tagSearch,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search_outlined),
                    SizedBox(width: 10),
                    Text('标签与曲风检索'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSongSheet,
        backgroundColor: CoupleUi.primaryStrong,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: DecoratedBox(
        decoration: CoupleUi.pageBackgroundDecoration(),
        child: RefreshIndicator(
          onRefresh: _refreshPlaylist,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: songs.isEmpty ? 2 : songs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _ListHeader(
                  count: songs.length,
                  sortLabel: _sortLabel(state.sortMode),
                  errorMessage: state.errorMessage,
                );
              }
              if (songs.isEmpty) {
                return const _EmptyPlaylist();
              }

              final song = songs[index - 1];
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.95, end: 1),
                duration: Duration(
                  milliseconds: 120 + ((index - 1) * 25).clamp(0, 220),
                ),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: PlaylistCard(
                  song: song,
                  combinedTotal: controller.totalScoreFor(song.id),
                  uploadOrdinal: uploadOrdinals[song.id] ?? 1,
                  greekBadgeIndex: controller.greekBadgeIndexForSong(song.id),
                  onTap: () async {
                    final deleted = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => SongDetailPage(song: song),
                      ),
                    );
                    if (deleted == true && mounted) {
                      await controller.load();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.count,
    required this.sortLabel,
    required this.errorMessage,
  });

  final int count;
  final String sortLabel;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$count 首歌',
                  style: const TextStyle(
                    color: CoupleUi.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: CoupleUi.partner.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sortLabel,
                  style: const TextStyle(
                    color: CoupleUi.partner,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFFC45A68),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPlaylist extends StatelessWidget {
  const _EmptyPlaylist();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 34, 18, 34),
      decoration: CoupleUi.sectionCardDecoration(
        color: Colors.white.withValues(alpha: 0.88),
      ),
      child: const Column(
        children: <Widget>[
          Icon(Icons.queue_music_outlined, size: 42, color: CoupleUi.partner),
          SizedBox(height: 12),
          Text(
            '还没有歌曲',
            style: TextStyle(
              color: CoupleUi.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '点右下角 + 添加第一首，之后你们可以分别打分、写歌评和查看曲风细分标签。',
            textAlign: TextAlign.center,
            style: TextStyle(color: CoupleUi.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(selected ? Icons.check_circle : Icons.circle_outlined),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

enum _PlaylistMenuAction {
  sortTime,
  sortScore,
  sortAlphabet,
  genreFilter,
  ranking,
  tagSearch,
}

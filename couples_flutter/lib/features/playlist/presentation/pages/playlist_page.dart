import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/song_review.dart';
import '../widgets/playlist_card.dart';

class PlaylistPage extends ConsumerStatefulWidget {
  const PlaylistPage({super.key});

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage>
    with WidgetsBindingObserver {
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final Map<String, TextEditingController> _reviewControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _tagControllers =
      <String, TextEditingController>{};
  final Map<String, List<double>> _scoreDrafts = <String, List<double>>{};
  final Map<String, List<String>> _tagDrafts = <String, List<String>>{};
  bool _composerExpanded = false;

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
    for (final controller in _reviewControllers.values) {
      controller.dispose();
    }
    for (final controller in _tagControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.read(playlistControllerProvider.notifier).load();
    }
  }

  TextEditingController _reviewControllerFor(String songId) {
    return _reviewControllers.putIfAbsent(songId, TextEditingController.new);
  }

  TextEditingController _tagControllerFor(String songId) {
    return _tagControllers.putIfAbsent(songId, TextEditingController.new);
  }

  List<double> _scoreDraftFor(String songId) {
    return _scoreDrafts.putIfAbsent(songId, () => <double>[3, 3, 3]);
  }

  List<String> _tagDraftFor(String songId) {
    return _tagDrafts.putIfAbsent(songId, () => <String>[]);
  }

  SongReview? _reviewByAuthor(List<SongReview> reviews, ReviewAuthor author) {
    for (final review in reviews) {
      if (review.author == author) {
        return review;
      }
    }
    return null;
  }

  List<String> _combinedStyleTags(List<SongReview> reviews) {
    final tags = <String>[];
    for (final review in reviews) {
      for (final tag in review.styleTags) {
        if (tags.any((existing) => existing.toLowerCase() == tag.toLowerCase())) {
          continue;
        }
        tags.add(tag);
      }
    }
    return tags;
  }

  void _hydrateDraft({
    required String songId,
    required SongReview? myReview,
  }) {
    final reviewController = _reviewControllerFor(songId);
    if (myReview != null) {
      reviewController.text = myReview.content;
      _scoreDrafts[songId] = <double>[
        myReview.atmosphereScore.toDouble(),
        myReview.resonanceScore.toDouble(),
        myReview.shareScore.toDouble(),
      ];
      _tagDrafts[songId] = List<String>.from(myReview.styleTags);
    } else {
      reviewController.clear();
      _scoreDrafts[songId] = <double>[3, 3, 3];
      _tagDrafts[songId] = <String>[];
    }
    _tagControllerFor(songId).clear();
  }

  void _addTagToDraft(String songId, String rawTag) {
    final trimmed = rawTag.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final currentTags = List<String>.from(_tagDraftFor(songId));
    final exists = currentTags.any(
      (tag) => tag.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      _tagControllerFor(songId).clear();
      return;
    }

    setState(() {
      currentTags.add(trimmed);
      _tagDrafts[songId] = currentTags;
      _tagControllerFor(songId).clear();
    });
  }

  void _removeTagFromDraft(String songId, String tag) {
    setState(() {
      _tagDrafts[songId] = _tagDraftFor(songId)
          .where((item) => item.toLowerCase() != tag.toLowerCase())
          .toList();
    });
  }

  String _preferenceText(SongPreference preference) {
    switch (preference) {
      case SongPreference.like:
        return '喜欢';
      case SongPreference.dislike:
        return '暂时跳过';
      case SongPreference.none:
        return '待决定';
    }
  }

  Color _preferenceColor(SongPreference preference) {
    switch (preference) {
      case SongPreference.like:
        return const Color(0xFFDA7A8B);
      case SongPreference.dislike:
        return const Color(0xFF8D88A4);
      case SongPreference.none:
        return const Color(0xFF7C95CF);
    }
  }

  String _scoreTierText(int totalScore) {
    if (totalScore <= 5) {
      return '还在慢慢升温';
    }
    if (totalScore <= 10) {
      return '已经很合拍';
    }
    return '值得循环播放';
  }

  String _relationText(SongReview? myReview, SongReview? partnerReview) {
    if (myReview == null && partnerReview == null) {
      return '这首歌还没有人写下感受，不如先从它带给你的氛围开始。';
    }
    if (myReview != null && partnerReview == null) {
      return '你的乐评已经写好了，等 TA 回应后就能一起对照彼此的感受。';
    }
    if (myReview == null && partnerReview != null) {
      return 'TA 已经先写下了自己的感受，现在很适合补上你的这一面。';
    }
    final diff = (myReview!.totalScore - partnerReview!.totalScore).abs();
    if (diff <= 1) {
      return '你们对这首歌的感受非常接近，几乎落在同一个频率上。';
    }
    if (diff <= 3) {
      return '你们听到的重点略有不同，但整体氛围依然是靠近的。';
    }
    return '这首歌击中了你们不同的地方，这种反差也很值得聊一聊。';
  }

  Map<_PlaylistSection, List<Song>> _groupSongs(List<Song> songs) {
    return <_PlaylistSection, List<Song>>{
      _PlaylistSection.favorite: songs
          .where((song) => song.preference == SongPreference.like)
          .toList(),
      _PlaylistSection.undecided: songs
          .where((song) => song.preference == SongPreference.none)
          .toList(),
      _PlaylistSection.skipped: songs
          .where((song) => song.preference == SongPreference.dislike)
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistControllerProvider);
    final controller = ref.read(playlistControllerProvider.notifier);
    final groupedSongs = _groupSongs(state.songs);

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        title: const Text('双人歌单'),
        backgroundColor: CoupleUi.surface,
      ),
      body: DecoratedBox(
        decoration: CoupleUi.pageBackgroundDecoration(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ComposerEntry(
                expanded: _composerExpanded,
                songNameController: _songNameController,
                artistController: _artistController,
                onToggle: () {
                  setState(() {
                    _composerExpanded = !_composerExpanded;
                  });
                },
                onSubmit: () async {
                  final ok = await controller.addSong(
                    name: _songNameController.text,
                    artist: _artistController.text,
                  );
                  if (!ok) {
                    return;
                  }
                  _songNameController.clear();
                  _artistController.clear();
                  setState(() {
                    _composerExpanded = false;
                  });
                },
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPlaylist,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: _PlaylistSection.values
                        .map(
                          (section) => _PlaylistSectionCard(
                            title: section.title,
                            subtitle: section.subtitle,
                            count: groupedSongs[section]?.length ?? 0,
                            children: [
                              if ((groupedSongs[section] ?? const <Song>[]).isEmpty)
                                _EmptySectionHint(text: section.emptyHint),
                              ...(groupedSongs[section] ?? const <Song>[]).map((song) {
                              final reviews =
                                  state.reviewsBySongId[song.id] ?? const <SongReview>[];
                              final myReview =
                                  _reviewByAuthor(reviews, ReviewAuthor.me);
                              final partnerReview =
                                  _reviewByAuthor(reviews, ReviewAuthor.partner);
                              final isSelected = state.selectedSongId == song.id;
                              final hasDraftTags = _tagDrafts.containsKey(song.id);

                              if (isSelected &&
                                  !_scoreDrafts.containsKey(song.id) &&
                                  !_tagDrafts.containsKey(song.id)) {
                                _hydrateDraft(songId: song.id, myReview: myReview);
                              }

                              final scoreDraft = _scoreDraftFor(song.id);
                              final tagDraft = _tagDraftFor(song.id);
                              final draftTotal =
                                  (scoreDraft[0] + scoreDraft[1] + scoreDraft[2]).round();
                              final heroTotal = myReview?.totalScore ?? draftTotal;

                              return PlaylistCard(
                                song: song,
                                expanded: isSelected,
                                preferenceLabel: _preferenceText(song.preference),
                                preferenceColor: _preferenceColor(song.preference),
                                reviewCountLabel: '${reviews.length} 条乐评',
                                previewTags: isSelected && hasDraftTags
                                    ? tagDraft
                                    : _combinedStyleTags(reviews),
                                myReview: myReview,
                                partnerReview: partnerReview,
                                relationText: _relationText(myReview, partnerReview),
                                totalScore: heroTotal,
                                scoreTierText: _scoreTierText(heroTotal),
                                scoreValues: scoreDraft,
                                reviewController: _reviewControllerFor(song.id),
                                tagController: _tagControllerFor(song.id),
                                onExpandToggle: () async {
                                  if (isSelected) {
                                    controller.selectSong(null);
                                    return;
                                  }
                                  await controller.loadReviews(song.id);
                                  final latestReviews = ref
                                          .read(playlistControllerProvider)
                                          .reviewsBySongId[song.id] ??
                                      reviews;
                                  _hydrateDraft(
                                    songId: song.id,
                                    myReview: _reviewByAuthor(
                                      latestReviews,
                                      ReviewAuthor.me,
                                    ),
                                  );
                                  controller.selectSong(song.id);
                                },
                                onLike: () {
                                  controller.togglePreference(
                                    song.id,
                                    SongPreference.like,
                                  );
                                },
                                onDislike: () {
                                  controller.togglePreference(
                                    song.id,
                                    SongPreference.dislike,
                                  );
                                },
                                onScoreChanged: (index, value) {
                                  setState(() {
                                    scoreDraft[index] = value;
                                  });
                                },
                                onSubmitReview: () async {
                                  final ok = await controller.addOrUpdateReview(
                                    songId: song.id,
                                    content: _reviewControllerFor(song.id).text,
                                    styleTags: tagDraft,
                                    atmosphereScore: scoreDraft[0].round(),
                                    resonanceScore: scoreDraft[1].round(),
                                    shareScore: scoreDraft[2].round(),
                                  );
                                  if (!ok) {
                                    return;
                                  }
                                  await controller.loadReviews(song.id);
                                  final latestMyReview = _reviewByAuthor(
                                    ref
                                            .read(playlistControllerProvider)
                                            .reviewsBySongId[song.id] ??
                                        const <SongReview>[],
                                    ReviewAuthor.me,
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    if (latestMyReview != null) {
                                      _tagDrafts[song.id] =
                                          List<String>.from(latestMyReview.styleTags);
                                    }
                                  });
                                },
                                onAddTag: () {
                                  _addTagToDraft(
                                    song.id,
                                    _tagControllerFor(song.id).text,
                                  );
                                },
                                onRemoveTag: (tag) {
                                  _removeTagFromDraft(song.id, tag);
                                },
                                onSuggestionTap: (tag) {
                                  _addTagToDraft(song.id, tag);
                                },
                              );
                              }),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerEntry extends StatelessWidget {
  const _ComposerEntry({
    required this.expanded,
    required this.songNameController,
    required this.artistController,
    required this.onToggle,
    required this.onSubmit,
  });

  final bool expanded;
  final TextEditingController songNameController;
  final TextEditingController artistController;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: CoupleUi.sectionCardDecoration(
        color: CoupleUi.surfaceMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.queue_music_outlined,
                size: 18,
                color: Color(0xFF746B89),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '往你们的共享歌单里加一首歌',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF584F6E),
                  ),
                ),
              ),
              TextButton(
                onPressed: onToggle,
                child: Text(expanded ? '收起' : '展开'),
              ),
            ],
          ),
          if (expanded) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: songNameController,
                    decoration: CoupleUi.inputDecoration(labelText: '歌名'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: artistController,
                    decoration: CoupleUi.inputDecoration(labelText: '歌手'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onSubmit,
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('保存歌曲'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaylistSectionCard extends StatelessWidget {
  const _PlaylistSectionCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.children,
  });

  final String title;
  final String subtitle;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: CoupleUi.sectionCardDecoration(
        color: const Color(0xFFFCFBFD),
      ),
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF302A40),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF716B81),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF665C7E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _EmptySectionHint extends StatelessWidget {
  const _EmptySectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: CoupleUi.nestedCardDecoration(),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF716B80),
          height: 1.4,
        ),
      ),
    );
  }
}

enum _PlaylistSection {
  favorite(
    title: '一起喜欢',
    subtitle: '已经被你们默契点亮的歌。',
    emptyHint: '把那些让你们觉得温柔、安心、想循环的歌放进这里。',
  ),
  undecided(
    title: '待决定',
    subtitle: '新加入、还在感受中的歌。',
    emptyHint: '新歌会先落在这里，等你们慢慢写下第一反应。',
  ),
  skipped(
    title: '暂时跳过',
    subtitle: '这阶段还没有被击中的歌。',
    emptyHint: '今天没感觉也没关系，先放在这里，之后随时还能再听。',
  );

  const _PlaylistSection({
    required this.title,
    required this.subtitle,
    required this.emptyHint,
  });

  final String title;
  final String subtitle;
  final String emptyHint;
}

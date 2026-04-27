import '../../domain/entities/excerpt_note.dart';
import '../../domain/entities/idea_note.dart';

enum ThoughtsSection { ideas, excerpts }

enum IdeaFilter { all, mood, idea, wish }

enum ExcerptFilter { all, book, movie, lyric, custom }

class ThoughtsHomeState {
  const ThoughtsHomeState({
    this.ideas = const <IdeaNote>[],
    this.excerpts = const <ExcerptNote>[],
    this.section = ThoughtsSection.ideas,
    this.ideaFilter = IdeaFilter.all,
    this.excerptFilter = ExcerptFilter.all,
    this.isLoading = true,
    this.isSaving = false,
    this.isSearchVisible = false,
    this.isQuickCreateOpen = false,
    this.ideaQuery = '',
    this.excerptQuery = '',
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final List<IdeaNote> ideas;
  final List<ExcerptNote> excerpts;
  final ThoughtsSection section;
  final IdeaFilter ideaFilter;
  final ExcerptFilter excerptFilter;
  final bool isLoading;
  final bool isSaving;
  final bool isSearchVisible;
  final bool isQuickCreateOpen;
  final String ideaQuery;
  final String excerptQuery;
  final String? errorMessage;
  final String? cloudSyncMessage;

  List<IdeaNote> get filteredIdeas {
    Iterable<IdeaNote> result = ideas;
    switch (ideaFilter) {
      case IdeaFilter.mood:
        result = result.where((item) => item.type == IdeaNote.typeMood);
        break;
      case IdeaFilter.idea:
        result = result.where((item) => item.type == IdeaNote.typeIdea);
        break;
      case IdeaFilter.wish:
        result = result.where((item) => item.type == IdeaNote.typeWish);
        break;
      case IdeaFilter.all:
        break;
    }
    final query = ideaQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return result.toList();
    }
    return result.where((item) {
      if ((item.title ?? '').toLowerCase().contains(query)) {
        return true;
      }
      if (item.content.toLowerCase().contains(query)) {
        return true;
      }
      for (final tag in item.moodTags) {
        if (tag.toLowerCase().contains(query)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List<ExcerptNote> get filteredExcerpts {
    Iterable<ExcerptNote> result = excerpts;
    switch (excerptFilter) {
      case ExcerptFilter.book:
        result = result.where((item) => item.category == ExcerptNote.categoryBook);
        break;
      case ExcerptFilter.movie:
        result = result.where((item) => item.category == ExcerptNote.categoryMovie);
        break;
      case ExcerptFilter.lyric:
        result = result.where((item) => item.category == ExcerptNote.categoryLyric);
        break;
      case ExcerptFilter.custom:
        result = result.where((item) => item.category == ExcerptNote.categoryCustom);
        break;
      case ExcerptFilter.all:
        break;
    }
    final query = excerptQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return result.toList();
    }
    return result.where((item) {
      return item.quoteText.toLowerCase().contains(query) ||
          (item.sourceTitle ?? '').toLowerCase().contains(query) ||
          (item.sourceAuthor ?? '').toLowerCase().contains(query) ||
          (item.sourceDetail ?? '').toLowerCase().contains(query) ||
          (item.personalNote ?? '').toLowerCase().contains(query);
    }).toList();
  }

  ThoughtsHomeState copyWith({
    List<IdeaNote>? ideas,
    List<ExcerptNote>? excerpts,
    ThoughtsSection? section,
    IdeaFilter? ideaFilter,
    ExcerptFilter? excerptFilter,
    bool? isLoading,
    bool? isSaving,
    bool? isSearchVisible,
    bool? isQuickCreateOpen,
    String? ideaQuery,
    String? excerptQuery,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return ThoughtsHomeState(
      ideas: ideas ?? this.ideas,
      excerpts: excerpts ?? this.excerpts,
      section: section ?? this.section,
      ideaFilter: ideaFilter ?? this.ideaFilter,
      excerptFilter: excerptFilter ?? this.excerptFilter,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      isQuickCreateOpen: isQuickCreateOpen ?? this.isQuickCreateOpen,
      ideaQuery: ideaQuery ?? this.ideaQuery,
      excerptQuery: excerptQuery ?? this.excerptQuery,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

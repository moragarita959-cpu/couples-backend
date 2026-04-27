import '../../domain/entities/idea_note.dart';

/// In-memory draft for the idea creation/edit flow. Carried as `extra`
/// between the edit page and the preview page so the preview can finalise
/// the colour + sticker before the controller actually writes to Drift.
class IdeaDraft {
  const IdeaDraft({
    required this.type,
    required this.title,
    required this.content,
    required this.moodTags,
    required this.colorStyle,
    required this.layoutStyle,
    this.ideaId,
    this.stickerStyle,
  });

  final String? ideaId;
  final String type;
  final String title;
  final String content;
  final List<String> moodTags;
  final String colorStyle;
  final String layoutStyle;
  final String? stickerStyle;

  IdeaDraft copyWith({
    String? type,
    String? title,
    String? content,
    List<String>? moodTags,
    String? colorStyle,
    String? layoutStyle,
    Object? stickerStyle = _noChange,
  }) {
    return IdeaDraft(
      ideaId: ideaId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      moodTags: moodTags ?? this.moodTags,
      colorStyle: colorStyle ?? this.colorStyle,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      stickerStyle: identical(stickerStyle, _noChange)
          ? this.stickerStyle
          : stickerStyle as String?,
    );
  }

  /// Build a transient `IdeaNote` for previewing in the existing card widgets
  /// without touching the database.
  IdeaNote toPreviewIdea({
    required String coupleId,
    required String authorUserId,
  }) {
    final now = DateTime.now();
    return IdeaNote(
      id: ideaId ?? 'idea-preview',
      coupleId: coupleId,
      authorUserId: authorUserId,
      type: type,
      title: title.trim().isEmpty ? null : title.trim(),
      content: content.trim().isEmpty
          ? '今天有一点想法，想先轻轻写在这里。'
          : content.trim(),
      moodTags: moodTags,
      colorStyle: colorStyle,
      layoutStyle: layoutStyle,
      stickerStyle: stickerStyle,
      createdAt: now,
      updatedAt: now,
    );
  }

  static const Object _noChange = Object();
}

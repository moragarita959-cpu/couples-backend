import '../../domain/entities/excerpt_note.dart';

/// In-memory draft for the excerpt creation/edit flow. The edit page only
/// captures text fields; card style + colour scheme live on the preview page.
class ExcerptDraft {
  const ExcerptDraft({
    required this.category,
    required this.quoteText,
    required this.sourceTitle,
    required this.sourceAuthor,
    required this.sourceDetail,
    required this.personalNote,
    required this.cardStyle,
    required this.colorStyle,
    this.excerptId,
  });

  final String? excerptId;
  final String category;
  final String quoteText;
  final String sourceTitle;
  final String sourceAuthor;
  final String sourceDetail;
  final String personalNote;
  final String cardStyle;
  final String colorStyle;

  ExcerptDraft copyWith({
    String? category,
    String? quoteText,
    String? sourceTitle,
    String? sourceAuthor,
    String? sourceDetail,
    String? personalNote,
    String? cardStyle,
    String? colorStyle,
  }) {
    return ExcerptDraft(
      excerptId: excerptId,
      category: category ?? this.category,
      quoteText: quoteText ?? this.quoteText,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      sourceAuthor: sourceAuthor ?? this.sourceAuthor,
      sourceDetail: sourceDetail ?? this.sourceDetail,
      personalNote: personalNote ?? this.personalNote,
      cardStyle: cardStyle ?? this.cardStyle,
      colorStyle: colorStyle ?? this.colorStyle,
    );
  }

  ExcerptNote toPreviewExcerpt({
    required String coupleId,
    required String authorUserId,
  }) {
    final now = DateTime.now();
    return ExcerptNote(
      id: excerptId ?? 'excerpt-preview',
      coupleId: coupleId,
      authorUserId: authorUserId,
      category: category,
      quoteText: quoteText.trim(),
      sourceTitle: sourceTitle.trim().isEmpty ? null : sourceTitle.trim(),
      sourceAuthor: sourceAuthor.trim().isEmpty ? null : sourceAuthor.trim(),
      sourceDetail: sourceDetail.trim().isEmpty ? null : sourceDetail.trim(),
      personalNote: personalNote.trim().isEmpty ? null : personalNote.trim(),
      cardStyle: cardStyle,
      colorStyle: colorStyle,
      createdAt: now,
      updatedAt: now,
    );
  }
}

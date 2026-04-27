import '../../domain/entities/excerpt_note.dart';
import '../../domain/entities/thought_comment.dart';

class ExcerptDetailState {
  const ExcerptDetailState({
    this.excerpt,
    this.comments = const <ThoughtComment>[],
    this.isLoading = true,
    this.isSendingComment = false,
    this.isUpdatingStyle = false,
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final ExcerptNote? excerpt;
  final List<ThoughtComment> comments;
  final bool isLoading;
  final bool isSendingComment;
  final bool isUpdatingStyle;
  final String? errorMessage;
  final String? cloudSyncMessage;

  ExcerptDetailState copyWith({
    Object? excerpt = _noChange,
    List<ThoughtComment>? comments,
    bool? isLoading,
    bool? isSendingComment,
    bool? isUpdatingStyle,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return ExcerptDetailState(
      excerpt: identical(excerpt, _noChange)
          ? this.excerpt
          : excerpt as ExcerptNote?,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSendingComment: isSendingComment ?? this.isSendingComment,
      isUpdatingStyle: isUpdatingStyle ?? this.isUpdatingStyle,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

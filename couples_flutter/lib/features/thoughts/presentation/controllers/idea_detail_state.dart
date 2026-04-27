import '../../domain/entities/idea_note.dart';
import '../../domain/entities/thought_comment.dart';

class IdeaDetailState {
  const IdeaDetailState({
    this.idea,
    this.comments = const <ThoughtComment>[],
    this.isLoading = true,
    this.isSendingComment = false,
    this.errorMessage,
    this.cloudSyncMessage,
  });

  static const Object _noChange = Object();

  final IdeaNote? idea;
  final List<ThoughtComment> comments;
  final bool isLoading;
  final bool isSendingComment;
  final String? errorMessage;
  final String? cloudSyncMessage;

  IdeaDetailState copyWith({
    Object? idea = _noChange,
    List<ThoughtComment>? comments,
    bool? isLoading,
    bool? isSendingComment,
    Object? errorMessage = _noChange,
    Object? cloudSyncMessage = _noChange,
  }) {
    return IdeaDetailState(
      idea: identical(idea, _noChange) ? this.idea : idea as IdeaNote?,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSendingComment: isSendingComment ?? this.isSendingComment,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      cloudSyncMessage: identical(cloudSyncMessage, _noChange)
          ? this.cloudSyncMessage
          : cloudSyncMessage as String?,
    );
  }
}

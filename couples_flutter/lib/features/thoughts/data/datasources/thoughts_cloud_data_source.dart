import '../../../../core/network/api_client.dart';
import '../models/excerpt_note_dto.dart';
import '../models/idea_note_dto.dart';
import '../models/thought_comment_dto.dart';

class ThoughtsCloudDataSource {
  const ThoughtsCloudDataSource(this._apiClient, this._resolveCurrentUserId);

  final ApiClient _apiClient;
  final String? Function() _resolveCurrentUserId;

  bool get isEnabled => _apiClient.usesHttpBackend;

  Future<List<IdeaNoteDto>> listIdeaNotes({
    required String coupleId,
    DateTime? since,
  }) async {
    final currentUserId = _resolveCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return const <IdeaNoteDto>[];
    }
    final payload = await _apiClient.listIdeaNotes(
      coupleId: coupleId,
      currentUserId: currentUserId,
      since: since,
    );
    return payload.map(IdeaNoteDto.fromCloudJson).toList();
  }

  Future<IdeaNoteDto> upsertIdeaNote(IdeaNoteDto note) async {
    final currentUserId = _resolveCurrentUserId();
    final payload = await _apiClient.upsertIdeaNote(<String, dynamic>{
      ...note.toCloudJson(),
      'currentUserId': currentUserId,
    });
    return IdeaNoteDto.fromCloudJson(payload);
  }

  Future<void> deleteIdeaNote({
    required String coupleId,
    required String ideaId,
  }) {
    final currentUserId = _resolveCurrentUserId() ?? '';
    return _apiClient.deleteIdeaNote(
      coupleId: coupleId,
      currentUserId: currentUserId,
      ideaId: ideaId,
    );
  }

  Future<List<ExcerptNoteDto>> listExcerptNotes({
    required String coupleId,
    DateTime? since,
  }) async {
    final currentUserId = _resolveCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return const <ExcerptNoteDto>[];
    }
    final payload = await _apiClient.listExcerptNotes(
      coupleId: coupleId,
      currentUserId: currentUserId,
      since: since,
    );
    return payload.map(ExcerptNoteDto.fromCloudJson).toList();
  }

  Future<ExcerptNoteDto> upsertExcerptNote(ExcerptNoteDto note) async {
    final currentUserId = _resolveCurrentUserId();
    final payload = await _apiClient.upsertExcerptNote(<String, dynamic>{
      ...note.toCloudJson(),
      'currentUserId': currentUserId,
    });
    return ExcerptNoteDto.fromCloudJson(payload);
  }

  Future<void> deleteExcerptNote({
    required String coupleId,
    required String excerptId,
  }) {
    final currentUserId = _resolveCurrentUserId() ?? '';
    return _apiClient.deleteExcerptNote(
      coupleId: coupleId,
      currentUserId: currentUserId,
      excerptId: excerptId,
    );
  }

  Future<List<ThoughtCommentDto>> listThoughtComments({
    required String coupleId,
    required String targetType,
    required String targetId,
  }) async {
    final currentUserId = _resolveCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return const <ThoughtCommentDto>[];
    }
    final payload = await _apiClient.listThoughtComments(
      coupleId: coupleId,
      currentUserId: currentUserId,
      targetType: targetType,
      targetId: targetId,
    );
    return payload.map(ThoughtCommentDto.fromCloudJson).toList();
  }

  Future<ThoughtCommentDto> upsertThoughtComment(ThoughtCommentDto comment) async {
    final currentUserId = _resolveCurrentUserId();
    final payload = await _apiClient.upsertThoughtComment(<String, dynamic>{
      ...comment.toCloudJson(),
      'currentUserId': currentUserId,
    });
    return ThoughtCommentDto.fromCloudJson(payload);
  }

  Future<void> deleteThoughtComment({
    required String coupleId,
    required String commentId,
  }) {
    final currentUserId = _resolveCurrentUserId() ?? '';
    return _apiClient.deleteThoughtComment(
      coupleId: coupleId,
      currentUserId: currentUserId,
      commentId: commentId,
    );
  }
}

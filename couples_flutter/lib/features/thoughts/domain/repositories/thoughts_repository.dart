import '../entities/excerpt_note.dart';
import '../entities/idea_note.dart';
import '../entities/thought_comment.dart';

abstract class ThoughtsRepository {
  Stream<List<IdeaNote>> watchIdeaNotes(String coupleId);
  Stream<IdeaNote?> watchIdeaNote(String ideaId);
  Future<List<IdeaNote>> refreshIdeaNotes();
  Future<IdeaNote> saveIdeaNote(IdeaNote note);
  Future<void> deleteIdeaNote(String ideaId);

  Stream<List<ExcerptNote>> watchExcerptNotes(String coupleId);
  Stream<ExcerptNote?> watchExcerptNote(String excerptId);
  Future<List<ExcerptNote>> refreshExcerptNotes();
  Future<ExcerptNote> saveExcerptNote(ExcerptNote note);
  Future<void> deleteExcerptNote(String excerptId);

  Stream<List<ThoughtComment>> watchThoughtComments(
    String targetType,
    String targetId,
  );
  Future<List<ThoughtComment>> refreshThoughtComments(
    String targetType,
    String targetId,
  );
  Future<ThoughtComment> saveThoughtComment(ThoughtComment comment);
  Future<void> deleteThoughtComment(String commentId);

  String? takeCloudSyncWarning();
}

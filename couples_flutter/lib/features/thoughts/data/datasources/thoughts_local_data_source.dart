import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../../domain/entities/thought_comment.dart';
import '../models/excerpt_note_dto.dart';
import '../models/idea_note_dto.dart';
import '../models/thought_comment_dto.dart';

class ThoughtsLocalDataSource {
  const ThoughtsLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<IdeaNoteDto>> watchIdeaNotes(String coupleId) {
    final query = _db.select(_db.ideaNotesTable)
      ..where((t) => t.coupleId.equals(coupleId))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      return Future.wait(rows.map(_hydrateIdeaNote));
    });
  }

  Stream<IdeaNoteDto?> watchIdeaNote(String ideaId) {
    final query = _db.select(_db.ideaNotesTable)
      ..where((t) => t.id.equals(ideaId))
      ..limit(1);
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) {
        return null;
      }
      return _hydrateIdeaNote(row);
    });
  }

  Future<IdeaNoteDto> upsertIdeaNote(IdeaNoteDto note) async {
    await _db.into(_db.ideaNotesTable).insertOnConflictUpdate(note.toCompanion());
    return (await getIdeaNote(note.id))!;
  }

  Future<void> replaceIdeaNotes(String coupleId, List<IdeaNoteDto> notes) async {
    if (notes.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      for (final note in notes) {
        await _db.into(_db.ideaNotesTable).insertOnConflictUpdate(
              note.toCompanion(),
            );
      }
    });
  }

  Future<void> deleteIdeaNote(String ideaId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.thoughtCommentsTable)
            ..where(
              (t) =>
                  t.targetType.equals(ThoughtComment.targetTypeIdea) &
                  t.targetId.equals(ideaId),
            ))
          .go();
      await (_db.delete(_db.ideaNotesTable)..where((t) => t.id.equals(ideaId))).go();
    });
  }

  Stream<List<ExcerptNoteDto>> watchExcerptNotes(String coupleId) {
    final query = _db.select(_db.excerptNotesTable)
      ..where((t) => t.coupleId.equals(coupleId))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      return Future.wait(rows.map(_hydrateExcerptNote));
    });
  }

  Stream<ExcerptNoteDto?> watchExcerptNote(String excerptId) {
    final query = _db.select(_db.excerptNotesTable)
      ..where((t) => t.id.equals(excerptId))
      ..limit(1);
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) {
        return null;
      }
      return _hydrateExcerptNote(row);
    });
  }

  Future<ExcerptNoteDto> upsertExcerptNote(ExcerptNoteDto note) async {
    await _db.into(_db.excerptNotesTable).insertOnConflictUpdate(note.toCompanion());
    return (await getExcerptNote(note.id))!;
  }

  Future<void> replaceExcerptNotes(
    String coupleId,
    List<ExcerptNoteDto> notes,
  ) async {
    if (notes.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      for (final note in notes) {
        await _db.into(_db.excerptNotesTable).insertOnConflictUpdate(
              note.toCompanion(),
            );
      }
    });
  }

  Future<void> deleteExcerptNote(String excerptId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.thoughtCommentsTable)
            ..where(
              (t) =>
                  t.targetType.equals(ThoughtComment.targetTypeExcerpt) &
                  t.targetId.equals(excerptId),
            ))
          .go();
      await (_db.delete(_db.excerptNotesTable)
            ..where((t) => t.id.equals(excerptId)))
          .go();
    });
  }

  Stream<List<ThoughtCommentDto>> watchThoughtComments(
    String targetType,
    String targetId,
  ) {
    final query = _db.select(_db.thoughtCommentsTable)
      ..where((t) => t.targetType.equals(targetType) & t.targetId.equals(targetId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map(
      (rows) => rows.map(ThoughtCommentDto.fromRow).toList(),
    );
  }

  Future<ThoughtCommentDto> upsertThoughtComment(ThoughtCommentDto comment) async {
    await _db.into(_db.thoughtCommentsTable).insertOnConflictUpdate(
          comment.toCompanion(),
        );
    return (await getThoughtComment(comment.id))!;
  }

  Future<void> replaceThoughtComments(
    String targetType,
    String targetId,
    List<ThoughtCommentDto> comments,
  ) async {
    if (comments.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      for (final comment in comments) {
        await _db.into(_db.thoughtCommentsTable).insertOnConflictUpdate(
              comment.toCompanion(),
            );
      }
    });
  }

  Future<void> deleteThoughtComment(String commentId) async {
    await (_db.delete(_db.thoughtCommentsTable)..where((t) => t.id.equals(commentId)))
        .go();
  }

  Future<IdeaNoteDto?> getIdeaNote(String ideaId) async {
    final row = await (_db.select(_db.ideaNotesTable)
          ..where((t) => t.id.equals(ideaId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrateIdeaNote(row);
  }

  Future<ExcerptNoteDto?> getExcerptNote(String excerptId) async {
    final row = await (_db.select(_db.excerptNotesTable)
          ..where((t) => t.id.equals(excerptId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrateExcerptNote(row);
  }

  Future<ThoughtCommentDto?> getThoughtComment(String commentId) async {
    final row = await (_db.select(_db.thoughtCommentsTable)
          ..where((t) => t.id.equals(commentId))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : ThoughtCommentDto.fromRow(row);
  }

  Future<IdeaNoteDto> _hydrateIdeaNote(IdeaNotesTableData row) async {
    final countExp = _db.thoughtCommentsTable.id.count();
    final commentRow = await (_db.selectOnly(_db.thoughtCommentsTable)
          ..addColumns([countExp])
          ..where(
            _db.thoughtCommentsTable.targetType.equals(
                  ThoughtComment.targetTypeIdea,
                ) &
                _db.thoughtCommentsTable.targetId.equals(row.id),
          ))
        .getSingle();
    return IdeaNoteDto.fromRow(row, commentCount: commentRow.read(countExp) ?? 0);
  }

  Future<ExcerptNoteDto> _hydrateExcerptNote(ExcerptNotesTableData row) async {
    final countExp = _db.thoughtCommentsTable.id.count();
    final commentRow = await (_db.selectOnly(_db.thoughtCommentsTable)
          ..addColumns([countExp])
          ..where(
            _db.thoughtCommentsTable.targetType.equals(
                  ThoughtComment.targetTypeExcerpt,
                ) &
                _db.thoughtCommentsTable.targetId.equals(row.id),
          ))
        .getSingle();
    return ExcerptNoteDto.fromRow(
      row,
      commentCount: commentRow.read(countExp) ?? 0,
    );
  }
}

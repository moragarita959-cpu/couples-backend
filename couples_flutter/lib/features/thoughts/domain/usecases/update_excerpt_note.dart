import '../entities/excerpt_note.dart';
import '../repositories/thoughts_repository.dart';

class UpdateExcerptNote {
  const UpdateExcerptNote(this._repository);

  final ThoughtsRepository _repository;

  Future<ExcerptNote> call(ExcerptNote note) => _repository.saveExcerptNote(note);
}

import '../entities/excerpt_note.dart';
import '../repositories/thoughts_repository.dart';

class CreateExcerptNote {
  const CreateExcerptNote(this._repository);

  final ThoughtsRepository _repository;

  Future<ExcerptNote> call(ExcerptNote note) => _repository.saveExcerptNote(note);
}

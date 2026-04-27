import '../entities/excerpt_note.dart';
import '../repositories/thoughts_repository.dart';

class RefreshExcerptNotes {
  const RefreshExcerptNotes(this._repository);

  final ThoughtsRepository _repository;

  Future<List<ExcerptNote>> call() => _repository.refreshExcerptNotes();
}

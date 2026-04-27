import '../entities/excerpt_note.dart';
import '../repositories/thoughts_repository.dart';

class WatchExcerptNotes {
  const WatchExcerptNotes(this._repository);

  final ThoughtsRepository _repository;

  Stream<List<ExcerptNote>> call(String coupleId) =>
      _repository.watchExcerptNotes(coupleId);
}

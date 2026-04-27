import '../entities/excerpt_note.dart';
import '../repositories/thoughts_repository.dart';

class WatchExcerptNote {
  const WatchExcerptNote(this._repository);

  final ThoughtsRepository _repository;

  Stream<ExcerptNote?> call(String excerptId) =>
      _repository.watchExcerptNote(excerptId);
}

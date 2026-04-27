import '../entities/idea_note.dart';
import '../repositories/thoughts_repository.dart';

class WatchIdeaNote {
  const WatchIdeaNote(this._repository);

  final ThoughtsRepository _repository;

  Stream<IdeaNote?> call(String ideaId) => _repository.watchIdeaNote(ideaId);
}

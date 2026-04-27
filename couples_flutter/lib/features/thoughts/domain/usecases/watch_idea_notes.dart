import '../entities/idea_note.dart';
import '../repositories/thoughts_repository.dart';

class WatchIdeaNotes {
  const WatchIdeaNotes(this._repository);

  final ThoughtsRepository _repository;

  Stream<List<IdeaNote>> call(String coupleId) => _repository.watchIdeaNotes(coupleId);
}

import '../entities/idea_note.dart';
import '../repositories/thoughts_repository.dart';

class RefreshIdeaNotes {
  const RefreshIdeaNotes(this._repository);

  final ThoughtsRepository _repository;

  Future<List<IdeaNote>> call() => _repository.refreshIdeaNotes();
}

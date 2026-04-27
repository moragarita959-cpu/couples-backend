import '../entities/idea_note.dart';
import '../repositories/thoughts_repository.dart';

class CreateIdeaNote {
  const CreateIdeaNote(this._repository);

  final ThoughtsRepository _repository;

  Future<IdeaNote> call(IdeaNote note) => _repository.saveIdeaNote(note);
}

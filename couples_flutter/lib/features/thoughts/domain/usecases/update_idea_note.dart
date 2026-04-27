import '../entities/idea_note.dart';
import '../repositories/thoughts_repository.dart';

class UpdateIdeaNote {
  const UpdateIdeaNote(this._repository);

  final ThoughtsRepository _repository;

  Future<IdeaNote> call(IdeaNote note) => _repository.saveIdeaNote(note);
}

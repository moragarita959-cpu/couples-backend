import '../repositories/thoughts_repository.dart';

class DeleteIdeaNote {
  const DeleteIdeaNote(this._repository);

  final ThoughtsRepository _repository;

  Future<void> call(String ideaId) => _repository.deleteIdeaNote(ideaId);
}

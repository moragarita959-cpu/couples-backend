import '../repositories/thoughts_repository.dart';

class DeleteExcerptNote {
  const DeleteExcerptNote(this._repository);

  final ThoughtsRepository _repository;

  Future<void> call(String excerptId) => _repository.deleteExcerptNote(excerptId);
}

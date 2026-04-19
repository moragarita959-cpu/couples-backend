import '../repositories/countdown_repository.dart';

class DeleteCountdownEvent {
  const DeleteCountdownEvent(this._repository);

  final CountdownRepository _repository;

  Future<void> call({
    required String id,
    required String coupleId,
    required DateTime updatedAt,
  }) {
    return _repository.delete(
      id: id,
      coupleId: coupleId,
      updatedAt: updatedAt,
    );
  }
}

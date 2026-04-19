import '../repositories/chat_repository.dart';

class SyncMessages {
  const SyncMessages(this._repository);

  final ChatRepository _repository;

  Future<void> call({
    required String currentUserId,
    required String coupleId,
  }) {
    return _repository.syncMessages(
      currentUserId: currentUserId,
      coupleId: coupleId,
    );
  }
}

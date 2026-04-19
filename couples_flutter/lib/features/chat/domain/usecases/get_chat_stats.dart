import '../entities/chat_stats.dart';
import '../repositories/chat_repository.dart';

class GetChatStats {
  const GetChatStats(this._repository);

  final ChatRepository _repository;

  Future<ChatStats> call({
    required String currentUserId,
  }) {
    return _repository.getChatStats(currentUserId: currentUserId);
  }
}

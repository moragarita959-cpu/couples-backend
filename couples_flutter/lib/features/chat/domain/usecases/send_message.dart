import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  const SendMessage(this._repository);

  final ChatRepository _repository;

  Future<void> call({
    required String currentUserId,
    required String coupleId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  }) {
    return _repository.sendMessage(
      currentUserId: currentUserId,
      coupleId: coupleId,
      content: content,
      clientMessageId: clientMessageId,
      messageType: messageType,
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
    );
  }
}

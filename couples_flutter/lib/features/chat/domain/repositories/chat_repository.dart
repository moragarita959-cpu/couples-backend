import '../entities/chat_message.dart';
import '../entities/chat_stats.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages({required String currentUserId});

  Future<ChatStats> getChatStats({required String currentUserId});

  Future<void> syncMessages({
    required String currentUserId,
    required String coupleId,
  });

  Future<ChatMessage> createOptimisticMessage({
    required String currentUserId,
    required String coupleId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  });

  Future<void> sendMessage({
    required String currentUserId,
    required String coupleId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  });

  Future<void> discardOptimisticMessage({required String clientMessageId});

  Future<String> uploadImage({
    required String currentUserId,
    required String coupleId,
    required String sourcePath,
  });

  Future<String> uploadVoice({
    required String currentUserId,
    required String coupleId,
    required String sourcePath,
  });

  Future<void> setTypingStatus({
    required String currentUserId,
    required String coupleId,
    required bool isTyping,
  });

  Future<bool> getPartnerTypingStatus({
    required String currentUserId,
    required String coupleId,
  });
}

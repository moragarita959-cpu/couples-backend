import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/chat_message_model.dart';

class ChatCloudDataSource {
  const ChatCloudDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChatMessageModel>> listMessages({
    required String coupleId,
    required String currentUserId,
    DateTime? since,
  }) async {
    final payload = await _apiClient.listChatMessages(
      coupleId: coupleId,
      since: since,
    );
    return payload
        .map(
          (item) => ChatMessageModel.fromCloudJson(
            item,
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  Future<ChatMessageModel> sendMessage({
    required String coupleId,
    required String senderUserId,
    required String content,
    required String clientMessageId,
    required String currentUserId,
    required String messageType,
    String? mediaUrl,
    int? mediaDurationMs,
  }) async {
    final payload = await _apiClient.sendChatMessage(
      coupleId: coupleId,
      senderUserId: senderUserId,
      content: content,
      clientMessageId: clientMessageId,
      messageType: messageType,
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
    );
    return ChatMessageModel.fromCloudJson(
      payload,
      currentUserId: currentUserId,
    );
  }

  Future<String> uploadImage({
    required String coupleId,
    required String senderUserId,
    required File file,
  }) {
    return _apiClient.uploadChatImage(
      coupleId: coupleId,
      senderUserId: senderUserId,
      sourcePath: file.path,
    );
  }

  Future<String> uploadVoice({
    required String coupleId,
    required String senderUserId,
    required File file,
  }) {
    return _apiClient.uploadChatVoice(
      coupleId: coupleId,
      senderUserId: senderUserId,
      sourcePath: file.path,
    );
  }

  Future<void> setTypingStatus({
    required String coupleId,
    required String currentUserId,
    required bool isTyping,
  }) async {
    try {
      await _apiClient.setChatTypingStatus(
        coupleId: coupleId,
        userId: currentUserId,
        isTyping: isTyping,
      );
    } catch (_) {
      // 兼容未实现 typing 接口的旧后端，不影响文字聊天主链路。
    }
  }

  Future<bool> getPartnerTypingStatus({
    required String coupleId,
    required String currentUserId,
  }) async {
    try {
      return await _apiClient.getChatTypingStatus(
        coupleId: coupleId,
        currentUserId: currentUserId,
      );
    } catch (_) {
      return false;
    }
  }
}

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.sender,
    required super.timestamp,
    super.messageType,
    super.mediaUrl,
    super.mediaDurationMs,
    super.senderUserId,
    super.clientMessageId,
    super.isPending,
  });

  factory ChatMessageModel.optimistic({
    required String id,
    required String currentUserId,
    required String content,
    required String clientMessageId,
    required DateTime timestamp,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      sender: ChatSender.me,
      timestamp: timestamp,
      messageType: messageType,
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
      senderUserId: currentUserId,
      clientMessageId: clientMessageId,
      isPending: true,
    );
  }

  factory ChatMessageModel.fromCloudJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderUserId = json['senderUserId'] as String?;
    return ChatMessageModel(
      id: json['id'] as String,
      content: (json['content'] as String?) ?? '',
      sender: senderUserId == currentUserId
          ? ChatSender.me
          : ChatSender.partner,
      timestamp: DateTime.parse(json['createdAt'] as String),
      messageType: _messageTypeFromRaw(json['messageType'] as String?),
      mediaUrl: json['mediaUrl'] as String?,
      mediaDurationMs: _toInt(json['mediaDurationMs']),
      senderUserId: senderUserId,
      clientMessageId: json['clientMessageId'] as String?,
      isPending: false,
    );
  }

  static ChatMessageType _messageTypeFromRaw(String? raw) {
    switch (raw) {
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      default:
        return ChatMessageType.text;
    }
  }

  static int? _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}

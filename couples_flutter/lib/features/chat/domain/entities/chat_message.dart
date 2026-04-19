enum ChatSender { me, partner }

enum ChatMessageType { text, image, voice }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.messageType = ChatMessageType.text,
    this.mediaUrl,
    this.mediaDurationMs,
    this.senderUserId,
    this.clientMessageId,
    this.isPending = false,
  });

  final String id;
  final String content;
  final ChatSender sender;
  final DateTime timestamp;
  final ChatMessageType messageType;
  final String? mediaUrl;
  final int? mediaDurationMs;
  final String? senderUserId;
  final String? clientMessageId;
  final bool isPending;
}

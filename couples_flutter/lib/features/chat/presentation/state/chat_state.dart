import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stats.dart';

class ChatState {
  const ChatState({
    this.messages = const <ChatMessage>[],
    this.isLoading = true,
    this.isSending = false,
    this.needsBinding = false,
    this.partnerTyping = false,
    this.stats,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool needsBinding;
  final bool partnerTyping;
  final ChatStats? stats;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? needsBinding,
    bool? partnerTyping,
    ChatStats? stats,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      needsBinding: needsBinding ?? this.needsBinding,
      partnerTyping: partnerTyping ?? this.partnerTyping,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }
}

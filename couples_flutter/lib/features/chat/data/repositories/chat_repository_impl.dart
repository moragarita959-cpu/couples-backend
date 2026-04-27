import 'dart:io';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stats.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_cloud_data_source.dart';
import '../datasources/chat_mock_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._localDataSource, this._cloudDataSource);

  final ChatMockDataSource _localDataSource;
  final ChatCloudDataSource _cloudDataSource;

  @override
  Future<List<ChatMessage>> getMessages({required String currentUserId}) {
    return _localDataSource.getMessages(currentUserId: currentUserId);
  }

  @override
  Future<ChatStats> getChatStats({required String currentUserId}) async {
    final messages = await getMessages(currentUserId: currentUserId);
    return _calculateStats(messages);
  }

  @override
  Future<void> syncMessages({
    required String currentUserId,
    required String coupleId,
    DateTime? since,
  }) async {
    await _localDataSource.purgeLegacyMessages();
    try {
      final cloudMessages = await _cloudDataSource.listMessages(
        coupleId: coupleId,
        currentUserId: currentUserId,
        since: since,
      );
      if (cloudMessages.isEmpty) {
        return;
      }
      await _localDataSource.upsertMessages(
        cloudMessages,
        currentUserId: currentUserId,
      );
    } catch (_) {
      // Keep chat usable from local cache when cloud sync is unavailable.
    }
  }

  @override
  Future<ChatMessage> createOptimisticMessage({
    required String currentUserId,
    required String coupleId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  }) {
    return _localDataSource.cacheOptimisticMessage(
      currentUserId: currentUserId,
      content: content,
      clientMessageId: clientMessageId,
      messageType: messageType,
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
    );
  }

  @override
  Future<void> sendMessage({
    required String currentUserId,
    required String coupleId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  }) async {
    final message = await _cloudDataSource.sendMessage(
      coupleId: coupleId,
      senderUserId: currentUserId,
      content: content,
      clientMessageId: clientMessageId,
      currentUserId: currentUserId,
      messageType: _messageTypeToRaw(messageType),
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
    );
    await _localDataSource.upsertMessages(<ChatMessageModel>[
      message,
    ], currentUserId: currentUserId);
  }

  @override
  Future<void> discardOptimisticMessage({required String clientMessageId}) {
    return _localDataSource.discardOptimisticMessage(
      clientMessageId: clientMessageId,
    );
  }

  @override
  Future<String> uploadImage({
    required String currentUserId,
    required String coupleId,
    required String sourcePath,
  }) {
    return _cloudDataSource.uploadImage(
      coupleId: coupleId,
      senderUserId: currentUserId,
      file: File(sourcePath),
    );
  }

  @override
  Future<String> uploadVoice({
    required String currentUserId,
    required String coupleId,
    required String sourcePath,
  }) {
    return _cloudDataSource.uploadVoice(
      coupleId: coupleId,
      senderUserId: currentUserId,
      file: File(sourcePath),
    );
  }

  @override
  Future<void> setTypingStatus({
    required String currentUserId,
    required String coupleId,
    required bool isTyping,
  }) {
    return _cloudDataSource.setTypingStatus(
      coupleId: coupleId,
      currentUserId: currentUserId,
      isTyping: isTyping,
    );
  }

  @override
  Future<bool> getPartnerTypingStatus({
    required String currentUserId,
    required String coupleId,
  }) {
    return _cloudDataSource.getPartnerTypingStatus(
      coupleId: coupleId,
      currentUserId: currentUserId,
    );
  }

  ChatStats _calculateStats(List<ChatMessage> messages) {
    final totalMessages = messages.length;
    final dayMap = <DateTime, List<ChatMessage>>{};
    var meCharacterCount = 0;
    var partnerCharacterCount = 0;

    for (final message in messages) {
      final key = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );
      final dayMessages = dayMap.putIfAbsent(key, () => <ChatMessage>[]);
      dayMessages.add(message);

      final charCount = message.content.runes.length;
      if (message.sender == ChatSender.me) {
        meCharacterCount += charCount;
      } else {
        partnerCharacterCount += charCount;
      }
    }

    for (final dayMessages in dayMap.values) {
      dayMessages.sort((a, b) {
        final byTime = a.timestamp.compareTo(b.timestamp);
        if (byTime != 0) {
          return byTime;
        }
        return a.id.compareTo(b.id);
      });
    }

    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    var streakDays = 0;
    while (true) {
      final dayMessages = dayMap[cursor];
      if (dayMessages == null) {
        break;
      }
      final hasMe = dayMessages.any((m) => m.sender == ChatSender.me);
      final hasPartner = dayMessages.any((m) => m.sender == ChatSender.partner);
      if (!hasMe || !hasPartner) {
        break;
      }
      streakDays += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var meInitiativeDays = 0;
    var partnerInitiativeDays = 0;
    for (final dayMessages in dayMap.values) {
      if (dayMessages.isEmpty) {
        continue;
      }
      final first = dayMessages.first;
      if (first.sender == ChatSender.me) {
        meInitiativeDays += 1;
      } else {
        partnerInitiativeDays += 1;
      }
    }

    final effectiveDays = meInitiativeDays + partnerInitiativeDays;
    final meRatio = effectiveDays == 0 ? 0.0 : meInitiativeDays / effectiveDays;
    final partnerRatio = effectiveDays == 0
        ? 0.0
        : partnerInitiativeDays / effectiveDays;

    return ChatStats(
      totalMessages: totalMessages,
      streakDays: streakDays,
      meInitiativeRatio: meRatio,
      partnerInitiativeRatio: partnerRatio,
      totalCharacterCount: meCharacterCount + partnerCharacterCount,
      meCharacterCount: meCharacterCount,
      partnerCharacterCount: partnerCharacterCount,
    );
  }

  String _messageTypeToRaw(ChatMessageType type) {
    switch (type) {
      case ChatMessageType.image:
        return 'image';
      case ChatMessageType.voice:
        return 'voice';
      case ChatMessageType.text:
        return 'text';
    }
  }
}

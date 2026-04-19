import 'package:drift/drift.dart';

import '../../../../core/storage/drift/app_database.dart';
import '../models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';

class ChatMockDataSource {
  ChatMockDataSource(this._db);

  final AppDatabase _db;

  Future<List<ChatMessageModel>> getMessages({
    required String currentUserId,
  }) async {
    final rows =
        await (_db.select(_db.chatMessagesTable)..orderBy([
              (t) => OrderingTerm.asc(t.timestamp),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    return rows.map((row) => _rowToModel(row, currentUserId)).toList();
  }

  Future<void> purgeLegacyMessages() async {
    await (_db.delete(
      _db.chatMessagesTable,
    )..where((t) => t.senderUserId.isNull())).go();
  }

  Future<void> upsertMessages(
    List<ChatMessageModel> messages, {
    required String currentUserId,
  }) async {
    for (final message in messages) {
      await _upsertMessage(message, currentUserId: currentUserId);
    }
  }

  Future<ChatMessageModel> cacheOptimisticMessage({
    required String currentUserId,
    required String content,
    required String clientMessageId,
    ChatMessageType messageType = ChatMessageType.text,
    String? mediaUrl,
    int? mediaDurationMs,
  }) async {
    final message = ChatMessageModel.optimistic(
      id: 'local-$clientMessageId',
      currentUserId: currentUserId,
      content: content,
      clientMessageId: clientMessageId,
      timestamp: DateTime.now(),
      messageType: messageType,
      mediaUrl: mediaUrl,
      mediaDurationMs: mediaDurationMs,
    );
    await _upsertMessage(message, currentUserId: currentUserId);
    return message;
  }

  Future<void> discardOptimisticMessage({required String clientMessageId}) {
    return (_db.delete(_db.chatMessagesTable)..where(
          (t) =>
              t.clientMessageId.equals(clientMessageId) & t.id.like('local-%'),
        ))
        .go();
  }

  Future<void> _upsertMessage(
    ChatMessageModel message, {
    required String currentUserId,
  }) async {
    final existingById = await (_db.select(
      _db.chatMessagesTable,
    )..where((t) => t.id.equals(message.id))).getSingleOrNull();

    if (existingById != null) {
      await (_db.update(
        _db.chatMessagesTable,
      )..where((t) => t.id.equals(message.id))).write(
        ChatMessagesTableCompanion(
          content: Value<String>(message.content),
          sender: Value<String>(_senderToDbValue(message.sender)),
          senderUserId: Value<String?>(message.senderUserId),
          clientMessageId: Value<String?>(message.clientMessageId),
          messageType: Value<String>(_messageTypeToDbValue(message.messageType)),
          mediaUrl: Value<String?>(message.mediaUrl),
          mediaDurationMs: Value<int?>(message.mediaDurationMs),
          timestamp: Value<DateTime>(message.timestamp),
        ),
      );
      return;
    }

    if (message.clientMessageId != null &&
        message.clientMessageId!.isNotEmpty) {
      final existingByClientId =
          await (_db.select(_db.chatMessagesTable)..where(
                (t) => t.clientMessageId.equals(message.clientMessageId!),
              ))
              .getSingleOrNull();

      if (existingByClientId != null) {
        await (_db.update(
          _db.chatMessagesTable,
        )..where((t) => t.id.equals(existingByClientId.id))).write(
          ChatMessagesTableCompanion(
            id: Value<String>(message.id),
            content: Value<String>(message.content),
            sender: Value<String>(_senderToDbValue(message.sender)),
            senderUserId: Value<String?>(message.senderUserId),
            clientMessageId: Value<String?>(message.clientMessageId),
            messageType: Value<String>(_messageTypeToDbValue(message.messageType)),
            mediaUrl: Value<String?>(message.mediaUrl),
            mediaDurationMs: Value<int?>(message.mediaDurationMs),
            timestamp: Value<DateTime>(message.timestamp),
          ),
        );
        return;
      }
    }

    await _db
        .into(_db.chatMessagesTable)
        .insert(
          ChatMessagesTableCompanion.insert(
            id: message.id,
            content: message.content,
            sender: _senderToDbValue(message.sender),
            senderUserId: Value<String?>(message.senderUserId),
            clientMessageId: Value<String?>(message.clientMessageId),
            messageType: Value<String>(_messageTypeToDbValue(message.messageType)),
            mediaUrl: Value<String?>(message.mediaUrl),
            mediaDurationMs: Value<int?>(message.mediaDurationMs),
            timestamp: message.timestamp,
          ),
        );
  }

  ChatMessageModel _rowToModel(
    ChatMessagesTableData row,
    String currentUserId,
  ) {
    final sender = row.senderUserId != null
        ? (row.senderUserId == currentUserId
              ? ChatSender.me
              : ChatSender.partner)
        : _senderFromDbValue(row.sender);

    return ChatMessageModel(
      id: row.id,
      content: row.content,
      sender: sender,
      timestamp: row.timestamp,
      messageType: _messageTypeFromDbValue(row.messageType),
      mediaUrl: row.mediaUrl,
      mediaDurationMs: row.mediaDurationMs,
      senderUserId: row.senderUserId,
      clientMessageId: row.clientMessageId,
      isPending: row.id.startsWith('local-'),
    );
  }

  String _senderToDbValue(ChatSender sender) {
    return sender == ChatSender.me ? 'me' : 'partner';
  }

  ChatSender _senderFromDbValue(String value) {
    return value == 'partner' ? ChatSender.partner : ChatSender.me;
  }

  String _messageTypeToDbValue(ChatMessageType type) {
    switch (type) {
      case ChatMessageType.image:
        return 'image';
      case ChatMessageType.voice:
        return 'voice';
      case ChatMessageType.text:
        return 'text';
    }
  }

  ChatMessageType _messageTypeFromDbValue(String value) {
    switch (value) {
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      default:
        return ChatMessageType.text;
    }
  }
}

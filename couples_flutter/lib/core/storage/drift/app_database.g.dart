// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatMessagesTableTable extends ChatMessagesTable
    with TableInfo<$ChatMessagesTableTable, ChatMessagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderUserIdMeta = const VerificationMeta(
    'senderUserId',
  );
  @override
  late final GeneratedColumn<String> senderUserId = GeneratedColumn<String>(
    'sender_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaDurationMsMeta = const VerificationMeta(
    'mediaDurationMs',
  );
  @override
  late final GeneratedColumn<int> mediaDurationMs = GeneratedColumn<int>(
    'media_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    sender,
    senderUserId,
    clientMessageId,
    messageType,
    mediaUrl,
    mediaDurationMs,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('sender_user_id')) {
      context.handle(
        _senderUserIdMeta,
        senderUserId.isAcceptableOrUnknown(
          data['sender_user_id']!,
          _senderUserIdMeta,
        ),
      );
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        clientMessageId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    }
    if (data.containsKey('media_duration_ms')) {
      context.handle(
        _mediaDurationMsMeta,
        mediaDurationMs.isAcceptableOrUnknown(
          data['media_duration_ms']!,
          _mediaDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      senderUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_user_id'],
      ),
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      ),
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      mediaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_url'],
      ),
      mediaDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_duration_ms'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $ChatMessagesTableTable createAlias(String alias) {
    return $ChatMessagesTableTable(attachedDatabase, alias);
  }
}

class ChatMessagesTableData extends DataClass
    implements Insertable<ChatMessagesTableData> {
  final String id;
  final String content;
  final String sender;
  final String? senderUserId;
  final String? clientMessageId;
  final String messageType;
  final String? mediaUrl;
  final int? mediaDurationMs;
  final DateTime timestamp;
  const ChatMessagesTableData({
    required this.id,
    required this.content,
    required this.sender,
    this.senderUserId,
    this.clientMessageId,
    required this.messageType,
    this.mediaUrl,
    this.mediaDurationMs,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['sender'] = Variable<String>(sender);
    if (!nullToAbsent || senderUserId != null) {
      map['sender_user_id'] = Variable<String>(senderUserId);
    }
    if (!nullToAbsent || clientMessageId != null) {
      map['client_message_id'] = Variable<String>(clientMessageId);
    }
    map['message_type'] = Variable<String>(messageType);
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    if (!nullToAbsent || mediaDurationMs != null) {
      map['media_duration_ms'] = Variable<int>(mediaDurationMs);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ChatMessagesTableCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesTableCompanion(
      id: Value(id),
      content: Value(content),
      sender: Value(sender),
      senderUserId: senderUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderUserId),
      clientMessageId: clientMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMessageId),
      messageType: Value(messageType),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      mediaDurationMs: mediaDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaDurationMs),
      timestamp: Value(timestamp),
    );
  }

  factory ChatMessagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessagesTableData(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      sender: serializer.fromJson<String>(json['sender']),
      senderUserId: serializer.fromJson<String?>(json['senderUserId']),
      clientMessageId: serializer.fromJson<String?>(json['clientMessageId']),
      messageType: serializer.fromJson<String>(json['messageType']),
      mediaUrl: serializer.fromJson<String?>(json['mediaUrl']),
      mediaDurationMs: serializer.fromJson<int?>(json['mediaDurationMs']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'sender': serializer.toJson<String>(sender),
      'senderUserId': serializer.toJson<String?>(senderUserId),
      'clientMessageId': serializer.toJson<String?>(clientMessageId),
      'messageType': serializer.toJson<String>(messageType),
      'mediaUrl': serializer.toJson<String?>(mediaUrl),
      'mediaDurationMs': serializer.toJson<int?>(mediaDurationMs),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ChatMessagesTableData copyWith({
    String? id,
    String? content,
    String? sender,
    Value<String?> senderUserId = const Value.absent(),
    Value<String?> clientMessageId = const Value.absent(),
    String? messageType,
    Value<String?> mediaUrl = const Value.absent(),
    Value<int?> mediaDurationMs = const Value.absent(),
    DateTime? timestamp,
  }) => ChatMessagesTableData(
    id: id ?? this.id,
    content: content ?? this.content,
    sender: sender ?? this.sender,
    senderUserId: senderUserId.present ? senderUserId.value : this.senderUserId,
    clientMessageId: clientMessageId.present
        ? clientMessageId.value
        : this.clientMessageId,
    messageType: messageType ?? this.messageType,
    mediaUrl: mediaUrl.present ? mediaUrl.value : this.mediaUrl,
    mediaDurationMs: mediaDurationMs.present
        ? mediaDurationMs.value
        : this.mediaDurationMs,
    timestamp: timestamp ?? this.timestamp,
  );
  ChatMessagesTableData copyWithCompanion(ChatMessagesTableCompanion data) {
    return ChatMessagesTableData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      sender: data.sender.present ? data.sender.value : this.sender,
      senderUserId: data.senderUserId.present
          ? data.senderUserId.value
          : this.senderUserId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      mediaDurationMs: data.mediaDurationMs.present
          ? data.mediaDurationMs.value
          : this.mediaDurationMs,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesTableData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('sender: $sender, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('messageType: $messageType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaDurationMs: $mediaDurationMs, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    sender,
    senderUserId,
    clientMessageId,
    messageType,
    mediaUrl,
    mediaDurationMs,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessagesTableData &&
          other.id == this.id &&
          other.content == this.content &&
          other.sender == this.sender &&
          other.senderUserId == this.senderUserId &&
          other.clientMessageId == this.clientMessageId &&
          other.messageType == this.messageType &&
          other.mediaUrl == this.mediaUrl &&
          other.mediaDurationMs == this.mediaDurationMs &&
          other.timestamp == this.timestamp);
}

class ChatMessagesTableCompanion
    extends UpdateCompanion<ChatMessagesTableData> {
  final Value<String> id;
  final Value<String> content;
  final Value<String> sender;
  final Value<String?> senderUserId;
  final Value<String?> clientMessageId;
  final Value<String> messageType;
  final Value<String?> mediaUrl;
  final Value<int?> mediaDurationMs;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatMessagesTableCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.sender = const Value.absent(),
    this.senderUserId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.messageType = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaDurationMs = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesTableCompanion.insert({
    required String id,
    required String content,
    required String sender,
    this.senderUserId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.messageType = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaDurationMs = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       sender = Value(sender),
       timestamp = Value(timestamp);
  static Insertable<ChatMessagesTableData> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? sender,
    Expression<String>? senderUserId,
    Expression<String>? clientMessageId,
    Expression<String>? messageType,
    Expression<String>? mediaUrl,
    Expression<int>? mediaDurationMs,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (sender != null) 'sender': sender,
      if (senderUserId != null) 'sender_user_id': senderUserId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (messageType != null) 'message_type': messageType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaDurationMs != null) 'media_duration_ms': mediaDurationMs,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<String>? sender,
    Value<String?>? senderUserId,
    Value<String?>? clientMessageId,
    Value<String>? messageType,
    Value<String?>? mediaUrl,
    Value<int?>? mediaDurationMs,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return ChatMessagesTableCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      senderUserId: senderUserId ?? this.senderUserId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaDurationMs: mediaDurationMs ?? this.mediaDurationMs,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (senderUserId.present) {
      map['sender_user_id'] = Variable<String>(senderUserId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (mediaDurationMs.present) {
      map['media_duration_ms'] = Variable<int>(mediaDurationMs.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesTableCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('sender: $sender, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('messageType: $messageType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaDurationMs: $mediaDurationMs, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillRecordsTableTable extends BillRecordsTable
    with TableInfo<$BillRecordsTableTable, BillRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    coupleId,
    type,
    amount,
    category,
    note,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillRecordsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillRecordsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillRecordsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $BillRecordsTableTable createAlias(String alias) {
    return $BillRecordsTableTable(attachedDatabase, alias);
  }
}

class BillRecordsTableData extends DataClass
    implements Insertable<BillRecordsTableData> {
  final String id;
  final String coupleId;
  final String type;
  final double amount;
  final String category;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;
  const BillRecordsTableData({
    required this.id,
    required this.coupleId,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['couple_id'] = Variable<String>(coupleId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  BillRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return BillRecordsTableCompanion(
      id: Value(id),
      coupleId: Value(coupleId),
      type: Value(type),
      amount: Value(amount),
      category: Value(category),
      note: Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      pendingSync: Value(pendingSync),
    );
  }

  factory BillRecordsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillRecordsTableData(
      id: serializer.fromJson<String>(json['id']),
      coupleId: serializer.fromJson<String>(json['coupleId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'coupleId': serializer.toJson<String>(coupleId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  BillRecordsTableData copyWith({
    String? id,
    String? coupleId,
    String? type,
    double? amount,
    String? category,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) => BillRecordsTableData(
    id: id ?? this.id,
    coupleId: coupleId ?? this.coupleId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  BillRecordsTableData copyWithCompanion(BillRecordsTableCompanion data) {
    return BillRecordsTableData(
      id: data.id.present ? data.id.value : this.id,
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillRecordsTableData(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    coupleId,
    type,
    amount,
    category,
    note,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillRecordsTableData &&
          other.id == this.id &&
          other.coupleId == this.coupleId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.pendingSync == this.pendingSync);
}

class BillRecordsTableCompanion extends UpdateCompanion<BillRecordsTableData> {
  final Value<String> id;
  final Value<String> coupleId;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> category;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const BillRecordsTableCompanion({
    this.id = const Value.absent(),
    this.coupleId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillRecordsTableCompanion.insert({
    required String id,
    this.coupleId = const Value.absent(),
    required String type,
    required double amount,
    this.category = const Value.absent(),
    required String note,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       note = Value(note),
       createdAt = Value(createdAt);
  static Insertable<BillRecordsTableData> custom({
    Expression<String>? id,
    Expression<String>? coupleId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (coupleId != null) 'couple_id': coupleId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillRecordsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? coupleId,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? category,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return BillRecordsTableCompanion(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountdownEventsTableTable extends CountdownEventsTable
    with TableInfo<$CountdownEventsTableTable, CountdownEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountdownEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    coupleId,
    name,
    date,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countdown_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountdownEventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CountdownEventsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountdownEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $CountdownEventsTableTable createAlias(String alias) {
    return $CountdownEventsTableTable(attachedDatabase, alias);
  }
}

class CountdownEventsTableData extends DataClass
    implements Insertable<CountdownEventsTableData> {
  final String id;
  final String coupleId;
  final String name;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;
  const CountdownEventsTableData({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['couple_id'] = Variable<String>(coupleId);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  CountdownEventsTableCompanion toCompanion(bool nullToAbsent) {
    return CountdownEventsTableCompanion(
      id: Value(id),
      coupleId: Value(coupleId),
      name: Value(name),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      pendingSync: Value(pendingSync),
    );
  }

  factory CountdownEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountdownEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      coupleId: serializer.fromJson<String>(json['coupleId']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'coupleId': serializer.toJson<String>(coupleId),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  CountdownEventsTableData copyWith({
    String? id,
    String? coupleId,
    String? name,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) => CountdownEventsTableData(
    id: id ?? this.id,
    coupleId: coupleId ?? this.coupleId,
    name: name ?? this.name,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  CountdownEventsTableData copyWithCompanion(
    CountdownEventsTableCompanion data,
  ) {
    return CountdownEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountdownEventsTableData(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    coupleId,
    name,
    date,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountdownEventsTableData &&
          other.id == this.id &&
          other.coupleId == this.coupleId &&
          other.name == this.name &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.pendingSync == this.pendingSync);
}

class CountdownEventsTableCompanion
    extends UpdateCompanion<CountdownEventsTableData> {
  final Value<String> id;
  final Value<String> coupleId;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const CountdownEventsTableCompanion({
    this.id = const Value.absent(),
    this.coupleId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountdownEventsTableCompanion.insert({
    required String id,
    this.coupleId = const Value.absent(),
    required String name,
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       date = Value(date);
  static Insertable<CountdownEventsTableData> custom({
    Expression<String>? id,
    Expression<String>? coupleId,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (coupleId != null) 'couple_id': coupleId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountdownEventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? coupleId,
    Value<String>? name,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return CountdownEventsTableCompanion(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      name: name ?? this.name,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountdownEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PokeEventsTableTable extends PokeEventsTable
    with TableInfo<$PokeEventsTableTable, PokeEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokeEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sender, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poke_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokeEventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokeEventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokeEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PokeEventsTableTable createAlias(String alias) {
    return $PokeEventsTableTable(attachedDatabase, alias);
  }
}

class PokeEventsTableData extends DataClass
    implements Insertable<PokeEventsTableData> {
  final String id;
  final String sender;
  final String message;
  final DateTime createdAt;
  const PokeEventsTableData({
    required this.id,
    required this.sender,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PokeEventsTableCompanion toCompanion(bool nullToAbsent) {
    return PokeEventsTableCompanion(
      id: Value(id),
      sender: Value(sender),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory PokeEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokeEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PokeEventsTableData copyWith({
    String? id,
    String? sender,
    String? message,
    DateTime? createdAt,
  }) => PokeEventsTableData(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  PokeEventsTableData copyWithCompanion(PokeEventsTableCompanion data) {
    return PokeEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokeEventsTableData(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sender, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokeEventsTableData &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class PokeEventsTableCompanion extends UpdateCompanion<PokeEventsTableData> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> message;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PokeEventsTableCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokeEventsTableCompanion.insert({
    required String id,
    required String sender,
    required String message,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sender = Value(sender),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<PokeEventsTableData> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokeEventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sender,
    Value<String>? message,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PokeEventsTableCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokeEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedEventsTableTable extends FeedEventsTable
    with TableInfo<$FeedEventsTableTable, FeedEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorSideMeta = const VerificationMeta(
    'actorSide',
  );
  @override
  late final GeneratedColumn<String> actorSide = GeneratedColumn<String>(
    'actor_side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryTextMeta = const VerificationMeta(
    'summaryText',
  );
  @override
  late final GeneratedColumn<String> summaryText = GeneratedColumn<String>(
    'summary_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    actorSide,
    targetType,
    targetId,
    summaryText,
    createdAt,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedEventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('actor_side')) {
      context.handle(
        _actorSideMeta,
        actorSide.isAcceptableOrUnknown(data['actor_side']!, _actorSideMeta),
      );
    } else if (isInserting) {
      context.missing(_actorSideMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('summary_text')) {
      context.handle(
        _summaryTextMeta,
        summaryText.isAcceptableOrUnknown(
          data['summary_text']!,
          _summaryTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedEventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      actorSide: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_side'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      summaryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $FeedEventsTableTable createAlias(String alias) {
    return $FeedEventsTableTable(attachedDatabase, alias);
  }
}

class FeedEventsTableData extends DataClass
    implements Insertable<FeedEventsTableData> {
  final String id;
  final String eventType;
  final String actorSide;
  final String targetType;
  final String targetId;
  final String summaryText;
  final DateTime createdAt;
  final bool isRead;
  const FeedEventsTableData({
    required this.id,
    required this.eventType,
    required this.actorSide,
    required this.targetType,
    required this.targetId,
    required this.summaryText,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_type'] = Variable<String>(eventType);
    map['actor_side'] = Variable<String>(actorSide);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['summary_text'] = Variable<String>(summaryText);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  FeedEventsTableCompanion toCompanion(bool nullToAbsent) {
    return FeedEventsTableCompanion(
      id: Value(id),
      eventType: Value(eventType),
      actorSide: Value(actorSide),
      targetType: Value(targetType),
      targetId: Value(targetId),
      summaryText: Value(summaryText),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory FeedEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      actorSide: serializer.fromJson<String>(json['actorSide']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      summaryText: serializer.fromJson<String>(json['summaryText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventType': serializer.toJson<String>(eventType),
      'actorSide': serializer.toJson<String>(actorSide),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'summaryText': serializer.toJson<String>(summaryText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  FeedEventsTableData copyWith({
    String? id,
    String? eventType,
    String? actorSide,
    String? targetType,
    String? targetId,
    String? summaryText,
    DateTime? createdAt,
    bool? isRead,
  }) => FeedEventsTableData(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    actorSide: actorSide ?? this.actorSide,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    summaryText: summaryText ?? this.summaryText,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
  FeedEventsTableData copyWithCompanion(FeedEventsTableCompanion data) {
    return FeedEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      actorSide: data.actorSide.present ? data.actorSide.value : this.actorSide,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      summaryText: data.summaryText.present
          ? data.summaryText.value
          : this.summaryText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedEventsTableData(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('actorSide: $actorSide, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('summaryText: $summaryText, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventType,
    actorSide,
    targetType,
    targetId,
    summaryText,
    createdAt,
    isRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedEventsTableData &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.actorSide == this.actorSide &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.summaryText == this.summaryText &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class FeedEventsTableCompanion extends UpdateCompanion<FeedEventsTableData> {
  final Value<String> id;
  final Value<String> eventType;
  final Value<String> actorSide;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String> summaryText;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const FeedEventsTableCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.actorSide = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedEventsTableCompanion.insert({
    required String id,
    required String eventType,
    required String actorSide,
    required String targetType,
    required String targetId,
    required String summaryText,
    required DateTime createdAt,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventType = Value(eventType),
       actorSide = Value(actorSide),
       targetType = Value(targetType),
       targetId = Value(targetId),
       summaryText = Value(summaryText),
       createdAt = Value(createdAt);
  static Insertable<FeedEventsTableData> custom({
    Expression<String>? id,
    Expression<String>? eventType,
    Expression<String>? actorSide,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? summaryText,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (actorSide != null) 'actor_side': actorSide,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (summaryText != null) 'summary_text': summaryText,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedEventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? eventType,
    Value<String>? actorSide,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<String>? summaryText,
    Value<DateTime>? createdAt,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return FeedEventsTableCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      actorSide: actorSide ?? this.actorSide,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      summaryText: summaryText ?? this.summaryText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (actorSide.present) {
      map['actor_side'] = Variable<String>(actorSide.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (summaryText.present) {
      map['summary_text'] = Variable<String>(summaryText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('actorSide: $actorSide, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('summaryText: $summaryText, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserProfileTableTable extends LocalUserProfileTable
    with TableInfo<$LocalUserProfileTableTable, LocalUserProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairCodeMeta = const VerificationMeta(
    'pairCode',
  );
  @override
  late final GeneratedColumn<String> pairCode = GeneratedColumn<String>(
    'pair_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    nickname,
    pairCode,
    coupleId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('pair_code')) {
      context.handle(
        _pairCodeMeta,
        pairCode.isAcceptableOrUnknown(data['pair_code']!, _pairCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_pairCodeMeta);
    }
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalUserProfileTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserProfileTableData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      pairCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair_code'],
      )!,
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalUserProfileTableTable createAlias(String alias) {
    return $LocalUserProfileTableTable(attachedDatabase, alias);
  }
}

class LocalUserProfileTableData extends DataClass
    implements Insertable<LocalUserProfileTableData> {
  final String userId;
  final String nickname;
  final String pairCode;
  final String? coupleId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUserProfileTableData({
    required this.userId,
    required this.nickname,
    required this.pairCode,
    this.coupleId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['nickname'] = Variable<String>(nickname);
    map['pair_code'] = Variable<String>(pairCode);
    if (!nullToAbsent || coupleId != null) {
      map['couple_id'] = Variable<String>(coupleId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return LocalUserProfileTableCompanion(
      userId: Value(userId),
      nickname: Value(nickname),
      pairCode: Value(pairCode),
      coupleId: coupleId == null && nullToAbsent
          ? const Value.absent()
          : Value(coupleId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUserProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserProfileTableData(
      userId: serializer.fromJson<String>(json['userId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      pairCode: serializer.fromJson<String>(json['pairCode']),
      coupleId: serializer.fromJson<String?>(json['coupleId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'nickname': serializer.toJson<String>(nickname),
      'pairCode': serializer.toJson<String>(pairCode),
      'coupleId': serializer.toJson<String?>(coupleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUserProfileTableData copyWith({
    String? userId,
    String? nickname,
    String? pairCode,
    Value<String?> coupleId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalUserProfileTableData(
    userId: userId ?? this.userId,
    nickname: nickname ?? this.nickname,
    pairCode: pairCode ?? this.pairCode,
    coupleId: coupleId.present ? coupleId.value : this.coupleId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalUserProfileTableData copyWithCompanion(
    LocalUserProfileTableCompanion data,
  ) {
    return LocalUserProfileTableData(
      userId: data.userId.present ? data.userId.value : this.userId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      pairCode: data.pairCode.present ? data.pairCode.value : this.pairCode,
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileTableData(')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('pairCode: $pairCode, ')
          ..write('coupleId: $coupleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, nickname, pairCode, coupleId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserProfileTableData &&
          other.userId == this.userId &&
          other.nickname == this.nickname &&
          other.pairCode == this.pairCode &&
          other.coupleId == this.coupleId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUserProfileTableCompanion
    extends UpdateCompanion<LocalUserProfileTableData> {
  final Value<String> userId;
  final Value<String> nickname;
  final Value<String> pairCode;
  final Value<String?> coupleId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalUserProfileTableCompanion({
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.pairCode = const Value.absent(),
    this.coupleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserProfileTableCompanion.insert({
    required String userId,
    required String nickname,
    required String pairCode,
    this.coupleId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       nickname = Value(nickname),
       pairCode = Value(pairCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalUserProfileTableData> custom({
    Expression<String>? userId,
    Expression<String>? nickname,
    Expression<String>? pairCode,
    Expression<String>? coupleId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (pairCode != null) 'pair_code': pairCode,
      if (coupleId != null) 'couple_id': coupleId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserProfileTableCompanion copyWith({
    Value<String>? userId,
    Value<String>? nickname,
    Value<String>? pairCode,
    Value<String?>? coupleId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalUserProfileTableCompanion(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      pairCode: pairCode ?? this.pairCode,
      coupleId: coupleId ?? this.coupleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (pairCode.present) {
      map['pair_code'] = Variable<String>(pairCode.value);
    }
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserProfileTableCompanion(')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('pairCode: $pairCode, ')
          ..write('coupleId: $coupleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCoupleProfileTableTable extends LocalCoupleProfileTable
    with TableInfo<$LocalCoupleProfileTableTable, LocalCoupleProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCoupleProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentUserIdMeta = const VerificationMeta(
    'currentUserId',
  );
  @override
  late final GeneratedColumn<String> currentUserId = GeneratedColumn<String>(
    'current_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentUserNicknameMeta =
      const VerificationMeta('currentUserNickname');
  @override
  late final GeneratedColumn<String> currentUserNickname =
      GeneratedColumn<String>(
        'current_user_nickname',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _partnerUserIdMeta = const VerificationMeta(
    'partnerUserId',
  );
  @override
  late final GeneratedColumn<String> partnerUserId = GeneratedColumn<String>(
    'partner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNicknameMeta = const VerificationMeta(
    'partnerNickname',
  );
  @override
  late final GeneratedColumn<String> partnerNickname = GeneratedColumn<String>(
    'partner_nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    coupleId,
    currentUserId,
    currentUserNickname,
    partnerUserId,
    partnerNickname,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_couple_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCoupleProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coupleIdMeta);
    }
    if (data.containsKey('current_user_id')) {
      context.handle(
        _currentUserIdMeta,
        currentUserId.isAcceptableOrUnknown(
          data['current_user_id']!,
          _currentUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentUserIdMeta);
    }
    if (data.containsKey('current_user_nickname')) {
      context.handle(
        _currentUserNicknameMeta,
        currentUserNickname.isAcceptableOrUnknown(
          data['current_user_nickname']!,
          _currentUserNicknameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentUserNicknameMeta);
    }
    if (data.containsKey('partner_user_id')) {
      context.handle(
        _partnerUserIdMeta,
        partnerUserId.isAcceptableOrUnknown(
          data['partner_user_id']!,
          _partnerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partnerUserIdMeta);
    }
    if (data.containsKey('partner_nickname')) {
      context.handle(
        _partnerNicknameMeta,
        partnerNickname.isAcceptableOrUnknown(
          data['partner_nickname']!,
          _partnerNicknameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partnerNicknameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {coupleId};
  @override
  LocalCoupleProfileTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCoupleProfileTableData(
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      )!,
      currentUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_user_id'],
      )!,
      currentUserNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_user_nickname'],
      )!,
      partnerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_user_id'],
      )!,
      partnerNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_nickname'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalCoupleProfileTableTable createAlias(String alias) {
    return $LocalCoupleProfileTableTable(attachedDatabase, alias);
  }
}

class LocalCoupleProfileTableData extends DataClass
    implements Insertable<LocalCoupleProfileTableData> {
  final String coupleId;
  final String currentUserId;
  final String currentUserNickname;
  final String partnerUserId;
  final String partnerNickname;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalCoupleProfileTableData({
    required this.coupleId,
    required this.currentUserId,
    required this.currentUserNickname,
    required this.partnerUserId,
    required this.partnerNickname,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['couple_id'] = Variable<String>(coupleId);
    map['current_user_id'] = Variable<String>(currentUserId);
    map['current_user_nickname'] = Variable<String>(currentUserNickname);
    map['partner_user_id'] = Variable<String>(partnerUserId);
    map['partner_nickname'] = Variable<String>(partnerNickname);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalCoupleProfileTableCompanion toCompanion(bool nullToAbsent) {
    return LocalCoupleProfileTableCompanion(
      coupleId: Value(coupleId),
      currentUserId: Value(currentUserId),
      currentUserNickname: Value(currentUserNickname),
      partnerUserId: Value(partnerUserId),
      partnerNickname: Value(partnerNickname),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalCoupleProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCoupleProfileTableData(
      coupleId: serializer.fromJson<String>(json['coupleId']),
      currentUserId: serializer.fromJson<String>(json['currentUserId']),
      currentUserNickname: serializer.fromJson<String>(
        json['currentUserNickname'],
      ),
      partnerUserId: serializer.fromJson<String>(json['partnerUserId']),
      partnerNickname: serializer.fromJson<String>(json['partnerNickname']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coupleId': serializer.toJson<String>(coupleId),
      'currentUserId': serializer.toJson<String>(currentUserId),
      'currentUserNickname': serializer.toJson<String>(currentUserNickname),
      'partnerUserId': serializer.toJson<String>(partnerUserId),
      'partnerNickname': serializer.toJson<String>(partnerNickname),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalCoupleProfileTableData copyWith({
    String? coupleId,
    String? currentUserId,
    String? currentUserNickname,
    String? partnerUserId,
    String? partnerNickname,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalCoupleProfileTableData(
    coupleId: coupleId ?? this.coupleId,
    currentUserId: currentUserId ?? this.currentUserId,
    currentUserNickname: currentUserNickname ?? this.currentUserNickname,
    partnerUserId: partnerUserId ?? this.partnerUserId,
    partnerNickname: partnerNickname ?? this.partnerNickname,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalCoupleProfileTableData copyWithCompanion(
    LocalCoupleProfileTableCompanion data,
  ) {
    return LocalCoupleProfileTableData(
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      currentUserId: data.currentUserId.present
          ? data.currentUserId.value
          : this.currentUserId,
      currentUserNickname: data.currentUserNickname.present
          ? data.currentUserNickname.value
          : this.currentUserNickname,
      partnerUserId: data.partnerUserId.present
          ? data.partnerUserId.value
          : this.partnerUserId,
      partnerNickname: data.partnerNickname.present
          ? data.partnerNickname.value
          : this.partnerNickname,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCoupleProfileTableData(')
          ..write('coupleId: $coupleId, ')
          ..write('currentUserId: $currentUserId, ')
          ..write('currentUserNickname: $currentUserNickname, ')
          ..write('partnerUserId: $partnerUserId, ')
          ..write('partnerNickname: $partnerNickname, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    coupleId,
    currentUserId,
    currentUserNickname,
    partnerUserId,
    partnerNickname,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCoupleProfileTableData &&
          other.coupleId == this.coupleId &&
          other.currentUserId == this.currentUserId &&
          other.currentUserNickname == this.currentUserNickname &&
          other.partnerUserId == this.partnerUserId &&
          other.partnerNickname == this.partnerNickname &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCoupleProfileTableCompanion
    extends UpdateCompanion<LocalCoupleProfileTableData> {
  final Value<String> coupleId;
  final Value<String> currentUserId;
  final Value<String> currentUserNickname;
  final Value<String> partnerUserId;
  final Value<String> partnerNickname;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalCoupleProfileTableCompanion({
    this.coupleId = const Value.absent(),
    this.currentUserId = const Value.absent(),
    this.currentUserNickname = const Value.absent(),
    this.partnerUserId = const Value.absent(),
    this.partnerNickname = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCoupleProfileTableCompanion.insert({
    required String coupleId,
    required String currentUserId,
    required String currentUserNickname,
    required String partnerUserId,
    required String partnerNickname,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : coupleId = Value(coupleId),
       currentUserId = Value(currentUserId),
       currentUserNickname = Value(currentUserNickname),
       partnerUserId = Value(partnerUserId),
       partnerNickname = Value(partnerNickname),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCoupleProfileTableData> custom({
    Expression<String>? coupleId,
    Expression<String>? currentUserId,
    Expression<String>? currentUserNickname,
    Expression<String>? partnerUserId,
    Expression<String>? partnerNickname,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (coupleId != null) 'couple_id': coupleId,
      if (currentUserId != null) 'current_user_id': currentUserId,
      if (currentUserNickname != null)
        'current_user_nickname': currentUserNickname,
      if (partnerUserId != null) 'partner_user_id': partnerUserId,
      if (partnerNickname != null) 'partner_nickname': partnerNickname,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCoupleProfileTableCompanion copyWith({
    Value<String>? coupleId,
    Value<String>? currentUserId,
    Value<String>? currentUserNickname,
    Value<String>? partnerUserId,
    Value<String>? partnerNickname,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalCoupleProfileTableCompanion(
      coupleId: coupleId ?? this.coupleId,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserNickname: currentUserNickname ?? this.currentUserNickname,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      partnerNickname: partnerNickname ?? this.partnerNickname,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (currentUserId.present) {
      map['current_user_id'] = Variable<String>(currentUserId.value);
    }
    if (currentUserNickname.present) {
      map['current_user_nickname'] = Variable<String>(
        currentUserNickname.value,
      );
    }
    if (partnerUserId.present) {
      map['partner_user_id'] = Variable<String>(partnerUserId.value);
    }
    if (partnerNickname.present) {
      map['partner_nickname'] = Variable<String>(partnerNickname.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCoupleProfileTableCompanion(')
          ..write('coupleId: $coupleId, ')
          ..write('currentUserId: $currentUserId, ')
          ..write('currentUserNickname: $currentUserNickname, ')
          ..write('partnerUserId: $partnerUserId, ')
          ..write('partnerNickname: $partnerNickname, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipSettingsTableTable extends RelationshipSettingsTable
    with
        TableInfo<
          $RelationshipSettingsTableTable,
          RelationshipSettingsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('primary'),
  );
  static const VerificationMeta _loveStartDateMeta = const VerificationMeta(
    'loveStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> loveStartDate =
      GeneratedColumn<DateTime>(
        'love_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _loveDaysOverrideMeta = const VerificationMeta(
    'loveDaysOverride',
  );
  @override
  late final GeneratedColumn<int> loveDaysOverride = GeneratedColumn<int>(
    'love_days_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceEnabledMeta = const VerificationMeta(
    'distanceEnabled',
  );
  @override
  late final GeneratedColumn<bool> distanceEnabled = GeneratedColumn<bool>(
    'distance_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("distance_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distanceTextMeta = const VerificationMeta(
    'distanceText',
  );
  @override
  late final GeneratedColumn<String> distanceText = GeneratedColumn<String>(
    'distance_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loveStartDate,
    loveDaysOverride,
    distanceEnabled,
    distanceText,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationship_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('love_start_date')) {
      context.handle(
        _loveStartDateMeta,
        loveStartDate.isAcceptableOrUnknown(
          data['love_start_date']!,
          _loveStartDateMeta,
        ),
      );
    }
    if (data.containsKey('love_days_override')) {
      context.handle(
        _loveDaysOverrideMeta,
        loveDaysOverride.isAcceptableOrUnknown(
          data['love_days_override']!,
          _loveDaysOverrideMeta,
        ),
      );
    }
    if (data.containsKey('distance_enabled')) {
      context.handle(
        _distanceEnabledMeta,
        distanceEnabled.isAcceptableOrUnknown(
          data['distance_enabled']!,
          _distanceEnabledMeta,
        ),
      );
    }
    if (data.containsKey('distance_text')) {
      context.handle(
        _distanceTextMeta,
        distanceText.isAcceptableOrUnknown(
          data['distance_text']!,
          _distanceTextMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipSettingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      loveStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}love_start_date'],
      ),
      loveDaysOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}love_days_override'],
      ),
      distanceEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}distance_enabled'],
      )!,
      distanceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_text'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RelationshipSettingsTableTable createAlias(String alias) {
    return $RelationshipSettingsTableTable(attachedDatabase, alias);
  }
}

class RelationshipSettingsTableData extends DataClass
    implements Insertable<RelationshipSettingsTableData> {
  final String id;
  final DateTime? loveStartDate;
  final int? loveDaysOverride;
  final bool distanceEnabled;
  final String? distanceText;
  final DateTime updatedAt;
  const RelationshipSettingsTableData({
    required this.id,
    this.loveStartDate,
    this.loveDaysOverride,
    required this.distanceEnabled,
    this.distanceText,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || loveStartDate != null) {
      map['love_start_date'] = Variable<DateTime>(loveStartDate);
    }
    if (!nullToAbsent || loveDaysOverride != null) {
      map['love_days_override'] = Variable<int>(loveDaysOverride);
    }
    map['distance_enabled'] = Variable<bool>(distanceEnabled);
    if (!nullToAbsent || distanceText != null) {
      map['distance_text'] = Variable<String>(distanceText);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RelationshipSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return RelationshipSettingsTableCompanion(
      id: Value(id),
      loveStartDate: loveStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(loveStartDate),
      loveDaysOverride: loveDaysOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(loveDaysOverride),
      distanceEnabled: Value(distanceEnabled),
      distanceText: distanceText == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceText),
      updatedAt: Value(updatedAt),
    );
  }

  factory RelationshipSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      loveStartDate: serializer.fromJson<DateTime?>(json['loveStartDate']),
      loveDaysOverride: serializer.fromJson<int?>(json['loveDaysOverride']),
      distanceEnabled: serializer.fromJson<bool>(json['distanceEnabled']),
      distanceText: serializer.fromJson<String?>(json['distanceText']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'loveStartDate': serializer.toJson<DateTime?>(loveStartDate),
      'loveDaysOverride': serializer.toJson<int?>(loveDaysOverride),
      'distanceEnabled': serializer.toJson<bool>(distanceEnabled),
      'distanceText': serializer.toJson<String?>(distanceText),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RelationshipSettingsTableData copyWith({
    String? id,
    Value<DateTime?> loveStartDate = const Value.absent(),
    Value<int?> loveDaysOverride = const Value.absent(),
    bool? distanceEnabled,
    Value<String?> distanceText = const Value.absent(),
    DateTime? updatedAt,
  }) => RelationshipSettingsTableData(
    id: id ?? this.id,
    loveStartDate: loveStartDate.present
        ? loveStartDate.value
        : this.loveStartDate,
    loveDaysOverride: loveDaysOverride.present
        ? loveDaysOverride.value
        : this.loveDaysOverride,
    distanceEnabled: distanceEnabled ?? this.distanceEnabled,
    distanceText: distanceText.present ? distanceText.value : this.distanceText,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RelationshipSettingsTableData copyWithCompanion(
    RelationshipSettingsTableCompanion data,
  ) {
    return RelationshipSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      loveStartDate: data.loveStartDate.present
          ? data.loveStartDate.value
          : this.loveStartDate,
      loveDaysOverride: data.loveDaysOverride.present
          ? data.loveDaysOverride.value
          : this.loveDaysOverride,
      distanceEnabled: data.distanceEnabled.present
          ? data.distanceEnabled.value
          : this.distanceEnabled,
      distanceText: data.distanceText.present
          ? data.distanceText.value
          : this.distanceText,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipSettingsTableData(')
          ..write('id: $id, ')
          ..write('loveStartDate: $loveStartDate, ')
          ..write('loveDaysOverride: $loveDaysOverride, ')
          ..write('distanceEnabled: $distanceEnabled, ')
          ..write('distanceText: $distanceText, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    loveStartDate,
    loveDaysOverride,
    distanceEnabled,
    distanceText,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipSettingsTableData &&
          other.id == this.id &&
          other.loveStartDate == this.loveStartDate &&
          other.loveDaysOverride == this.loveDaysOverride &&
          other.distanceEnabled == this.distanceEnabled &&
          other.distanceText == this.distanceText &&
          other.updatedAt == this.updatedAt);
}

class RelationshipSettingsTableCompanion
    extends UpdateCompanion<RelationshipSettingsTableData> {
  final Value<String> id;
  final Value<DateTime?> loveStartDate;
  final Value<int?> loveDaysOverride;
  final Value<bool> distanceEnabled;
  final Value<String?> distanceText;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RelationshipSettingsTableCompanion({
    this.id = const Value.absent(),
    this.loveStartDate = const Value.absent(),
    this.loveDaysOverride = const Value.absent(),
    this.distanceEnabled = const Value.absent(),
    this.distanceText = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.loveStartDate = const Value.absent(),
    this.loveDaysOverride = const Value.absent(),
    this.distanceEnabled = const Value.absent(),
    this.distanceText = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<RelationshipSettingsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? loveStartDate,
    Expression<int>? loveDaysOverride,
    Expression<bool>? distanceEnabled,
    Expression<String>? distanceText,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loveStartDate != null) 'love_start_date': loveStartDate,
      if (loveDaysOverride != null) 'love_days_override': loveDaysOverride,
      if (distanceEnabled != null) 'distance_enabled': distanceEnabled,
      if (distanceText != null) 'distance_text': distanceText,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime?>? loveStartDate,
    Value<int?>? loveDaysOverride,
    Value<bool>? distanceEnabled,
    Value<String?>? distanceText,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RelationshipSettingsTableCompanion(
      id: id ?? this.id,
      loveStartDate: loveStartDate ?? this.loveStartDate,
      loveDaysOverride: loveDaysOverride ?? this.loveDaysOverride,
      distanceEnabled: distanceEnabled ?? this.distanceEnabled,
      distanceText: distanceText ?? this.distanceText,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (loveStartDate.present) {
      map['love_start_date'] = Variable<DateTime>(loveStartDate.value);
    }
    if (loveDaysOverride.present) {
      map['love_days_override'] = Variable<int>(loveDaysOverride.value);
    }
    if (distanceEnabled.present) {
      map['distance_enabled'] = Variable<bool>(distanceEnabled.value);
    }
    if (distanceText.present) {
      map['distance_text'] = Variable<String>(distanceText.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('loveStartDate: $loveStartDate, ')
          ..write('loveDaysOverride: $loveDaysOverride, ')
          ..write('distanceEnabled: $distanceEnabled, ')
          ..write('distanceText: $distanceText, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoursesTableTable extends CoursesTable
    with TableInfo<$CoursesTableTable, CoursesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(575),
  );
  static const VerificationMeta _startWeekMeta = const VerificationMeta(
    'startWeek',
  );
  @override
  late final GeneratedColumn<int> startWeek = GeneratedColumn<int>(
    'start_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _endWeekMeta = const VerificationMeta(
    'endWeek',
  );
  @override
  late final GeneratedColumn<int> endWeek = GeneratedColumn<int>(
    'end_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _repeatWeeklyMeta = const VerificationMeta(
    'repeatWeekly',
  );
  @override
  late final GeneratedColumn<bool> repeatWeekly = GeneratedColumn<bool>(
    'repeat_weekly',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeat_weekly" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startPeriodMeta = const VerificationMeta(
    'startPeriod',
  );
  @override
  late final GeneratedColumn<int> startPeriod = GeneratedColumn<int>(
    'start_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPeriodMeta = const VerificationMeta(
    'endPeriod',
  );
  @override
  late final GeneratedColumn<int> endPeriod = GeneratedColumn<int>(
    'end_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    weekday,
    startMinute,
    endMinute,
    startWeek,
    endWeek,
    repeatWeekly,
    startPeriod,
    endPeriod,
    location,
    teacher,
    note,
    owner,
    colorHex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoursesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    }
    if (data.containsKey('start_week')) {
      context.handle(
        _startWeekMeta,
        startWeek.isAcceptableOrUnknown(data['start_week']!, _startWeekMeta),
      );
    }
    if (data.containsKey('end_week')) {
      context.handle(
        _endWeekMeta,
        endWeek.isAcceptableOrUnknown(data['end_week']!, _endWeekMeta),
      );
    }
    if (data.containsKey('repeat_weekly')) {
      context.handle(
        _repeatWeeklyMeta,
        repeatWeekly.isAcceptableOrUnknown(
          data['repeat_weekly']!,
          _repeatWeeklyMeta,
        ),
      );
    }
    if (data.containsKey('start_period')) {
      context.handle(
        _startPeriodMeta,
        startPeriod.isAcceptableOrUnknown(
          data['start_period']!,
          _startPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startPeriodMeta);
    }
    if (data.containsKey('end_period')) {
      context.handle(
        _endPeriodMeta,
        endPeriod.isAcceptableOrUnknown(data['end_period']!, _endPeriodMeta),
      );
    } else if (isInserting) {
      context.missing(_endPeriodMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoursesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoursesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      startWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_week'],
      )!,
      endWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_week'],
      )!,
      repeatWeekly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeat_weekly'],
      )!,
      startPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_period'],
      )!,
      endPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_period'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoursesTableTable createAlias(String alias) {
    return $CoursesTableTable(attachedDatabase, alias);
  }
}

class CoursesTableData extends DataClass
    implements Insertable<CoursesTableData> {
  final String id;
  final String title;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final int startWeek;
  final int endWeek;
  final bool repeatWeekly;
  final int startPeriod;
  final int endPeriod;
  final String location;
  final String teacher;
  final String note;
  final String owner;
  final String colorHex;
  final DateTime createdAt;
  const CoursesTableData({
    required this.id,
    required this.title,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.startWeek,
    required this.endWeek,
    required this.repeatWeekly,
    required this.startPeriod,
    required this.endPeriod,
    required this.location,
    required this.teacher,
    required this.note,
    required this.owner,
    required this.colorHex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['weekday'] = Variable<int>(weekday);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['start_week'] = Variable<int>(startWeek);
    map['end_week'] = Variable<int>(endWeek);
    map['repeat_weekly'] = Variable<bool>(repeatWeekly);
    map['start_period'] = Variable<int>(startPeriod);
    map['end_period'] = Variable<int>(endPeriod);
    map['location'] = Variable<String>(location);
    map['teacher'] = Variable<String>(teacher);
    map['note'] = Variable<String>(note);
    map['owner'] = Variable<String>(owner);
    map['color_hex'] = Variable<String>(colorHex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CoursesTableCompanion toCompanion(bool nullToAbsent) {
    return CoursesTableCompanion(
      id: Value(id),
      title: Value(title),
      weekday: Value(weekday),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      startWeek: Value(startWeek),
      endWeek: Value(endWeek),
      repeatWeekly: Value(repeatWeekly),
      startPeriod: Value(startPeriod),
      endPeriod: Value(endPeriod),
      location: Value(location),
      teacher: Value(teacher),
      note: Value(note),
      owner: Value(owner),
      colorHex: Value(colorHex),
      createdAt: Value(createdAt),
    );
  }

  factory CoursesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoursesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      startWeek: serializer.fromJson<int>(json['startWeek']),
      endWeek: serializer.fromJson<int>(json['endWeek']),
      repeatWeekly: serializer.fromJson<bool>(json['repeatWeekly']),
      startPeriod: serializer.fromJson<int>(json['startPeriod']),
      endPeriod: serializer.fromJson<int>(json['endPeriod']),
      location: serializer.fromJson<String>(json['location']),
      teacher: serializer.fromJson<String>(json['teacher']),
      note: serializer.fromJson<String>(json['note']),
      owner: serializer.fromJson<String>(json['owner']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'weekday': serializer.toJson<int>(weekday),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'startWeek': serializer.toJson<int>(startWeek),
      'endWeek': serializer.toJson<int>(endWeek),
      'repeatWeekly': serializer.toJson<bool>(repeatWeekly),
      'startPeriod': serializer.toJson<int>(startPeriod),
      'endPeriod': serializer.toJson<int>(endPeriod),
      'location': serializer.toJson<String>(location),
      'teacher': serializer.toJson<String>(teacher),
      'note': serializer.toJson<String>(note),
      'owner': serializer.toJson<String>(owner),
      'colorHex': serializer.toJson<String>(colorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CoursesTableData copyWith({
    String? id,
    String? title,
    int? weekday,
    int? startMinute,
    int? endMinute,
    int? startWeek,
    int? endWeek,
    bool? repeatWeekly,
    int? startPeriod,
    int? endPeriod,
    String? location,
    String? teacher,
    String? note,
    String? owner,
    String? colorHex,
    DateTime? createdAt,
  }) => CoursesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    weekday: weekday ?? this.weekday,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    startWeek: startWeek ?? this.startWeek,
    endWeek: endWeek ?? this.endWeek,
    repeatWeekly: repeatWeekly ?? this.repeatWeekly,
    startPeriod: startPeriod ?? this.startPeriod,
    endPeriod: endPeriod ?? this.endPeriod,
    location: location ?? this.location,
    teacher: teacher ?? this.teacher,
    note: note ?? this.note,
    owner: owner ?? this.owner,
    colorHex: colorHex ?? this.colorHex,
    createdAt: createdAt ?? this.createdAt,
  );
  CoursesTableData copyWithCompanion(CoursesTableCompanion data) {
    return CoursesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      startWeek: data.startWeek.present ? data.startWeek.value : this.startWeek,
      endWeek: data.endWeek.present ? data.endWeek.value : this.endWeek,
      repeatWeekly: data.repeatWeekly.present
          ? data.repeatWeekly.value
          : this.repeatWeekly,
      startPeriod: data.startPeriod.present
          ? data.startPeriod.value
          : this.startPeriod,
      endPeriod: data.endPeriod.present ? data.endPeriod.value : this.endPeriod,
      location: data.location.present ? data.location.value : this.location,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      note: data.note.present ? data.note.value : this.note,
      owner: data.owner.present ? data.owner.value : this.owner,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoursesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('repeatWeekly: $repeatWeekly, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('location: $location, ')
          ..write('teacher: $teacher, ')
          ..write('note: $note, ')
          ..write('owner: $owner, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    weekday,
    startMinute,
    endMinute,
    startWeek,
    endWeek,
    repeatWeekly,
    startPeriod,
    endPeriod,
    location,
    teacher,
    note,
    owner,
    colorHex,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoursesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.weekday == this.weekday &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.startWeek == this.startWeek &&
          other.endWeek == this.endWeek &&
          other.repeatWeekly == this.repeatWeekly &&
          other.startPeriod == this.startPeriod &&
          other.endPeriod == this.endPeriod &&
          other.location == this.location &&
          other.teacher == this.teacher &&
          other.note == this.note &&
          other.owner == this.owner &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt);
}

class CoursesTableCompanion extends UpdateCompanion<CoursesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> weekday;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<int> startWeek;
  final Value<int> endWeek;
  final Value<bool> repeatWeekly;
  final Value<int> startPeriod;
  final Value<int> endPeriod;
  final Value<String> location;
  final Value<String> teacher;
  final Value<String> note;
  final Value<String> owner;
  final Value<String> colorHex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CoursesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.startWeek = const Value.absent(),
    this.endWeek = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.endPeriod = const Value.absent(),
    this.location = const Value.absent(),
    this.teacher = const Value.absent(),
    this.note = const Value.absent(),
    this.owner = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesTableCompanion.insert({
    required String id,
    required String title,
    required int weekday,
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.startWeek = const Value.absent(),
    this.endWeek = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    required int startPeriod,
    required int endPeriod,
    required String location,
    required String teacher,
    this.note = const Value.absent(),
    required String owner,
    required String colorHex,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       weekday = Value(weekday),
       startPeriod = Value(startPeriod),
       endPeriod = Value(endPeriod),
       location = Value(location),
       teacher = Value(teacher),
       owner = Value(owner),
       colorHex = Value(colorHex),
       createdAt = Value(createdAt);
  static Insertable<CoursesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? weekday,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? startWeek,
    Expression<int>? endWeek,
    Expression<bool>? repeatWeekly,
    Expression<int>? startPeriod,
    Expression<int>? endPeriod,
    Expression<String>? location,
    Expression<String>? teacher,
    Expression<String>? note,
    Expression<String>? owner,
    Expression<String>? colorHex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (weekday != null) 'weekday': weekday,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (startWeek != null) 'start_week': startWeek,
      if (endWeek != null) 'end_week': endWeek,
      if (repeatWeekly != null) 'repeat_weekly': repeatWeekly,
      if (startPeriod != null) 'start_period': startPeriod,
      if (endPeriod != null) 'end_period': endPeriod,
      if (location != null) 'location': location,
      if (teacher != null) 'teacher': teacher,
      if (note != null) 'note': note,
      if (owner != null) 'owner': owner,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? weekday,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<int>? startWeek,
    Value<int>? endWeek,
    Value<bool>? repeatWeekly,
    Value<int>? startPeriod,
    Value<int>? endPeriod,
    Value<String>? location,
    Value<String>? teacher,
    Value<String>? note,
    Value<String>? owner,
    Value<String>? colorHex,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CoursesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      weekday: weekday ?? this.weekday,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      location: location ?? this.location,
      teacher: teacher ?? this.teacher,
      note: note ?? this.note,
      owner: owner ?? this.owner,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (startWeek.present) {
      map['start_week'] = Variable<int>(startWeek.value);
    }
    if (endWeek.present) {
      map['end_week'] = Variable<int>(endWeek.value);
    }
    if (repeatWeekly.present) {
      map['repeat_weekly'] = Variable<bool>(repeatWeekly.value);
    }
    if (startPeriod.present) {
      map['start_period'] = Variable<int>(startPeriod.value);
    }
    if (endPeriod.present) {
      map['end_period'] = Variable<int>(endPeriod.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('repeatWeekly: $repeatWeekly, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('location: $location, ')
          ..write('teacher: $teacher, ')
          ..write('note: $note, ')
          ..write('owner: $owner, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongsTableTable extends SongsTable
    with TableInfo<$SongsTableTable, SongsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferenceMeta = const VerificationMeta(
    'preference',
  );
  @override
  late final GeneratedColumn<String> preference = GeneratedColumn<String>(
    'preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    artist,
    createdAt,
    preference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('preference')) {
      context.handle(
        _preferenceMeta,
        preference.isAcceptableOrUnknown(data['preference']!, _preferenceMeta),
      );
    } else if (isInserting) {
      context.missing(_preferenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      preference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference'],
      )!,
    );
  }

  @override
  $SongsTableTable createAlias(String alias) {
    return $SongsTableTable(attachedDatabase, alias);
  }
}

class SongsTableData extends DataClass implements Insertable<SongsTableData> {
  final String id;
  final String name;
  final String artist;
  final DateTime createdAt;
  final String preference;
  const SongsTableData({
    required this.id,
    required this.name,
    required this.artist,
    required this.createdAt,
    required this.preference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['artist'] = Variable<String>(artist);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['preference'] = Variable<String>(preference);
    return map;
  }

  SongsTableCompanion toCompanion(bool nullToAbsent) {
    return SongsTableCompanion(
      id: Value(id),
      name: Value(name),
      artist: Value(artist),
      createdAt: Value(createdAt),
      preference: Value(preference),
    );
  }

  factory SongsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<String>(json['artist']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      preference: serializer.fromJson<String>(json['preference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<String>(artist),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'preference': serializer.toJson<String>(preference),
    };
  }

  SongsTableData copyWith({
    String? id,
    String? name,
    String? artist,
    DateTime? createdAt,
    String? preference,
  }) => SongsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    artist: artist ?? this.artist,
    createdAt: createdAt ?? this.createdAt,
    preference: preference ?? this.preference,
  );
  SongsTableData copyWithCompanion(SongsTableCompanion data) {
    return SongsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      preference: data.preference.present
          ? data.preference.value
          : this.preference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('createdAt: $createdAt, ')
          ..write('preference: $preference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, artist, createdAt, preference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.artist == this.artist &&
          other.createdAt == this.createdAt &&
          other.preference == this.preference);
}

class SongsTableCompanion extends UpdateCompanion<SongsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> artist;
  final Value<DateTime> createdAt;
  final Value<String> preference;
  final Value<int> rowid;
  const SongsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.preference = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsTableCompanion.insert({
    required String id,
    required String name,
    required String artist,
    required DateTime createdAt,
    required String preference,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artist = Value(artist),
       createdAt = Value(createdAt),
       preference = Value(preference);
  static Insertable<SongsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artist,
    Expression<DateTime>? createdAt,
    Expression<String>? preference,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (createdAt != null) 'created_at': createdAt,
      if (preference != null) 'preference': preference,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? artist,
    Value<DateTime>? createdAt,
    Value<String>? preference,
    Value<int>? rowid,
  }) {
    return SongsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      createdAt: createdAt ?? this.createdAt,
      preference: preference ?? this.preference,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (preference.present) {
      map['preference'] = Variable<String>(preference.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('createdAt: $createdAt, ')
          ..write('preference: $preference, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongReviewsTableTable extends SongReviewsTable
    with TableInfo<$SongReviewsTableTable, SongReviewsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongReviewsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atmosphereScoreMeta = const VerificationMeta(
    'atmosphereScore',
  );
  @override
  late final GeneratedColumn<int> atmosphereScore = GeneratedColumn<int>(
    'atmosphere_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _resonanceScoreMeta = const VerificationMeta(
    'resonanceScore',
  );
  @override
  late final GeneratedColumn<int> resonanceScore = GeneratedColumn<int>(
    'resonance_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shareScoreMeta = const VerificationMeta(
    'shareScore',
  );
  @override
  late final GeneratedColumn<int> shareScore = GeneratedColumn<int>(
    'share_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _styleTagsMeta = const VerificationMeta(
    'styleTags',
  );
  @override
  late final GeneratedColumn<String> styleTags = GeneratedColumn<String>(
    'style_tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songId,
    author,
    content,
    atmosphereScore,
    resonanceScore,
    shareScore,
    styleTags,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongReviewsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('atmosphere_score')) {
      context.handle(
        _atmosphereScoreMeta,
        atmosphereScore.isAcceptableOrUnknown(
          data['atmosphere_score']!,
          _atmosphereScoreMeta,
        ),
      );
    }
    if (data.containsKey('resonance_score')) {
      context.handle(
        _resonanceScoreMeta,
        resonanceScore.isAcceptableOrUnknown(
          data['resonance_score']!,
          _resonanceScoreMeta,
        ),
      );
    }
    if (data.containsKey('share_score')) {
      context.handle(
        _shareScoreMeta,
        shareScore.isAcceptableOrUnknown(data['share_score']!, _shareScoreMeta),
      );
    }
    if (data.containsKey('style_tags')) {
      context.handle(
        _styleTagsMeta,
        styleTags.isAcceptableOrUnknown(data['style_tags']!, _styleTagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongReviewsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongReviewsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      atmosphereScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atmosphere_score'],
      )!,
      resonanceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resonance_score'],
      )!,
      shareScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_score'],
      )!,
      styleTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_tags'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SongReviewsTableTable createAlias(String alias) {
    return $SongReviewsTableTable(attachedDatabase, alias);
  }
}

class SongReviewsTableData extends DataClass
    implements Insertable<SongReviewsTableData> {
  final String id;
  final String songId;
  final String author;
  final String content;
  final int atmosphereScore;
  final int resonanceScore;
  final int shareScore;
  final String styleTags;
  final DateTime createdAt;
  const SongReviewsTableData({
    required this.id,
    required this.songId,
    required this.author,
    required this.content,
    required this.atmosphereScore,
    required this.resonanceScore,
    required this.shareScore,
    required this.styleTags,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['author'] = Variable<String>(author);
    map['content'] = Variable<String>(content);
    map['atmosphere_score'] = Variable<int>(atmosphereScore);
    map['resonance_score'] = Variable<int>(resonanceScore);
    map['share_score'] = Variable<int>(shareScore);
    map['style_tags'] = Variable<String>(styleTags);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SongReviewsTableCompanion toCompanion(bool nullToAbsent) {
    return SongReviewsTableCompanion(
      id: Value(id),
      songId: Value(songId),
      author: Value(author),
      content: Value(content),
      atmosphereScore: Value(atmosphereScore),
      resonanceScore: Value(resonanceScore),
      shareScore: Value(shareScore),
      styleTags: Value(styleTags),
      createdAt: Value(createdAt),
    );
  }

  factory SongReviewsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongReviewsTableData(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      author: serializer.fromJson<String>(json['author']),
      content: serializer.fromJson<String>(json['content']),
      atmosphereScore: serializer.fromJson<int>(json['atmosphereScore']),
      resonanceScore: serializer.fromJson<int>(json['resonanceScore']),
      shareScore: serializer.fromJson<int>(json['shareScore']),
      styleTags: serializer.fromJson<String>(json['styleTags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'author': serializer.toJson<String>(author),
      'content': serializer.toJson<String>(content),
      'atmosphereScore': serializer.toJson<int>(atmosphereScore),
      'resonanceScore': serializer.toJson<int>(resonanceScore),
      'shareScore': serializer.toJson<int>(shareScore),
      'styleTags': serializer.toJson<String>(styleTags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SongReviewsTableData copyWith({
    String? id,
    String? songId,
    String? author,
    String? content,
    int? atmosphereScore,
    int? resonanceScore,
    int? shareScore,
    String? styleTags,
    DateTime? createdAt,
  }) => SongReviewsTableData(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    author: author ?? this.author,
    content: content ?? this.content,
    atmosphereScore: atmosphereScore ?? this.atmosphereScore,
    resonanceScore: resonanceScore ?? this.resonanceScore,
    shareScore: shareScore ?? this.shareScore,
    styleTags: styleTags ?? this.styleTags,
    createdAt: createdAt ?? this.createdAt,
  );
  SongReviewsTableData copyWithCompanion(SongReviewsTableCompanion data) {
    return SongReviewsTableData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      author: data.author.present ? data.author.value : this.author,
      content: data.content.present ? data.content.value : this.content,
      atmosphereScore: data.atmosphereScore.present
          ? data.atmosphereScore.value
          : this.atmosphereScore,
      resonanceScore: data.resonanceScore.present
          ? data.resonanceScore.value
          : this.resonanceScore,
      shareScore: data.shareScore.present
          ? data.shareScore.value
          : this.shareScore,
      styleTags: data.styleTags.present ? data.styleTags.value : this.styleTags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongReviewsTableData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('author: $author, ')
          ..write('content: $content, ')
          ..write('atmosphereScore: $atmosphereScore, ')
          ..write('resonanceScore: $resonanceScore, ')
          ..write('shareScore: $shareScore, ')
          ..write('styleTags: $styleTags, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    songId,
    author,
    content,
    atmosphereScore,
    resonanceScore,
    shareScore,
    styleTags,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongReviewsTableData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.author == this.author &&
          other.content == this.content &&
          other.atmosphereScore == this.atmosphereScore &&
          other.resonanceScore == this.resonanceScore &&
          other.shareScore == this.shareScore &&
          other.styleTags == this.styleTags &&
          other.createdAt == this.createdAt);
}

class SongReviewsTableCompanion extends UpdateCompanion<SongReviewsTableData> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> author;
  final Value<String> content;
  final Value<int> atmosphereScore;
  final Value<int> resonanceScore;
  final Value<int> shareScore;
  final Value<String> styleTags;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SongReviewsTableCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.author = const Value.absent(),
    this.content = const Value.absent(),
    this.atmosphereScore = const Value.absent(),
    this.resonanceScore = const Value.absent(),
    this.shareScore = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongReviewsTableCompanion.insert({
    required String id,
    required String songId,
    required String author,
    required String content,
    this.atmosphereScore = const Value.absent(),
    this.resonanceScore = const Value.absent(),
    this.shareScore = const Value.absent(),
    this.styleTags = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       songId = Value(songId),
       author = Value(author),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<SongReviewsTableData> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? author,
    Expression<String>? content,
    Expression<int>? atmosphereScore,
    Expression<int>? resonanceScore,
    Expression<int>? shareScore,
    Expression<String>? styleTags,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (author != null) 'author': author,
      if (content != null) 'content': content,
      if (atmosphereScore != null) 'atmosphere_score': atmosphereScore,
      if (resonanceScore != null) 'resonance_score': resonanceScore,
      if (shareScore != null) 'share_score': shareScore,
      if (styleTags != null) 'style_tags': styleTags,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongReviewsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? author,
    Value<String>? content,
    Value<int>? atmosphereScore,
    Value<int>? resonanceScore,
    Value<int>? shareScore,
    Value<String>? styleTags,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SongReviewsTableCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      author: author ?? this.author,
      content: content ?? this.content,
      atmosphereScore: atmosphereScore ?? this.atmosphereScore,
      resonanceScore: resonanceScore ?? this.resonanceScore,
      shareScore: shareScore ?? this.shareScore,
      styleTags: styleTags ?? this.styleTags,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (atmosphereScore.present) {
      map['atmosphere_score'] = Variable<int>(atmosphereScore.value);
    }
    if (resonanceScore.present) {
      map['resonance_score'] = Variable<int>(resonanceScore.value);
    }
    if (shareScore.present) {
      map['share_score'] = Variable<int>(shareScore.value);
    }
    if (styleTags.present) {
      map['style_tags'] = Variable<String>(styleTags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongReviewsTableCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('author: $author, ')
          ..write('content: $content, ')
          ..write('atmosphereScore: $atmosphereScore, ')
          ..write('resonanceScore: $resonanceScore, ')
          ..write('shareScore: $shareScore, ')
          ..write('styleTags: $styleTags, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTableTable extends TodosTable
    with TableInfo<$TodosTableTable, TodosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    coupleId,
    title,
    description,
    dueAt,
    owner,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $TodosTableTable createAlias(String alias) {
    return $TodosTableTable(attachedDatabase, alias);
  }
}

class TodosTableData extends DataClass implements Insertable<TodosTableData> {
  final String id;
  final String coupleId;
  final String title;
  final String description;
  final DateTime? dueAt;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool pendingSync;
  const TodosTableData({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.description,
    this.dueAt,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['couple_id'] = Variable<String>(coupleId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['owner'] = Variable<String>(owner);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  TodosTableCompanion toCompanion(bool nullToAbsent) {
    return TodosTableCompanion(
      id: Value(id),
      coupleId: Value(coupleId),
      title: Value(title),
      description: Value(description),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      owner: Value(owner),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      pendingSync: Value(pendingSync),
    );
  }

  factory TodosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodosTableData(
      id: serializer.fromJson<String>(json['id']),
      coupleId: serializer.fromJson<String>(json['coupleId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      owner: serializer.fromJson<String>(json['owner']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'coupleId': serializer.toJson<String>(coupleId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'owner': serializer.toJson<String>(owner),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  TodosTableData copyWith({
    String? id,
    String? coupleId,
    String? title,
    String? description,
    Value<DateTime?> dueAt = const Value.absent(),
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? pendingSync,
  }) => TodosTableData(
    id: id ?? this.id,
    coupleId: coupleId ?? this.coupleId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    owner: owner ?? this.owner,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  TodosTableData copyWithCompanion(TodosTableCompanion data) {
    return TodosTableData(
      id: data.id.present ? data.id.value : this.id,
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      owner: data.owner.present ? data.owner.value : this.owner,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodosTableData(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueAt: $dueAt, ')
          ..write('owner: $owner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    coupleId,
    title,
    description,
    dueAt,
    owner,
    createdAt,
    updatedAt,
    isDeleted,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodosTableData &&
          other.id == this.id &&
          other.coupleId == this.coupleId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueAt == this.dueAt &&
          other.owner == this.owner &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.pendingSync == this.pendingSync);
}

class TodosTableCompanion extends UpdateCompanion<TodosTableData> {
  final Value<String> id;
  final Value<String> coupleId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime?> dueAt;
  final Value<String> owner;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const TodosTableCompanion({
    this.id = const Value.absent(),
    this.coupleId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.owner = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosTableCompanion.insert({
    required String id,
    this.coupleId = const Value.absent(),
    required String title,
    required String description,
    this.dueAt = const Value.absent(),
    required String owner,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       owner = Value(owner),
       createdAt = Value(createdAt);
  static Insertable<TodosTableData> custom({
    Expression<String>? id,
    Expression<String>? coupleId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueAt,
    Expression<String>? owner,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (coupleId != null) 'couple_id': coupleId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueAt != null) 'due_at': dueAt,
      if (owner != null) 'owner': owner,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? coupleId,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime?>? dueAt,
    Value<String>? owner,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return TodosTableCompanion(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosTableCompanion(')
          ..write('id: $id, ')
          ..write('coupleId: $coupleId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueAt: $dueAt, ')
          ..write('owner: $owner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoProgressTableTable extends TodoProgressTable
    with TableInfo<$TodoProgressTableTable, TodoProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meDoneMeta = const VerificationMeta('meDone');
  @override
  late final GeneratedColumn<bool> meDone = GeneratedColumn<bool>(
    'me_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("me_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _partnerDoneMeta = const VerificationMeta(
    'partnerDone',
  );
  @override
  late final GeneratedColumn<bool> partnerDone = GeneratedColumn<bool>(
    'partner_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("partner_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    todoId,
    meDone,
    partnerDone,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('me_done')) {
      context.handle(
        _meDoneMeta,
        meDone.isAcceptableOrUnknown(data['me_done']!, _meDoneMeta),
      );
    }
    if (data.containsKey('partner_done')) {
      context.handle(
        _partnerDoneMeta,
        partnerDone.isAcceptableOrUnknown(
          data['partner_done']!,
          _partnerDoneMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {todoId};
  @override
  TodoProgressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoProgressTableData(
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      meDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}me_done'],
      )!,
      partnerDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}partner_done'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TodoProgressTableTable createAlias(String alias) {
    return $TodoProgressTableTable(attachedDatabase, alias);
  }
}

class TodoProgressTableData extends DataClass
    implements Insertable<TodoProgressTableData> {
  final String todoId;
  final bool meDone;
  final bool partnerDone;
  final DateTime updatedAt;
  const TodoProgressTableData({
    required this.todoId,
    required this.meDone,
    required this.partnerDone,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['todo_id'] = Variable<String>(todoId);
    map['me_done'] = Variable<bool>(meDone);
    map['partner_done'] = Variable<bool>(partnerDone);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TodoProgressTableCompanion toCompanion(bool nullToAbsent) {
    return TodoProgressTableCompanion(
      todoId: Value(todoId),
      meDone: Value(meDone),
      partnerDone: Value(partnerDone),
      updatedAt: Value(updatedAt),
    );
  }

  factory TodoProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoProgressTableData(
      todoId: serializer.fromJson<String>(json['todoId']),
      meDone: serializer.fromJson<bool>(json['meDone']),
      partnerDone: serializer.fromJson<bool>(json['partnerDone']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'todoId': serializer.toJson<String>(todoId),
      'meDone': serializer.toJson<bool>(meDone),
      'partnerDone': serializer.toJson<bool>(partnerDone),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TodoProgressTableData copyWith({
    String? todoId,
    bool? meDone,
    bool? partnerDone,
    DateTime? updatedAt,
  }) => TodoProgressTableData(
    todoId: todoId ?? this.todoId,
    meDone: meDone ?? this.meDone,
    partnerDone: partnerDone ?? this.partnerDone,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TodoProgressTableData copyWithCompanion(TodoProgressTableCompanion data) {
    return TodoProgressTableData(
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      meDone: data.meDone.present ? data.meDone.value : this.meDone,
      partnerDone: data.partnerDone.present
          ? data.partnerDone.value
          : this.partnerDone,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoProgressTableData(')
          ..write('todoId: $todoId, ')
          ..write('meDone: $meDone, ')
          ..write('partnerDone: $partnerDone, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(todoId, meDone, partnerDone, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoProgressTableData &&
          other.todoId == this.todoId &&
          other.meDone == this.meDone &&
          other.partnerDone == this.partnerDone &&
          other.updatedAt == this.updatedAt);
}

class TodoProgressTableCompanion
    extends UpdateCompanion<TodoProgressTableData> {
  final Value<String> todoId;
  final Value<bool> meDone;
  final Value<bool> partnerDone;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TodoProgressTableCompanion({
    this.todoId = const Value.absent(),
    this.meDone = const Value.absent(),
    this.partnerDone = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoProgressTableCompanion.insert({
    required String todoId,
    this.meDone = const Value.absent(),
    this.partnerDone = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : todoId = Value(todoId),
       updatedAt = Value(updatedAt);
  static Insertable<TodoProgressTableData> custom({
    Expression<String>? todoId,
    Expression<bool>? meDone,
    Expression<bool>? partnerDone,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (todoId != null) 'todo_id': todoId,
      if (meDone != null) 'me_done': meDone,
      if (partnerDone != null) 'partner_done': partnerDone,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoProgressTableCompanion copyWith({
    Value<String>? todoId,
    Value<bool>? meDone,
    Value<bool>? partnerDone,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TodoProgressTableCompanion(
      todoId: todoId ?? this.todoId,
      meDone: meDone ?? this.meDone,
      partnerDone: partnerDone ?? this.partnerDone,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (meDone.present) {
      map['me_done'] = Variable<bool>(meDone.value);
    }
    if (partnerDone.present) {
      map['partner_done'] = Variable<bool>(partnerDone.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoProgressTableCompanion(')
          ..write('todoId: $todoId, ')
          ..write('meDone: $meDone, ')
          ..write('partnerDone: $partnerDone, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatMessagesTableTable chatMessagesTable =
      $ChatMessagesTableTable(this);
  late final $BillRecordsTableTable billRecordsTable = $BillRecordsTableTable(
    this,
  );
  late final $CountdownEventsTableTable countdownEventsTable =
      $CountdownEventsTableTable(this);
  late final $PokeEventsTableTable pokeEventsTable = $PokeEventsTableTable(
    this,
  );
  late final $FeedEventsTableTable feedEventsTable = $FeedEventsTableTable(
    this,
  );
  late final $LocalUserProfileTableTable localUserProfileTable =
      $LocalUserProfileTableTable(this);
  late final $LocalCoupleProfileTableTable localCoupleProfileTable =
      $LocalCoupleProfileTableTable(this);
  late final $RelationshipSettingsTableTable relationshipSettingsTable =
      $RelationshipSettingsTableTable(this);
  late final $CoursesTableTable coursesTable = $CoursesTableTable(this);
  late final $SongsTableTable songsTable = $SongsTableTable(this);
  late final $SongReviewsTableTable songReviewsTable = $SongReviewsTableTable(
    this,
  );
  late final $TodosTableTable todosTable = $TodosTableTable(this);
  late final $TodoProgressTableTable todoProgressTable =
      $TodoProgressTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatMessagesTable,
    billRecordsTable,
    countdownEventsTable,
    pokeEventsTable,
    feedEventsTable,
    localUserProfileTable,
    localCoupleProfileTable,
    relationshipSettingsTable,
    coursesTable,
    songsTable,
    songReviewsTable,
    todosTable,
    todoProgressTable,
  ];
}

typedef $$ChatMessagesTableTableCreateCompanionBuilder =
    ChatMessagesTableCompanion Function({
      required String id,
      required String content,
      required String sender,
      Value<String?> senderUserId,
      Value<String?> clientMessageId,
      Value<String> messageType,
      Value<String?> mediaUrl,
      Value<int?> mediaDurationMs,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableTableUpdateCompanionBuilder =
    ChatMessagesTableCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<String> sender,
      Value<String?> senderUserId,
      Value<String?> clientMessageId,
      Value<String> messageType,
      Value<String?> mediaUrl,
      Value<int?> mediaDurationMs,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$ChatMessagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ChatMessagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTableTable,
          ChatMessagesTableData,
          $$ChatMessagesTableTableFilterComposer,
          $$ChatMessagesTableTableOrderingComposer,
          $$ChatMessagesTableTableAnnotationComposer,
          $$ChatMessagesTableTableCreateCompanionBuilder,
          $$ChatMessagesTableTableUpdateCompanionBuilder,
          (
            ChatMessagesTableData,
            BaseReferences<
              _$AppDatabase,
              $ChatMessagesTableTable,
              ChatMessagesTableData
            >,
          ),
          ChatMessagesTableData,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableTableManager(
    _$AppDatabase db,
    $ChatMessagesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String?> senderUserId = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String?> mediaUrl = const Value.absent(),
                Value<int?> mediaDurationMs = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesTableCompanion(
                id: id,
                content: content,
                sender: sender,
                senderUserId: senderUserId,
                clientMessageId: clientMessageId,
                messageType: messageType,
                mediaUrl: mediaUrl,
                mediaDurationMs: mediaDurationMs,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required String sender,
                Value<String?> senderUserId = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String?> mediaUrl = const Value.absent(),
                Value<int?> mediaDurationMs = const Value.absent(),
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesTableCompanion.insert(
                id: id,
                content: content,
                sender: sender,
                senderUserId: senderUserId,
                clientMessageId: clientMessageId,
                messageType: messageType,
                mediaUrl: mediaUrl,
                mediaDurationMs: mediaDurationMs,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTableTable,
      ChatMessagesTableData,
      $$ChatMessagesTableTableFilterComposer,
      $$ChatMessagesTableTableOrderingComposer,
      $$ChatMessagesTableTableAnnotationComposer,
      $$ChatMessagesTableTableCreateCompanionBuilder,
      $$ChatMessagesTableTableUpdateCompanionBuilder,
      (
        ChatMessagesTableData,
        BaseReferences<
          _$AppDatabase,
          $ChatMessagesTableTable,
          ChatMessagesTableData
        >,
      ),
      ChatMessagesTableData,
      PrefetchHooks Function()
    >;
typedef $$BillRecordsTableTableCreateCompanionBuilder =
    BillRecordsTableCompanion Function({
      required String id,
      Value<String> coupleId,
      required String type,
      required double amount,
      Value<String> category,
      required String note,
      required DateTime createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$BillRecordsTableTableUpdateCompanionBuilder =
    BillRecordsTableCompanion Function({
      Value<String> id,
      Value<String> coupleId,
      Value<String> type,
      Value<double> amount,
      Value<String> category,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$BillRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BillRecordsTableTable> {
  $$BillRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BillRecordsTableTable> {
  $$BillRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillRecordsTableTable> {
  $$BillRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$BillRecordsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillRecordsTableTable,
          BillRecordsTableData,
          $$BillRecordsTableTableFilterComposer,
          $$BillRecordsTableTableOrderingComposer,
          $$BillRecordsTableTableAnnotationComposer,
          $$BillRecordsTableTableCreateCompanionBuilder,
          $$BillRecordsTableTableUpdateCompanionBuilder,
          (
            BillRecordsTableData,
            BaseReferences<
              _$AppDatabase,
              $BillRecordsTableTable,
              BillRecordsTableData
            >,
          ),
          BillRecordsTableData,
          PrefetchHooks Function()
        > {
  $$BillRecordsTableTableTableManager(
    _$AppDatabase db,
    $BillRecordsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillRecordsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillRecordsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> coupleId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillRecordsTableCompanion(
                id: id,
                coupleId: coupleId,
                type: type,
                amount: amount,
                category: category,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> coupleId = const Value.absent(),
                required String type,
                required double amount,
                Value<String> category = const Value.absent(),
                required String note,
                required DateTime createdAt,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillRecordsTableCompanion.insert(
                id: id,
                coupleId: coupleId,
                type: type,
                amount: amount,
                category: category,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillRecordsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillRecordsTableTable,
      BillRecordsTableData,
      $$BillRecordsTableTableFilterComposer,
      $$BillRecordsTableTableOrderingComposer,
      $$BillRecordsTableTableAnnotationComposer,
      $$BillRecordsTableTableCreateCompanionBuilder,
      $$BillRecordsTableTableUpdateCompanionBuilder,
      (
        BillRecordsTableData,
        BaseReferences<
          _$AppDatabase,
          $BillRecordsTableTable,
          BillRecordsTableData
        >,
      ),
      BillRecordsTableData,
      PrefetchHooks Function()
    >;
typedef $$CountdownEventsTableTableCreateCompanionBuilder =
    CountdownEventsTableCompanion Function({
      required String id,
      Value<String> coupleId,
      required String name,
      required DateTime date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$CountdownEventsTableTableUpdateCompanionBuilder =
    CountdownEventsTableCompanion Function({
      Value<String> id,
      Value<String> coupleId,
      Value<String> name,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$CountdownEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CountdownEventsTableTable> {
  $$CountdownEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountdownEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CountdownEventsTableTable> {
  $$CountdownEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountdownEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountdownEventsTableTable> {
  $$CountdownEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$CountdownEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountdownEventsTableTable,
          CountdownEventsTableData,
          $$CountdownEventsTableTableFilterComposer,
          $$CountdownEventsTableTableOrderingComposer,
          $$CountdownEventsTableTableAnnotationComposer,
          $$CountdownEventsTableTableCreateCompanionBuilder,
          $$CountdownEventsTableTableUpdateCompanionBuilder,
          (
            CountdownEventsTableData,
            BaseReferences<
              _$AppDatabase,
              $CountdownEventsTableTable,
              CountdownEventsTableData
            >,
          ),
          CountdownEventsTableData,
          PrefetchHooks Function()
        > {
  $$CountdownEventsTableTableTableManager(
    _$AppDatabase db,
    $CountdownEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountdownEventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountdownEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CountdownEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> coupleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountdownEventsTableCompanion(
                id: id,
                coupleId: coupleId,
                name: name,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> coupleId = const Value.absent(),
                required String name,
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountdownEventsTableCompanion.insert(
                id: id,
                coupleId: coupleId,
                name: name,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountdownEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountdownEventsTableTable,
      CountdownEventsTableData,
      $$CountdownEventsTableTableFilterComposer,
      $$CountdownEventsTableTableOrderingComposer,
      $$CountdownEventsTableTableAnnotationComposer,
      $$CountdownEventsTableTableCreateCompanionBuilder,
      $$CountdownEventsTableTableUpdateCompanionBuilder,
      (
        CountdownEventsTableData,
        BaseReferences<
          _$AppDatabase,
          $CountdownEventsTableTable,
          CountdownEventsTableData
        >,
      ),
      CountdownEventsTableData,
      PrefetchHooks Function()
    >;
typedef $$PokeEventsTableTableCreateCompanionBuilder =
    PokeEventsTableCompanion Function({
      required String id,
      required String sender,
      required String message,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PokeEventsTableTableUpdateCompanionBuilder =
    PokeEventsTableCompanion Function({
      Value<String> id,
      Value<String> sender,
      Value<String> message,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PokeEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokeEventsTableTable> {
  $$PokeEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokeEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokeEventsTableTable> {
  $$PokeEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokeEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokeEventsTableTable> {
  $$PokeEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PokeEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokeEventsTableTable,
          PokeEventsTableData,
          $$PokeEventsTableTableFilterComposer,
          $$PokeEventsTableTableOrderingComposer,
          $$PokeEventsTableTableAnnotationComposer,
          $$PokeEventsTableTableCreateCompanionBuilder,
          $$PokeEventsTableTableUpdateCompanionBuilder,
          (
            PokeEventsTableData,
            BaseReferences<
              _$AppDatabase,
              $PokeEventsTableTable,
              PokeEventsTableData
            >,
          ),
          PokeEventsTableData,
          PrefetchHooks Function()
        > {
  $$PokeEventsTableTableTableManager(
    _$AppDatabase db,
    $PokeEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokeEventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokeEventsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokeEventsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PokeEventsTableCompanion(
                id: id,
                sender: sender,
                message: message,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sender,
                required String message,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PokeEventsTableCompanion.insert(
                id: id,
                sender: sender,
                message: message,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokeEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokeEventsTableTable,
      PokeEventsTableData,
      $$PokeEventsTableTableFilterComposer,
      $$PokeEventsTableTableOrderingComposer,
      $$PokeEventsTableTableAnnotationComposer,
      $$PokeEventsTableTableCreateCompanionBuilder,
      $$PokeEventsTableTableUpdateCompanionBuilder,
      (
        PokeEventsTableData,
        BaseReferences<
          _$AppDatabase,
          $PokeEventsTableTable,
          PokeEventsTableData
        >,
      ),
      PokeEventsTableData,
      PrefetchHooks Function()
    >;
typedef $$FeedEventsTableTableCreateCompanionBuilder =
    FeedEventsTableCompanion Function({
      required String id,
      required String eventType,
      required String actorSide,
      required String targetType,
      required String targetId,
      required String summaryText,
      required DateTime createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });
typedef $$FeedEventsTableTableUpdateCompanionBuilder =
    FeedEventsTableCompanion Function({
      Value<String> id,
      Value<String> eventType,
      Value<String> actorSide,
      Value<String> targetType,
      Value<String> targetId,
      Value<String> summaryText,
      Value<DateTime> createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });

class $$FeedEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FeedEventsTableTable> {
  $$FeedEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorSide => $composableBuilder(
    column: $table.actorSide,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedEventsTableTable> {
  $$FeedEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorSide => $composableBuilder(
    column: $table.actorSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedEventsTableTable> {
  $$FeedEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get actorSide =>
      $composableBuilder(column: $table.actorSide, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$FeedEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedEventsTableTable,
          FeedEventsTableData,
          $$FeedEventsTableTableFilterComposer,
          $$FeedEventsTableTableOrderingComposer,
          $$FeedEventsTableTableAnnotationComposer,
          $$FeedEventsTableTableCreateCompanionBuilder,
          $$FeedEventsTableTableUpdateCompanionBuilder,
          (
            FeedEventsTableData,
            BaseReferences<
              _$AppDatabase,
              $FeedEventsTableTable,
              FeedEventsTableData
            >,
          ),
          FeedEventsTableData,
          PrefetchHooks Function()
        > {
  $$FeedEventsTableTableTableManager(
    _$AppDatabase db,
    $FeedEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedEventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedEventsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedEventsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> actorSide = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> summaryText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedEventsTableCompanion(
                id: id,
                eventType: eventType,
                actorSide: actorSide,
                targetType: targetType,
                targetId: targetId,
                summaryText: summaryText,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventType,
                required String actorSide,
                required String targetType,
                required String targetId,
                required String summaryText,
                required DateTime createdAt,
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedEventsTableCompanion.insert(
                id: id,
                eventType: eventType,
                actorSide: actorSide,
                targetType: targetType,
                targetId: targetId,
                summaryText: summaryText,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedEventsTableTable,
      FeedEventsTableData,
      $$FeedEventsTableTableFilterComposer,
      $$FeedEventsTableTableOrderingComposer,
      $$FeedEventsTableTableAnnotationComposer,
      $$FeedEventsTableTableCreateCompanionBuilder,
      $$FeedEventsTableTableUpdateCompanionBuilder,
      (
        FeedEventsTableData,
        BaseReferences<
          _$AppDatabase,
          $FeedEventsTableTable,
          FeedEventsTableData
        >,
      ),
      FeedEventsTableData,
      PrefetchHooks Function()
    >;
typedef $$LocalUserProfileTableTableCreateCompanionBuilder =
    LocalUserProfileTableCompanion Function({
      required String userId,
      required String nickname,
      required String pairCode,
      Value<String?> coupleId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalUserProfileTableTableUpdateCompanionBuilder =
    LocalUserProfileTableCompanion Function({
      Value<String> userId,
      Value<String> nickname,
      Value<String> pairCode,
      Value<String?> coupleId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalUserProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTableTable> {
  $$LocalUserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pairCode => $composableBuilder(
    column: $table.pairCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTableTable> {
  $$LocalUserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairCode => $composableBuilder(
    column: $table.pairCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserProfileTableTable> {
  $$LocalUserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get pairCode =>
      $composableBuilder(column: $table.pairCode, builder: (column) => column);

  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUserProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserProfileTableTable,
          LocalUserProfileTableData,
          $$LocalUserProfileTableTableFilterComposer,
          $$LocalUserProfileTableTableOrderingComposer,
          $$LocalUserProfileTableTableAnnotationComposer,
          $$LocalUserProfileTableTableCreateCompanionBuilder,
          $$LocalUserProfileTableTableUpdateCompanionBuilder,
          (
            LocalUserProfileTableData,
            BaseReferences<
              _$AppDatabase,
              $LocalUserProfileTableTable,
              LocalUserProfileTableData
            >,
          ),
          LocalUserProfileTableData,
          PrefetchHooks Function()
        > {
  $$LocalUserProfileTableTableTableManager(
    _$AppDatabase db,
    $LocalUserProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserProfileTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalUserProfileTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalUserProfileTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> pairCode = const Value.absent(),
                Value<String?> coupleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserProfileTableCompanion(
                userId: userId,
                nickname: nickname,
                pairCode: pairCode,
                coupleId: coupleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String nickname,
                required String pairCode,
                Value<String?> coupleId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalUserProfileTableCompanion.insert(
                userId: userId,
                nickname: nickname,
                pairCode: pairCode,
                coupleId: coupleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserProfileTableTable,
      LocalUserProfileTableData,
      $$LocalUserProfileTableTableFilterComposer,
      $$LocalUserProfileTableTableOrderingComposer,
      $$LocalUserProfileTableTableAnnotationComposer,
      $$LocalUserProfileTableTableCreateCompanionBuilder,
      $$LocalUserProfileTableTableUpdateCompanionBuilder,
      (
        LocalUserProfileTableData,
        BaseReferences<
          _$AppDatabase,
          $LocalUserProfileTableTable,
          LocalUserProfileTableData
        >,
      ),
      LocalUserProfileTableData,
      PrefetchHooks Function()
    >;
typedef $$LocalCoupleProfileTableTableCreateCompanionBuilder =
    LocalCoupleProfileTableCompanion Function({
      required String coupleId,
      required String currentUserId,
      required String currentUserNickname,
      required String partnerUserId,
      required String partnerNickname,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalCoupleProfileTableTableUpdateCompanionBuilder =
    LocalCoupleProfileTableCompanion Function({
      Value<String> coupleId,
      Value<String> currentUserId,
      Value<String> currentUserNickname,
      Value<String> partnerUserId,
      Value<String> partnerNickname,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalCoupleProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCoupleProfileTableTable> {
  $$LocalCoupleProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentUserId => $composableBuilder(
    column: $table.currentUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentUserNickname => $composableBuilder(
    column: $table.currentUserNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCoupleProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCoupleProfileTableTable> {
  $$LocalCoupleProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentUserId => $composableBuilder(
    column: $table.currentUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentUserNickname => $composableBuilder(
    column: $table.currentUserNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCoupleProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCoupleProfileTableTable> {
  $$LocalCoupleProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<String> get currentUserId => $composableBuilder(
    column: $table.currentUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentUserNickname => $composableBuilder(
    column: $table.currentUserNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerUserId => $composableBuilder(
    column: $table.partnerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerNickname => $composableBuilder(
    column: $table.partnerNickname,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCoupleProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCoupleProfileTableTable,
          LocalCoupleProfileTableData,
          $$LocalCoupleProfileTableTableFilterComposer,
          $$LocalCoupleProfileTableTableOrderingComposer,
          $$LocalCoupleProfileTableTableAnnotationComposer,
          $$LocalCoupleProfileTableTableCreateCompanionBuilder,
          $$LocalCoupleProfileTableTableUpdateCompanionBuilder,
          (
            LocalCoupleProfileTableData,
            BaseReferences<
              _$AppDatabase,
              $LocalCoupleProfileTableTable,
              LocalCoupleProfileTableData
            >,
          ),
          LocalCoupleProfileTableData,
          PrefetchHooks Function()
        > {
  $$LocalCoupleProfileTableTableTableManager(
    _$AppDatabase db,
    $LocalCoupleProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCoupleProfileTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalCoupleProfileTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalCoupleProfileTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> coupleId = const Value.absent(),
                Value<String> currentUserId = const Value.absent(),
                Value<String> currentUserNickname = const Value.absent(),
                Value<String> partnerUserId = const Value.absent(),
                Value<String> partnerNickname = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCoupleProfileTableCompanion(
                coupleId: coupleId,
                currentUserId: currentUserId,
                currentUserNickname: currentUserNickname,
                partnerUserId: partnerUserId,
                partnerNickname: partnerNickname,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String coupleId,
                required String currentUserId,
                required String currentUserNickname,
                required String partnerUserId,
                required String partnerNickname,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalCoupleProfileTableCompanion.insert(
                coupleId: coupleId,
                currentUserId: currentUserId,
                currentUserNickname: currentUserNickname,
                partnerUserId: partnerUserId,
                partnerNickname: partnerNickname,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCoupleProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCoupleProfileTableTable,
      LocalCoupleProfileTableData,
      $$LocalCoupleProfileTableTableFilterComposer,
      $$LocalCoupleProfileTableTableOrderingComposer,
      $$LocalCoupleProfileTableTableAnnotationComposer,
      $$LocalCoupleProfileTableTableCreateCompanionBuilder,
      $$LocalCoupleProfileTableTableUpdateCompanionBuilder,
      (
        LocalCoupleProfileTableData,
        BaseReferences<
          _$AppDatabase,
          $LocalCoupleProfileTableTable,
          LocalCoupleProfileTableData
        >,
      ),
      LocalCoupleProfileTableData,
      PrefetchHooks Function()
    >;
typedef $$RelationshipSettingsTableTableCreateCompanionBuilder =
    RelationshipSettingsTableCompanion Function({
      Value<String> id,
      Value<DateTime?> loveStartDate,
      Value<int?> loveDaysOverride,
      Value<bool> distanceEnabled,
      Value<String?> distanceText,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RelationshipSettingsTableTableUpdateCompanionBuilder =
    RelationshipSettingsTableCompanion Function({
      Value<String> id,
      Value<DateTime?> loveStartDate,
      Value<int?> loveDaysOverride,
      Value<bool> distanceEnabled,
      Value<String?> distanceText,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RelationshipSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipSettingsTableTable> {
  $$RelationshipSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loveStartDate => $composableBuilder(
    column: $table.loveStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loveDaysOverride => $composableBuilder(
    column: $table.loveDaysOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get distanceEnabled => $composableBuilder(
    column: $table.distanceEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceText => $composableBuilder(
    column: $table.distanceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RelationshipSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipSettingsTableTable> {
  $$RelationshipSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loveStartDate => $composableBuilder(
    column: $table.loveStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loveDaysOverride => $composableBuilder(
    column: $table.loveDaysOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get distanceEnabled => $composableBuilder(
    column: $table.distanceEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceText => $composableBuilder(
    column: $table.distanceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RelationshipSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipSettingsTableTable> {
  $$RelationshipSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loveStartDate => $composableBuilder(
    column: $table.loveStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loveDaysOverride => $composableBuilder(
    column: $table.loveDaysOverride,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get distanceEnabled => $composableBuilder(
    column: $table.distanceEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distanceText => $composableBuilder(
    column: $table.distanceText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RelationshipSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipSettingsTableTable,
          RelationshipSettingsTableData,
          $$RelationshipSettingsTableTableFilterComposer,
          $$RelationshipSettingsTableTableOrderingComposer,
          $$RelationshipSettingsTableTableAnnotationComposer,
          $$RelationshipSettingsTableTableCreateCompanionBuilder,
          $$RelationshipSettingsTableTableUpdateCompanionBuilder,
          (
            RelationshipSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $RelationshipSettingsTableTable,
              RelationshipSettingsTableData
            >,
          ),
          RelationshipSettingsTableData,
          PrefetchHooks Function()
        > {
  $$RelationshipSettingsTableTableTableManager(
    _$AppDatabase db,
    $RelationshipSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipSettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RelationshipSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RelationshipSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime?> loveStartDate = const Value.absent(),
                Value<int?> loveDaysOverride = const Value.absent(),
                Value<bool> distanceEnabled = const Value.absent(),
                Value<String?> distanceText = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipSettingsTableCompanion(
                id: id,
                loveStartDate: loveStartDate,
                loveDaysOverride: loveDaysOverride,
                distanceEnabled: distanceEnabled,
                distanceText: distanceText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime?> loveStartDate = const Value.absent(),
                Value<int?> loveDaysOverride = const Value.absent(),
                Value<bool> distanceEnabled = const Value.absent(),
                Value<String?> distanceText = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RelationshipSettingsTableCompanion.insert(
                id: id,
                loveStartDate: loveStartDate,
                loveDaysOverride: loveDaysOverride,
                distanceEnabled: distanceEnabled,
                distanceText: distanceText,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RelationshipSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipSettingsTableTable,
      RelationshipSettingsTableData,
      $$RelationshipSettingsTableTableFilterComposer,
      $$RelationshipSettingsTableTableOrderingComposer,
      $$RelationshipSettingsTableTableAnnotationComposer,
      $$RelationshipSettingsTableTableCreateCompanionBuilder,
      $$RelationshipSettingsTableTableUpdateCompanionBuilder,
      (
        RelationshipSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $RelationshipSettingsTableTable,
          RelationshipSettingsTableData
        >,
      ),
      RelationshipSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$CoursesTableTableCreateCompanionBuilder =
    CoursesTableCompanion Function({
      required String id,
      required String title,
      required int weekday,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<int> startWeek,
      Value<int> endWeek,
      Value<bool> repeatWeekly,
      required int startPeriod,
      required int endPeriod,
      required String location,
      required String teacher,
      Value<String> note,
      required String owner,
      required String colorHex,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CoursesTableTableUpdateCompanionBuilder =
    CoursesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> weekday,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<int> startWeek,
      Value<int> endWeek,
      Value<bool> repeatWeekly,
      Value<int> startPeriod,
      Value<int> endPeriod,
      Value<String> location,
      Value<String> teacher,
      Value<String> note,
      Value<String> owner,
      Value<String> colorHex,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CoursesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTableTable> {
  $$CoursesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get startWeek =>
      $composableBuilder(column: $table.startWeek, builder: (column) => column);

  GeneratedColumn<int> get endWeek =>
      $composableBuilder(column: $table.endWeek, builder: (column) => column);

  GeneratedColumn<bool> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endPeriod =>
      $composableBuilder(column: $table.endPeriod, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CoursesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTableTable,
          CoursesTableData,
          $$CoursesTableTableFilterComposer,
          $$CoursesTableTableOrderingComposer,
          $$CoursesTableTableAnnotationComposer,
          $$CoursesTableTableCreateCompanionBuilder,
          $$CoursesTableTableUpdateCompanionBuilder,
          (
            CoursesTableData,
            BaseReferences<_$AppDatabase, $CoursesTableTable, CoursesTableData>,
          ),
          CoursesTableData,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableTableManager(_$AppDatabase db, $CoursesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> startWeek = const Value.absent(),
                Value<int> endWeek = const Value.absent(),
                Value<bool> repeatWeekly = const Value.absent(),
                Value<int> startPeriod = const Value.absent(),
                Value<int> endPeriod = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> teacher = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesTableCompanion(
                id: id,
                title: title,
                weekday: weekday,
                startMinute: startMinute,
                endMinute: endMinute,
                startWeek: startWeek,
                endWeek: endWeek,
                repeatWeekly: repeatWeekly,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                location: location,
                teacher: teacher,
                note: note,
                owner: owner,
                colorHex: colorHex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int weekday,
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> startWeek = const Value.absent(),
                Value<int> endWeek = const Value.absent(),
                Value<bool> repeatWeekly = const Value.absent(),
                required int startPeriod,
                required int endPeriod,
                required String location,
                required String teacher,
                Value<String> note = const Value.absent(),
                required String owner,
                required String colorHex,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CoursesTableCompanion.insert(
                id: id,
                title: title,
                weekday: weekday,
                startMinute: startMinute,
                endMinute: endMinute,
                startWeek: startWeek,
                endWeek: endWeek,
                repeatWeekly: repeatWeekly,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                location: location,
                teacher: teacher,
                note: note,
                owner: owner,
                colorHex: colorHex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTableTable,
      CoursesTableData,
      $$CoursesTableTableFilterComposer,
      $$CoursesTableTableOrderingComposer,
      $$CoursesTableTableAnnotationComposer,
      $$CoursesTableTableCreateCompanionBuilder,
      $$CoursesTableTableUpdateCompanionBuilder,
      (
        CoursesTableData,
        BaseReferences<_$AppDatabase, $CoursesTableTable, CoursesTableData>,
      ),
      CoursesTableData,
      PrefetchHooks Function()
    >;
typedef $$SongsTableTableCreateCompanionBuilder =
    SongsTableCompanion Function({
      required String id,
      required String name,
      required String artist,
      required DateTime createdAt,
      required String preference,
      Value<int> rowid,
    });
typedef $$SongsTableTableUpdateCompanionBuilder =
    SongsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> artist,
      Value<DateTime> createdAt,
      Value<String> preference,
      Value<int> rowid,
    });

class $$SongsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preference => $composableBuilder(
    column: $table.preference,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preference => $composableBuilder(
    column: $table.preference,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTableTable> {
  $$SongsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get preference => $composableBuilder(
    column: $table.preference,
    builder: (column) => column,
  );
}

class $$SongsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTableTable,
          SongsTableData,
          $$SongsTableTableFilterComposer,
          $$SongsTableTableOrderingComposer,
          $$SongsTableTableAnnotationComposer,
          $$SongsTableTableCreateCompanionBuilder,
          $$SongsTableTableUpdateCompanionBuilder,
          (
            SongsTableData,
            BaseReferences<_$AppDatabase, $SongsTableTable, SongsTableData>,
          ),
          SongsTableData,
          PrefetchHooks Function()
        > {
  $$SongsTableTableTableManager(_$AppDatabase db, $SongsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> preference = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion(
                id: id,
                name: name,
                artist: artist,
                createdAt: createdAt,
                preference: preference,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String artist,
                required DateTime createdAt,
                required String preference,
                Value<int> rowid = const Value.absent(),
              }) => SongsTableCompanion.insert(
                id: id,
                name: name,
                artist: artist,
                createdAt: createdAt,
                preference: preference,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTableTable,
      SongsTableData,
      $$SongsTableTableFilterComposer,
      $$SongsTableTableOrderingComposer,
      $$SongsTableTableAnnotationComposer,
      $$SongsTableTableCreateCompanionBuilder,
      $$SongsTableTableUpdateCompanionBuilder,
      (
        SongsTableData,
        BaseReferences<_$AppDatabase, $SongsTableTable, SongsTableData>,
      ),
      SongsTableData,
      PrefetchHooks Function()
    >;
typedef $$SongReviewsTableTableCreateCompanionBuilder =
    SongReviewsTableCompanion Function({
      required String id,
      required String songId,
      required String author,
      required String content,
      Value<int> atmosphereScore,
      Value<int> resonanceScore,
      Value<int> shareScore,
      Value<String> styleTags,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SongReviewsTableTableUpdateCompanionBuilder =
    SongReviewsTableCompanion Function({
      Value<String> id,
      Value<String> songId,
      Value<String> author,
      Value<String> content,
      Value<int> atmosphereScore,
      Value<int> resonanceScore,
      Value<int> shareScore,
      Value<String> styleTags,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SongReviewsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SongReviewsTableTable> {
  $$SongReviewsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atmosphereScore => $composableBuilder(
    column: $table.atmosphereScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resonanceScore => $composableBuilder(
    column: $table.resonanceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shareScore => $composableBuilder(
    column: $table.shareScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SongReviewsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SongReviewsTableTable> {
  $$SongReviewsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atmosphereScore => $composableBuilder(
    column: $table.atmosphereScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resonanceScore => $composableBuilder(
    column: $table.resonanceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shareScore => $composableBuilder(
    column: $table.shareScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongReviewsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongReviewsTableTable> {
  $$SongReviewsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get atmosphereScore => $composableBuilder(
    column: $table.atmosphereScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resonanceScore => $composableBuilder(
    column: $table.resonanceScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shareScore => $composableBuilder(
    column: $table.shareScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get styleTags =>
      $composableBuilder(column: $table.styleTags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SongReviewsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongReviewsTableTable,
          SongReviewsTableData,
          $$SongReviewsTableTableFilterComposer,
          $$SongReviewsTableTableOrderingComposer,
          $$SongReviewsTableTableAnnotationComposer,
          $$SongReviewsTableTableCreateCompanionBuilder,
          $$SongReviewsTableTableUpdateCompanionBuilder,
          (
            SongReviewsTableData,
            BaseReferences<
              _$AppDatabase,
              $SongReviewsTableTable,
              SongReviewsTableData
            >,
          ),
          SongReviewsTableData,
          PrefetchHooks Function()
        > {
  $$SongReviewsTableTableTableManager(
    _$AppDatabase db,
    $SongReviewsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongReviewsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongReviewsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongReviewsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> atmosphereScore = const Value.absent(),
                Value<int> resonanceScore = const Value.absent(),
                Value<int> shareScore = const Value.absent(),
                Value<String> styleTags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongReviewsTableCompanion(
                id: id,
                songId: songId,
                author: author,
                content: content,
                atmosphereScore: atmosphereScore,
                resonanceScore: resonanceScore,
                shareScore: shareScore,
                styleTags: styleTags,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String songId,
                required String author,
                required String content,
                Value<int> atmosphereScore = const Value.absent(),
                Value<int> resonanceScore = const Value.absent(),
                Value<int> shareScore = const Value.absent(),
                Value<String> styleTags = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SongReviewsTableCompanion.insert(
                id: id,
                songId: songId,
                author: author,
                content: content,
                atmosphereScore: atmosphereScore,
                resonanceScore: resonanceScore,
                shareScore: shareScore,
                styleTags: styleTags,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SongReviewsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongReviewsTableTable,
      SongReviewsTableData,
      $$SongReviewsTableTableFilterComposer,
      $$SongReviewsTableTableOrderingComposer,
      $$SongReviewsTableTableAnnotationComposer,
      $$SongReviewsTableTableCreateCompanionBuilder,
      $$SongReviewsTableTableUpdateCompanionBuilder,
      (
        SongReviewsTableData,
        BaseReferences<
          _$AppDatabase,
          $SongReviewsTableTable,
          SongReviewsTableData
        >,
      ),
      SongReviewsTableData,
      PrefetchHooks Function()
    >;
typedef $$TodosTableTableCreateCompanionBuilder =
    TodosTableCompanion Function({
      required String id,
      Value<String> coupleId,
      required String title,
      required String description,
      Value<DateTime?> dueAt,
      required String owner,
      required DateTime createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$TodosTableTableUpdateCompanionBuilder =
    TodosTableCompanion Function({
      Value<String> id,
      Value<String> coupleId,
      Value<String> title,
      Value<String> description,
      Value<DateTime?> dueAt,
      Value<String> owner,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$TodosTableTableFilterComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTableTable> {
  $$TodosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$TodosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodosTableTable,
          TodosTableData,
          $$TodosTableTableFilterComposer,
          $$TodosTableTableOrderingComposer,
          $$TodosTableTableAnnotationComposer,
          $$TodosTableTableCreateCompanionBuilder,
          $$TodosTableTableUpdateCompanionBuilder,
          (
            TodosTableData,
            BaseReferences<_$AppDatabase, $TodosTableTable, TodosTableData>,
          ),
          TodosTableData,
          PrefetchHooks Function()
        > {
  $$TodosTableTableTableManager(_$AppDatabase db, $TodosTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> coupleId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosTableCompanion(
                id: id,
                coupleId: coupleId,
                title: title,
                description: description,
                dueAt: dueAt,
                owner: owner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> coupleId = const Value.absent(),
                required String title,
                required String description,
                Value<DateTime?> dueAt = const Value.absent(),
                required String owner,
                required DateTime createdAt,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosTableCompanion.insert(
                id: id,
                coupleId: coupleId,
                title: title,
                description: description,
                dueAt: dueAt,
                owner: owner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodosTableTable,
      TodosTableData,
      $$TodosTableTableFilterComposer,
      $$TodosTableTableOrderingComposer,
      $$TodosTableTableAnnotationComposer,
      $$TodosTableTableCreateCompanionBuilder,
      $$TodosTableTableUpdateCompanionBuilder,
      (
        TodosTableData,
        BaseReferences<_$AppDatabase, $TodosTableTable, TodosTableData>,
      ),
      TodosTableData,
      PrefetchHooks Function()
    >;
typedef $$TodoProgressTableTableCreateCompanionBuilder =
    TodoProgressTableCompanion Function({
      required String todoId,
      Value<bool> meDone,
      Value<bool> partnerDone,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TodoProgressTableTableUpdateCompanionBuilder =
    TodoProgressTableCompanion Function({
      Value<String> todoId,
      Value<bool> meDone,
      Value<bool> partnerDone,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TodoProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $TodoProgressTableTable> {
  $$TodoProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get meDone => $composableBuilder(
    column: $table.meDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get partnerDone => $composableBuilder(
    column: $table.partnerDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoProgressTableTable> {
  $$TodoProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get meDone => $composableBuilder(
    column: $table.meDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get partnerDone => $composableBuilder(
    column: $table.partnerDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoProgressTableTable> {
  $$TodoProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<bool> get meDone =>
      $composableBuilder(column: $table.meDone, builder: (column) => column);

  GeneratedColumn<bool> get partnerDone => $composableBuilder(
    column: $table.partnerDone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TodoProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoProgressTableTable,
          TodoProgressTableData,
          $$TodoProgressTableTableFilterComposer,
          $$TodoProgressTableTableOrderingComposer,
          $$TodoProgressTableTableAnnotationComposer,
          $$TodoProgressTableTableCreateCompanionBuilder,
          $$TodoProgressTableTableUpdateCompanionBuilder,
          (
            TodoProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $TodoProgressTableTable,
              TodoProgressTableData
            >,
          ),
          TodoProgressTableData,
          PrefetchHooks Function()
        > {
  $$TodoProgressTableTableTableManager(
    _$AppDatabase db,
    $TodoProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoProgressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> todoId = const Value.absent(),
                Value<bool> meDone = const Value.absent(),
                Value<bool> partnerDone = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoProgressTableCompanion(
                todoId: todoId,
                meDone: meDone,
                partnerDone: partnerDone,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String todoId,
                Value<bool> meDone = const Value.absent(),
                Value<bool> partnerDone = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TodoProgressTableCompanion.insert(
                todoId: todoId,
                meDone: meDone,
                partnerDone: partnerDone,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoProgressTableTable,
      TodoProgressTableData,
      $$TodoProgressTableTableFilterComposer,
      $$TodoProgressTableTableOrderingComposer,
      $$TodoProgressTableTableAnnotationComposer,
      $$TodoProgressTableTableCreateCompanionBuilder,
      $$TodoProgressTableTableUpdateCompanionBuilder,
      (
        TodoProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $TodoProgressTableTable,
          TodoProgressTableData
        >,
      ),
      TodoProgressTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatMessagesTableTableTableManager get chatMessagesTable =>
      $$ChatMessagesTableTableTableManager(_db, _db.chatMessagesTable);
  $$BillRecordsTableTableTableManager get billRecordsTable =>
      $$BillRecordsTableTableTableManager(_db, _db.billRecordsTable);
  $$CountdownEventsTableTableTableManager get countdownEventsTable =>
      $$CountdownEventsTableTableTableManager(_db, _db.countdownEventsTable);
  $$PokeEventsTableTableTableManager get pokeEventsTable =>
      $$PokeEventsTableTableTableManager(_db, _db.pokeEventsTable);
  $$FeedEventsTableTableTableManager get feedEventsTable =>
      $$FeedEventsTableTableTableManager(_db, _db.feedEventsTable);
  $$LocalUserProfileTableTableTableManager get localUserProfileTable =>
      $$LocalUserProfileTableTableTableManager(_db, _db.localUserProfileTable);
  $$LocalCoupleProfileTableTableTableManager get localCoupleProfileTable =>
      $$LocalCoupleProfileTableTableTableManager(
        _db,
        _db.localCoupleProfileTable,
      );
  $$RelationshipSettingsTableTableTableManager get relationshipSettingsTable =>
      $$RelationshipSettingsTableTableTableManager(
        _db,
        _db.relationshipSettingsTable,
      );
  $$CoursesTableTableTableManager get coursesTable =>
      $$CoursesTableTableTableManager(_db, _db.coursesTable);
  $$SongsTableTableTableManager get songsTable =>
      $$SongsTableTableTableManager(_db, _db.songsTable);
  $$SongReviewsTableTableTableManager get songReviewsTable =>
      $$SongReviewsTableTableTableManager(_db, _db.songReviewsTable);
  $$TodosTableTableTableManager get todosTable =>
      $$TodosTableTableTableManager(_db, _db.todosTable);
  $$TodoProgressTableTableTableManager get todoProgressTable =>
      $$TodoProgressTableTableTableManager(_db, _db.todoProgressTable);
}

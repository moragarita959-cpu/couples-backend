import 'dart:convert';
import 'dart:io';
import 'dart:math';

class ApiClient {
  ApiClient()
    : _baseUrl = const String.fromEnvironment(
        'COUPLES_API_BASE_URL',
        defaultValue: '',
      );

  final String _baseUrl;
  final Random _random = Random();

  bool get _usesHttpBackend => _baseUrl.trim().isNotEmpty;

  Future<Map<String, dynamic>> bootstrapUser({
    required String userId,
    required String nickname,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/bootstrap-user', <String, dynamic>{
        'userId': userId,
        'nickname': nickname,
      });
      return _extractObject(data);
    }

    return _withFakeStore((store) {
      final users = _readUsers(store);
      final now = DateTime.now().toUtc().toIso8601String();
      final existingIndex = users.indexWhere((item) => item['id'] == userId);

      if (existingIndex >= 0) {
        final updated = <String, dynamic>{
          ...users[existingIndex],
          'nickname': nickname.trim(),
          'updatedAt': now,
        };
        users[existingIndex] = updated;
        store['users'] = users;
        return updated;
      }

      final created = <String, dynamic>{
        'id': userId,
        'nickname': nickname.trim(),
        'pairCode': _generatePairCode(users),
        'coupleId': null,
        'createdAt': now,
        'updatedAt': now,
      };
      users.add(created);
      store['users'] = users;
      return created;
    });
  }

  Future<Map<String, dynamic>> bindCoupleByPairCode({
    required String currentUserId,
    required String targetPairCode,
  }) async {
    if (_usesHttpBackend) {
      final data =
          await _postJson('/bind-couple-by-pair-code', <String, dynamic>{
            'currentUserId': currentUserId,
            'targetPairCode': targetPairCode.trim().toUpperCase(),
          });
      return _extractObject(data);
    }

    return _withFakeStore((store) {
      final users = _readUsers(store);
      final couples = _readCouples(store);
      final currentIndex = users.indexWhere(
        (item) => item['id'] == currentUserId,
      );
      if (currentIndex < 0) {
        throw const ApiClientException('auth_required');
      }

      final currentUser = users[currentIndex];
      if ((currentUser['coupleId'] as String?)?.isNotEmpty ?? false) {
        throw const ApiClientException('current_user_already_bound');
      }

      final normalizedPairCode = targetPairCode.trim().toUpperCase();
      final targetIndex = users.indexWhere(
        (item) =>
            (item['pairCode'] as String).toUpperCase() == normalizedPairCode,
      );
      if (targetIndex < 0) {
        throw const ApiClientException('invalid_pair_code');
      }

      final targetUser = users[targetIndex];
      if (targetUser['id'] == currentUserId) {
        throw const ApiClientException('cannot_bind_self');
      }
      if ((targetUser['coupleId'] as String?)?.isNotEmpty ?? false) {
        throw const ApiClientException('target_user_already_bound');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final coupleId = 'couple-${DateTime.now().microsecondsSinceEpoch}';
      final couple = <String, dynamic>{
        'id': coupleId,
        'userIds': <String>[currentUserId, targetUser['id'] as String],
        'createdAt': now,
        'status': 'active',
      };
      couples.add(couple);

      users[currentIndex] = <String, dynamic>{
        ...currentUser,
        'coupleId': coupleId,
        'updatedAt': now,
      };
      users[targetIndex] = <String, dynamic>{
        ...targetUser,
        'coupleId': coupleId,
        'updatedAt': now,
      };

      store['users'] = users;
      store['couples'] = couples;

      return <String, dynamic>{
        'coupleId': coupleId,
        'createdAt': now,
        'updatedAt': now,
        'currentUser': <String, dynamic>{
          'id': users[currentIndex]['id'],
          'nickname': users[currentIndex]['nickname'],
        },
        'partner': <String, dynamic>{
          'id': users[targetIndex]['id'],
          'nickname': users[targetIndex]['nickname'],
        },
      };
    });
  }

  Future<List<Map<String, dynamic>>> listChatMessages({
    required String coupleId,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/chat/list', <String, dynamic>{
        'coupleId': coupleId,
      });
      return _extractList(data);
    }

    return _withFakeStore((store) {
      final messages = _readMessages(store)
          .where((item) => item['coupleId'] == coupleId)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      messages.sort((a, b) {
        final byTime = (a['createdAt'] as String).compareTo(
          b['createdAt'] as String,
        );
        if (byTime != 0) {
          return byTime;
        }
        return (a['id'] as String).compareTo(b['id'] as String);
      });
      return messages;
    });
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String coupleId,
    required String senderUserId,
    required String content,
    required String clientMessageId,
    String messageType = 'text',
    String? mediaUrl,
    int? mediaDurationMs,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/chat/send', <String, dynamic>{
        'coupleId': coupleId,
        'senderUserId': senderUserId,
        'content': content,
        'clientMessageId': clientMessageId,
        'messageType': messageType,
        'mediaUrl': mediaUrl,
        'mediaDurationMs': mediaDurationMs,
      });
      return _extractObject(data);
    }

    return _withFakeStore((store) {
      final couples = _readCouples(store);
      final couple = couples.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == coupleId,
        orElse: () => <String, dynamic>{},
      );
      if (couple.isEmpty) {
        throw const ApiClientException('couple_not_found');
      }
      final userIds = List<String>.from(couple['userIds'] as List<dynamic>);
      if (!userIds.contains(senderUserId)) {
        throw const ApiClientException('forbidden_sender');
      }

      final messages = _readMessages(store);
      final existingIndex = messages.indexWhere(
        (item) => item['clientMessageId'] == clientMessageId,
      );
      if (existingIndex >= 0) {
        return messages[existingIndex];
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final created = <String, dynamic>{
        'id':
            'msg-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9000) + 1000}',
        'coupleId': coupleId,
        'senderUserId': senderUserId,
        'content': content,
        'clientMessageId': clientMessageId,
        'messageType': messageType,
        'mediaUrl': mediaUrl,
        'mediaDurationMs': mediaDurationMs,
        'createdAt': now,
      };
      messages.add(created);
      store['chatMessages'] = messages;
      return created;
    });
  }

  Future<String> uploadChatImage({
    required String coupleId,
    required String senderUserId,
    required String sourcePath,
  }) async {
    if (_usesHttpBackend) {
      final payload = await _postJson('/chat/upload-image', <String, dynamic>{
        'coupleId': coupleId,
        'senderUserId': senderUserId,
        'fileName': _extractFileName(sourcePath),
        'fileBytesBase64': await _encodeFileAsBase64(sourcePath),
      });
      final data = _extractObject(payload);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ApiClientException('invalid_upload_response');
      }
      return url;
    }

    return _copyToFakeCloudMedia(
      coupleId: coupleId,
      senderUserId: senderUserId,
      sourcePath: sourcePath,
      folderName: 'images',
    );
  }

  Future<String> uploadChatVoice({
    required String coupleId,
    required String senderUserId,
    required String sourcePath,
  }) async {
    if (_usesHttpBackend) {
      final payload = await _postJson('/chat/upload-voice', <String, dynamic>{
        'coupleId': coupleId,
        'senderUserId': senderUserId,
        'fileName': _extractFileName(sourcePath),
        'fileBytesBase64': await _encodeFileAsBase64(sourcePath),
      });
      final data = _extractObject(payload);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ApiClientException('invalid_upload_response');
      }
      return url;
    }

    return _copyToFakeCloudMedia(
      coupleId: coupleId,
      senderUserId: senderUserId,
      sourcePath: sourcePath,
      folderName: 'voice',
    );
  }

  Future<void> setChatTypingStatus({
    required String coupleId,
    required String userId,
    required bool isTyping,
  }) async {
    if (_usesHttpBackend) {
      await _postJson('/chat/typing/set', <String, dynamic>{
        'coupleId': coupleId,
        'userId': userId,
        'isTyping': isTyping,
      });
      return;
    }

    await _withFakeStore<void>((store) {
      final typing = _readTypingStatuses(store);
      final now = DateTime.now().toUtc().toIso8601String();
      final key = '$coupleId::$userId';
      final index = typing.indexWhere((item) => item['key'] == key);
      final payload = <String, dynamic>{
        'key': key,
        'coupleId': coupleId,
        'userId': userId,
        'isTyping': isTyping,
        'updatedAt': now,
      };
      if (index >= 0) {
        typing[index] = payload;
      } else {
        typing.add(payload);
      }
      store['chatTyping'] = typing;
    });
  }

  Future<bool> getChatTypingStatus({
    required String coupleId,
    required String currentUserId,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/chat/typing/get', <String, dynamic>{
        'coupleId': coupleId,
        'currentUserId': currentUserId,
      });
      if (data is Map<String, dynamic> && data['isTyping'] is bool) {
        return data['isTyping'] as bool;
      }
      final payload = _extractObject(data);
      return payload['isTyping'] == true;
    }

    return _withFakeStore<bool>((store) {
      final typing = _readTypingStatuses(store);
      final now = DateTime.now().toUtc();
      for (final item in typing) {
        if (item['coupleId'] != coupleId || item['userId'] == currentUserId) {
          continue;
        }
        if (item['isTyping'] != true) {
          continue;
        }
        final updatedAtRaw = item['updatedAt'] as String?;
        if (updatedAtRaw == null) {
          continue;
        }
        final updatedAt = DateTime.tryParse(updatedAtRaw);
        if (updatedAt == null) {
          continue;
        }
        if (now.difference(updatedAt).inSeconds <= 5) {
          return true;
        }
      }
      return false;
    });
  }

  Future<List<Map<String, dynamic>>> listTodoItems({
    required String coupleId,
    required String currentUserId,
    DateTime? since,
  }) async {
    final payload = await _postJson('/todo/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'since': since?.toUtc().toIso8601String(),
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertTodoItem(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/todo/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteTodoItem({
    required String coupleId,
    required String id,
    required DateTime updatedAt,
  }) async {
    await _postJson('/todo/delete', <String, dynamic>{
      'coupleId': coupleId,
      'id': id,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> listBillRecords({
    required String coupleId,
    DateTime? since,
  }) async {
    final payload = await _postJson('/bill/list', <String, dynamic>{
      'coupleId': coupleId,
      'since': since?.toUtc().toIso8601String(),
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertBillRecord(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/bill/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteBillRecord({
    required String coupleId,
    required String id,
    required DateTime updatedAt,
  }) async {
    await _postJson('/bill/delete', <String, dynamic>{
      'coupleId': coupleId,
      'id': id,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> listCountdownEvents({
    required String coupleId,
    DateTime? since,
  }) async {
    final payload = await _postJson('/countdown/list', <String, dynamic>{
      'coupleId': coupleId,
      'since': since?.toUtc().toIso8601String(),
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertCountdownEvent(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/countdown/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteCountdownEvent({
    required String coupleId,
    required String id,
    required DateTime updatedAt,
  }) async {
    await _postJson('/countdown/delete', <String, dynamic>{
      'coupleId': coupleId,
      'id': id,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> listPlaylistSongs({
    required String coupleId,
  }) async {
    final payload = await _postJson('/playlist/songs/list', <String, dynamic>{
      'coupleId': coupleId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertPlaylistSong(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/playlist/songs/upsert', body);
    return _extractObject(payload);
  }

  Future<List<Map<String, dynamic>>> listPlaylistReviews({
    required String coupleId,
    required String songId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/playlist/reviews/list', <String, dynamic>{
      'coupleId': coupleId,
      'songId': songId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertPlaylistReview(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/playlist/reviews/upsert', body);
    return _extractObject(payload);
  }

  Future<List<Map<String, dynamic>>> listPokeEvents({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/poke/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> sendPoke({
    required String coupleId,
    required String currentUserId,
    required String message,
  }) async {
    final payload = await _postJson('/poke/send', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'message': message,
    });
    return _extractObject(payload);
  }

  Future<List<Map<String, dynamic>>> listScheduleCourses({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/schedule/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertScheduleCourse(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/schedule/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteScheduleCourse({
    required String coupleId,
    required String id,
  }) async {
    await _postJson('/schedule/delete', <String, dynamic>{
      'coupleId': coupleId,
      'id': id,
    });
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl$path'));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiClientException(
          responseBody.isEmpty ? 'http_error' : responseBody,
        );
      }
      if (responseBody.isEmpty) {
        return null;
      }
      return jsonDecode(responseBody);
    } finally {
      client.close();
    }
  }

  Future<T> _withFakeStore<T>(
    T Function(Map<String, dynamic> store) action,
  ) async {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}couples_flutter_fake_cloud.json',
    );
    if (!await file.exists()) {
      await file.writeAsString(
        jsonEncode(<String, dynamic>{
          'users': <Map<String, dynamic>>[],
          'couples': <Map<String, dynamic>>[],
          'chatMessages': <Map<String, dynamic>>[],
          'chatTyping': <Map<String, dynamic>>[],
        }),
      );
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final store = <String, dynamic>{
      'users': List<Map<String, dynamic>>.from(
        (decoded['users'] as List<dynamic>? ?? <dynamic>[]).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      'couples': List<Map<String, dynamic>>.from(
        (decoded['couples'] as List<dynamic>? ?? <dynamic>[]).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      'chatMessages': List<Map<String, dynamic>>.from(
        (decoded['chatMessages'] as List<dynamic>? ?? <dynamic>[]).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
      'chatTyping': List<Map<String, dynamic>>.from(
        (decoded['chatTyping'] as List<dynamic>? ?? <dynamic>[]).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      ),
    };

    final result = action(store);
    await file.writeAsString(jsonEncode(store));
    return result;
  }

  List<Map<String, dynamic>> _readUsers(Map<String, dynamic> store) {
    return List<Map<String, dynamic>>.from(store['users'] as List<dynamic>);
  }

  List<Map<String, dynamic>> _readCouples(Map<String, dynamic> store) {
    return List<Map<String, dynamic>>.from(store['couples'] as List<dynamic>);
  }

  List<Map<String, dynamic>> _readMessages(Map<String, dynamic> store) {
    return List<Map<String, dynamic>>.from(
      store['chatMessages'] as List<dynamic>,
    );
  }

  List<Map<String, dynamic>> _readTypingStatuses(Map<String, dynamic> store) {
    return List<Map<String, dynamic>>.from(
      store['chatTyping'] as List<dynamic>,
    );
  }

  String _generatePairCode(List<Map<String, dynamic>> users) {
    String nextCode() {
      final value = _random.nextInt(899999) + 100000;
      return value.toString();
    }

    var code = nextCode();
    while (users.any((item) => item['pairCode'] == code)) {
      code = nextCode();
    }
    return code;
  }

  Future<String> _encodeFileAsBase64(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      throw const ApiClientException('file_not_found');
    }
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> _copyToFakeCloudMedia({
    required String coupleId,
    required String senderUserId,
    required String sourcePath,
    required String folderName,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const ApiClientException('file_not_found');
    }

    final targetDirectory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}couples_flutter_fake_cloud_media${Platform.pathSeparator}$coupleId${Platform.pathSeparator}$folderName',
    );
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final extension = _extractFileExtension(sourcePath);
    final targetPath =
        '${targetDirectory.path}${Platform.pathSeparator}$senderUserId-${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '' : '.$extension'}';
    final copied = await sourceFile.copy(targetPath);
    return copied.path;
  }

  String _extractFileName(String path) {
    final separatorIndex = path.lastIndexOf(RegExp(r'[\\/]'));
    if (separatorIndex < 0 || separatorIndex + 1 >= path.length) {
      return path;
    }
    return path.substring(separatorIndex + 1);
  }

  String _extractFileExtension(String path) {
    final fileName = _extractFileName(path);
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex + 1 >= fileName.length) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  Map<String, dynamic> _extractObject(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          payload['data'] as Map<String, dynamic>,
        );
      }
      return payload;
    }
    throw const ApiClientException('invalid_response');
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is List<dynamic>) {
      return List<Map<String, dynamic>>.from(
        (payload['data'] as List<dynamic>).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
    }
    if (payload is List<dynamic>) {
      return List<Map<String, dynamic>>.from(
        payload.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    }
    throw const ApiClientException('invalid_response');
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.code);

  final String code;

  @override
  String toString() => code;
}

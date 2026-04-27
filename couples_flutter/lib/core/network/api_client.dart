import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'fake_cloud_store.dart';

class ApiClient {
  ApiClient()
    : _baseUrl = const String.fromEnvironment(
        'COUPLES_API_BASE_URL',
        defaultValue: '',
      );

  final String _baseUrl;
  final Random _random = Random();

  bool get _usesHttpBackend => _baseUrl.trim().isNotEmpty;
  bool get usesHttpBackend => _usesHttpBackend;
  bool get _baseUrlHasApiSuffix {
    final trimmed = _baseUrl.trim().toLowerCase();
    return trimmed.endsWith('/api');
  }

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

    return runWithFakeStore((store) {
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

    return runWithFakeStore((store) {
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

  /// Other member's user id for [coupleId], when local profile has no partner id.
  Future<String?> fetchPartnerUserId({
    required String coupleId,
    required String currentUserId,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/couple/partner-id', <String, dynamic>{
        'coupleId': coupleId.trim(),
        'currentUserId': currentUserId.trim(),
      });
      final obj = _extractObject(data);
      final raw = obj['partnerUserId']?.toString().trim();
      return raw != null && raw.isNotEmpty ? raw : null;
    }

    return runWithFakeStore((store) {
      final couples = _readCouples(store);
      final cid = coupleId.trim();
      final me = currentUserId.trim();
      if (cid.isEmpty || me.isEmpty) {
        throw const ApiClientException('invalid_request');
      }
      final couple = couples.cast<Map<String, dynamic>>().firstWhere(
        (item) => item['id'] == cid,
        orElse: () => <String, dynamic>{},
      );
      if (couple.isEmpty) {
        throw const ApiClientException('couple_not_found');
      }
      final status = (couple['status'] as String?)?.trim() ?? 'active';
      if (status != 'active') {
        throw const ApiClientException('couple_not_found');
      }
      final userIds = couple['userIds'];
      if (userIds is! List<dynamic> || userIds.length < 2) {
        throw const ApiClientException('couple_not_found');
      }
      final ids = userIds.map((e) => e.toString()).toList();
      if (!ids.contains(me)) {
        throw const ApiClientException('forbidden');
      }
      final partner = ids.firstWhere((id) => id != me, orElse: () => '');
      return partner.isEmpty ? null : partner;
    });
  }

  Future<List<Map<String, dynamic>>> listChatMessages({
    required String coupleId,
    DateTime? since,
  }) async {
    if (_usesHttpBackend) {
      final data = await _postJson('/chat/list', <String, dynamic>{
        'coupleId': coupleId,
        'since': since?.toUtc().toIso8601String(),
      });
      return _extractList(data);
    }

    return runWithFakeStore((store) {
      final messages = _readMessages(store)
          .where((item) => item['coupleId'] == coupleId)
          .where((item) {
            if (since == null) {
              return true;
            }
            final createdAtRaw = item['createdAt'] as String?;
            final createdAt = createdAtRaw == null
                ? null
                : DateTime.tryParse(createdAtRaw);
            if (createdAt == null) {
              return false;
            }
            return createdAt.isAfter(since.toUtc());
          })
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

    return runWithFakeStore((store) {
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
      final url = _resolveUploadedMediaUrl(data);
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
      final url = _resolveUploadedMediaUrl(data);
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

    await runWithFakeStore<void>((store) {
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

    return runWithFakeStore<bool>((store) {
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

  Future<void> registerChatPushToken({
    required String coupleId,
    required String userId,
    required String token,
    required String platform,
  }) async {
    if (!_usesHttpBackend) {
      return;
    }
    await _postJson('/chat/push/register-token', <String, dynamic>{
      'coupleId': coupleId,
      'userId': userId,
      'token': token,
      'platform': platform,
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

  Future<Map<String, dynamic>> upsertTodoItem(Map<String, dynamic> body) async {
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
    required String actorUserId,
  }) async {
    await _postJson('/bill/delete', <String, dynamic>{
      'coupleId': coupleId,
      'id': id,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'actorUserId': actorUserId,
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
    required String currentUserId,
  }) async {
    if (!_usesHttpBackend) {
      return runWithFakeStore((store) {
        final songs = _readPlaylistSongs(store)
            .where(
              (item) =>
                  item['coupleId'] == coupleId && item['isDeleted'] != true,
            )
            .map((item) => _playlistSongForUser(item, currentUserId))
            .toList();
        songs.sort((a, b) {
          final byTime = (b['createdAt'] as String).compareTo(
            a['createdAt'] as String,
          );
          if (byTime != 0) {
            return byTime;
          }
          return (b['id'] as String).compareTo(a['id'] as String);
        });
        return songs;
      });
    }

    final payload = await _postJson('/playlist/songs/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertPlaylistSong(
    Map<String, dynamic> body,
  ) async {
    if (!_usesHttpBackend) {
      return runWithFakeStore((store) {
        final songs = _readPlaylistSongs(store);
        final coupleId = (body['coupleId'] ?? '').toString().trim();
        final currentUserId = (body['currentUserId'] ?? '').toString().trim();
        final id = (body['id'] ?? '').toString().trim();
        final name = (body['name'] ?? '').toString().trim();
        final artist = (body['artist'] ?? '').toString().trim();
        if (coupleId.isEmpty ||
            currentUserId.isEmpty ||
            id.isEmpty ||
            name.isEmpty ||
            artist.isEmpty) {
          throw const ApiClientException('invalid_request');
        }

        final existingIndex = songs.indexWhere(
          (item) => item['id'] == id && item['coupleId'] == coupleId,
        );
        if (existingIndex < 0) {
          final duplicate = songs.any(
            (item) =>
                item['coupleId'] == coupleId &&
                item['isDeleted'] != true &&
                (item['name'] ?? '').toString().trim().toLowerCase() ==
                    name.toLowerCase() &&
                (item['artist'] ?? '').toString().trim().toLowerCase() ==
                    artist.toLowerCase(),
          );
          if (duplicate) {
            throw const ApiClientException('duplicate_playlist_song');
          }
        }

        final now = DateTime.now().toUtc().toIso8601String();
        final payload = <String, dynamic>{
          'id': id,
          'coupleId': coupleId,
          'name': name,
          'artist': artist,
          'genre': (body['genre'] ?? '').toString().trim(),
          'createdAt': (body['createdAt'] ?? now).toString(),
          'updatedAt': (body['updatedAt'] ?? now).toString(),
          'preference': (body['preference'] ?? 'none').toString(),
          'recommenderUserId': currentUserId,
          'isDeleted': body['isDeleted'] == true,
        };

        if (existingIndex >= 0) {
          songs[existingIndex] = <String, dynamic>{
            ...songs[existingIndex],
            ...payload,
            'recommenderUserId':
                songs[existingIndex]['recommenderUserId'] ?? currentUserId,
          };
        } else {
          songs.add(payload);
        }
        store['playlistSongs'] = songs;
        return _playlistSongForUser(
          existingIndex >= 0 ? songs[existingIndex] : payload,
          currentUserId,
        );
      });
    }

    final payload = await _postJson('/playlist/songs/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deletePlaylistSong({
    required String coupleId,
    required String currentUserId,
    required String songId,
    required DateTime updatedAt,
  }) async {
    if (!_usesHttpBackend) {
      await runWithFakeStore<void>((store) {
        final songs = _readPlaylistSongs(store);
        final index = songs.indexWhere(
          (item) => item['id'] == songId && item['coupleId'] == coupleId,
        );
        if (index < 0) {
          throw const ApiClientException('song_not_found');
        }
        songs[index] = <String, dynamic>{
          ...songs[index],
          'isDeleted': true,
          'updatedAt': updatedAt.toUtc().toIso8601String(),
          'deletedByUserId': currentUserId,
        };
        store['playlistSongs'] = songs;
      });
      return;
    }

    await _postJson('/playlist/songs/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'songId': songId,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    });
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

  Future<List<Map<String, dynamic>>> listFeedEvents({
    required String coupleId,
    required String currentUserId,
    int limit = 100,
  }) async {
    final payload = await _postJson('/feed/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'limit': limit,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> addFeedEvent({
    required String coupleId,
    required String currentUserId,
    required String eventType,
    required String targetType,
    required String targetId,
    required String summaryText,
  }) async {
    final payload = await _postJson('/feed/add', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'eventType': eventType,
      'targetType': targetType,
      'targetId': targetId,
      'summaryText': summaryText,
    });
    return _extractObject(payload);
  }

  Future<void> updateDistanceLocation({
    required String coupleId,
    required String currentUserId,
    required double latitude,
    required double longitude,
    String? locationLabel,
  }) async {
    await _postJson('/distance/update-location', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
    });
  }

  Future<Map<String, dynamic>> getDistanceInfo({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/distance/get-info', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractObject(payload);
  }

  Future<void> setDistanceVisibility({
    required String coupleId,
    required String currentUserId,
    required bool isVisible,
  }) async {
    await _postJson('/distance/set-visibility', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'isVisible': isVisible,
    });
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

  Future<List<Map<String, dynamic>>> listAlbums({
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/album/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> createAlbum(Map<String, dynamic> body) async {
    final payload = await _postJson('/album/create', body);
    return _extractObject(payload);
  }

  Future<Map<String, dynamic>> updateAlbum(Map<String, dynamic> body) async {
    final payload = await _postJson('/album/update', body);
    return _extractObject(payload);
  }

  Future<void> deleteAlbum({
    required String coupleId,
    required String currentUserId,
    required String albumId,
  }) async {
    await _postJson('/album/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'albumId': albumId,
    });
  }

  Future<List<Map<String, dynamic>>> listAlbumPhotos({
    required String albumId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson('/album/photo/list', <String, dynamic>{
      'albumId': albumId,
      'coupleId': coupleId,
      'currentUserId': currentUserId,
    });
    return _extractList(payload);
  }

  /// 由服务端分配 photo id 与主键时间戳；[id] 仅用于客户端幂等（可选）。
  Future<Map<String, dynamic>> uploadAlbumPhoto({
    required String coupleId,
    required String albumId,
    required String currentUserId,
    required String sourcePath,
    required String caption,
    String? id,
    String? localPath,
  }) async {
    final fields = <String, String>{
      'coupleId': coupleId,
      'albumId': albumId,
      'currentUserId': currentUserId,
      'caption': caption,
      if (id != null && id.isNotEmpty) 'id': id,
      if (localPath != null && localPath.trim().isNotEmpty)
        'localPath': localPath.trim(),
    };
    try {
      return await postMultipart(
        '/album/photo/upload',
        fields: fields,
        fileFieldName: 'file',
        filePath: sourcePath,
      );
    } on ApiClientException catch (error) {
      final shouldRetryWithApiPrefix =
          (error.code == 'route_not_found' ||
              error.code == 'album_upload_route_missing') &&
          !_baseUrl.trim().toLowerCase().contains('/api');
      if (!shouldRetryWithApiPrefix) {
        rethrow;
      }
      return postMultipart(
        '/api/album/photo/upload',
        fields: fields,
        fileFieldName: 'file',
        filePath: sourcePath,
      );
    }
  }

  Future<Map<String, dynamic>> updateAlbumPhoto(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/album/photo/update', body);
    return _extractObject(payload);
  }

  Future<void> deleteAlbumPhoto({
    required String coupleId,
    required String currentUserId,
    required String photoId,
  }) async {
    await _postJson('/album/photo/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'photoId': photoId,
    });
  }

  Future<List<Map<String, dynamic>>> listPhotoComments({
    required String photoId,
    required String coupleId,
    required String currentUserId,
  }) async {
    final payload = await _postJson(
      '/album/photo/comment/list',
      <String, dynamic>{
        'photoId': photoId,
        'coupleId': coupleId,
        'currentUserId': currentUserId,
      },
    );
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> createPhotoComment(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/album/photo/comment/create', body);
    return _extractObject(payload);
  }

  Future<void> deletePhotoComment({
    required String coupleId,
    required String currentUserId,
    required String commentId,
  }) async {
    await _postJson('/album/photo/comment/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'commentId': commentId,
    });
  }

  Future<List<Map<String, dynamic>>> listIdeaNotes({
    required String coupleId,
    required String currentUserId,
    DateTime? since,
  }) async {
    final payload = await _postJson('/thoughts/ideas/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'since': since?.toUtc().toIso8601String(),
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertIdeaNote(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/thoughts/ideas/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteIdeaNote({
    required String coupleId,
    required String currentUserId,
    required String ideaId,
  }) async {
    await _postJson('/thoughts/ideas/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'ideaId': ideaId,
    });
  }

  Future<List<Map<String, dynamic>>> listExcerptNotes({
    required String coupleId,
    required String currentUserId,
    DateTime? since,
  }) async {
    final payload =
        await _postJson('/thoughts/excerpts/list', <String, dynamic>{
          'coupleId': coupleId,
          'currentUserId': currentUserId,
          'since': since?.toUtc().toIso8601String(),
        });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertExcerptNote(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/thoughts/excerpts/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteExcerptNote({
    required String coupleId,
    required String currentUserId,
    required String excerptId,
  }) async {
    await _postJson('/thoughts/excerpts/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'excerptId': excerptId,
    });
  }

  Future<List<Map<String, dynamic>>> listThoughtComments({
    required String coupleId,
    required String currentUserId,
    required String targetType,
    required String targetId,
  }) async {
    final payload = await _postJson('/thoughts/comments/list', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'targetType': targetType,
      'targetId': targetId,
    });
    return _extractList(payload);
  }

  Future<Map<String, dynamic>> upsertThoughtComment(
    Map<String, dynamic> body,
  ) async {
    final payload = await _postJson('/thoughts/comments/upsert', body);
    return _extractObject(payload);
  }

  Future<void> deleteThoughtComment({
    required String coupleId,
    required String currentUserId,
    required String commentId,
  }) async {
    await _postJson('/thoughts/comments/delete', <String, dynamic>{
      'coupleId': coupleId,
      'currentUserId': currentUserId,
      'commentId': commentId,
    });
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final candidatePaths = _resolveCandidatePaths(path);
    ApiClientException? lastError;
    for (final candidatePath in candidatePaths) {
      try {
        return await _postJsonSingle(candidatePath, body);
      } on ApiClientException catch (error) {
        lastError = error;
        if (error.code != 'route_not_found' &&
            error.code != 'album_upload_route_missing') {
          rethrow;
        }
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    throw const ApiClientException('http_error');
  }

  Future<dynamic> _postJsonSingle(
    String path,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$_baseUrl$path'));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiClientException(
          _resolveHttpErrorCode(
            statusCode: response.statusCode,
            path: path,
            responseBody: responseBody,
          ),
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

  /// 通用 multipart 上传，其它模块可复用（相册等）。
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
  }) {
    return _postMultipart(
      path,
      fields: fields,
      fileFieldName: fileFieldName,
      filePath: filePath,
    );
  }

  Future<Map<String, dynamic>> _postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
  }) async {
    final candidatePaths = _resolveCandidatePaths(path);
    ApiClientException? lastError;
    for (final candidatePath in candidatePaths) {
      try {
        return await _postMultipartSingle(
          candidatePath,
          fields: fields,
          fileFieldName: fileFieldName,
          filePath: filePath,
        );
      } on ApiClientException catch (error) {
        lastError = error;
        if (error.code != 'route_not_found' &&
            error.code != 'album_upload_route_missing') {
          rethrow;
        }
      }
    }
    if (lastError != null) {
      throw lastError;
    }
    throw const ApiClientException('http_error');
  }

  Future<Map<String, dynamic>> _postMultipartSingle(
    String path, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
  }) async {
    final client = HttpClient();
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const ApiClientException('file_not_found');
      }
      final fileBytes = await file.readAsBytes();
      final fileName = _extractFileName(filePath);
      final boundary = '----codex-${DateTime.now().microsecondsSinceEpoch}';
      final request = await client.postUrl(Uri.parse('$_baseUrl$path'));
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      for (final entry in fields.entries) {
        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n',
        );
        request.write('${entry.value}\r\n');
      }

      request.write('--$boundary\r\n');
      request.write(
        'Content-Disposition: form-data; name="$fileFieldName"; filename="$fileName"\r\n',
      );
      request.write(
        'Content-Type: ${_guessMimeTypeFromFileName(fileName)}\r\n\r\n',
      );
      request.add(fileBytes);
      request.write('\r\n--$boundary--\r\n');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiClientException(
          _resolveHttpErrorCode(
            statusCode: response.statusCode,
            path: path,
            responseBody: responseBody,
          ),
        );
      }
      final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);
      return _extractObject(decoded);
    } finally {
      client.close();
    }
  }

  List<String> _resolveCandidatePaths(String path) {
    if (!path.startsWith('/')) {
      return <String>[path];
    }
    if (path.startsWith('/album/')) {
      if (_baseUrlHasApiSuffix) {
        return <String>[path];
      }
      return _dedupPaths(<String>[
        path,
        '/api$path',
        '/api/v1$path',
        '/v1$path',
      ]);
    }
    return <String>[path];
  }

  List<String> _dedupPaths(List<String> paths) {
    final out = <String>[];
    final seen = <String>{};
    for (final item in paths) {
      final normalized = item.trim();
      if (normalized.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      out.add(normalized);
    }
    return out;
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

  List<Map<String, dynamic>> _readPlaylistSongs(Map<String, dynamic> store) {
    return List<Map<String, dynamic>>.from(
      (store['playlistSongs'] as List<dynamic>? ?? <dynamic>[]).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  Map<String, dynamic> _playlistSongForUser(
    Map<String, dynamic> item,
    String currentUserId,
  ) {
    return <String, dynamic>{
      'id': item['id'],
      'name': item['name'] ?? '',
      'artist': item['artist'] ?? '',
      'genre': item['genre'] ?? '',
      'createdAt': item['createdAt'],
      'updatedAt': item['updatedAt'] ?? item['createdAt'],
      'preference': item['preference'] ?? 'none',
      'recommender': item['recommenderUserId'] == currentUserId
          ? 'me'
          : 'partner',
      'isDeleted': item['isDeleted'] == true,
    };
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

  String _guessMimeTypeFromFileName(String fileName) {
    final ext = _extractFileExtension(fileName);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  String _resolveHttpErrorCode({
    required int statusCode,
    required String path,
    required String responseBody,
  }) {
    final body = responseBody.trim();
    if (body.isEmpty) {
      return statusCode == 404 ? 'route_not_found' : 'http_error';
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final errorMap = decoded['error'];
        if (errorMap is Map<String, dynamic>) {
          final code = errorMap['code']?.toString().trim();
          if (code != null && code.isNotEmpty) {
            return code;
          }
        }
        final code = decoded['code']?.toString().trim();
        if (code != null && code.isNotEmpty) {
          return code;
        }
      }
    } catch (_) {}
    final lower = body.toLowerCase();
    if (lower.contains('cannot post')) {
      if (path.contains('/album/photo/upload')) {
        return 'album_upload_route_missing';
      }
      return 'route_not_found';
    }
    if (statusCode == 404) {
      return 'route_not_found';
    }
    return 'http_error';
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

  String? _resolveUploadedMediaUrl(Map<String, dynamic> data) {
    final raw = (data['mediaUrl'] ?? data['url'])?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('file://')) {
      return raw;
    }
    if (raw.startsWith('/')) {
      if (!_usesHttpBackend) {
        return raw;
      }
      return '${_baseUrl.trim().replaceAll(RegExp(r"/+$"), "")}$raw';
    }
    return raw;
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

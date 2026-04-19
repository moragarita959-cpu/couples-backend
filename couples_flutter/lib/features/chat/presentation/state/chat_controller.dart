import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chat_stats.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/sync_messages.dart';
import 'chat_state.dart';

class ChatController extends StateNotifier<ChatState> {
  ChatController(
    this._sendMessageUseCase,
    this._syncMessages,
    this._getChatStats,
    this._chatRepository,
    this._currentUserIdResolver,
    this._currentCoupleIdResolver,
  ) : super(const ChatState()) {
    _initialize();
  }

  final SendMessage _sendMessageUseCase;
  final SyncMessages _syncMessages;
  final GetChatStats _getChatStats;
  final ChatRepository _chatRepository;
  final String? Function() _currentUserIdResolver;
  final String? Function() _currentCoupleIdResolver;
  final Random _random = Random();
  Timer? _pollingTimer;
  Timer? _typingDebounceTimer;
  bool _lastTypingValue = false;

  Future<void> _initialize() async {
    final currentUserId = _currentUserIdResolver();
    final coupleId = _currentCoupleIdResolver();

    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '请先初始化当前设备身份。',
      );
      return;
    }

    if (coupleId == null || coupleId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        needsBinding: true,
        partnerTyping: false,
        errorMessage: null,
      );
      return;
    }

    await _reload(syncFirst: true);
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _reload(syncFirst: true, silent: true);
    });
  }

  Future<void> _reload({required bool syncFirst, bool silent = false}) async {
    final currentUserId = _currentUserIdResolver();
    final coupleId = _currentCoupleIdResolver();
    if (currentUserId == null ||
        currentUserId.isEmpty ||
        coupleId == null ||
        coupleId.isEmpty) {
      return;
    }

    if (!silent) {
      state = state.copyWith(
        isLoading: true,
        needsBinding: false,
        errorMessage: null,
      );
    }

    try {
      if (syncFirst) {
        await _syncMessages(currentUserId: currentUserId, coupleId: coupleId);
      }
      await _refreshFromLocal(
        currentUserId: currentUserId,
        coupleId: coupleId,
        silent: silent,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '聊天数据加载失败，请稍后重试。',
      );
    }
  }

  Future<void> _refreshFromLocal({
    required String currentUserId,
    required String coupleId,
    bool silent = true,
  }) async {
    final messages = await _chatRepository.getMessages(
      currentUserId: currentUserId,
    );
    final stats = await _getChatStats(currentUserId: currentUserId);
    final partnerTyping = await _chatRepository.getPartnerTypingStatus(
      currentUserId: currentUserId,
      coupleId: coupleId,
    );
    state = state.copyWith(
      messages: messages,
      stats: stats,
      partnerTyping: partnerTyping,
      isLoading: silent ? state.isLoading : false,
      needsBinding: false,
      errorMessage: null,
    );
  }

  void onComposerTextChanged(String value) {
    final shouldSetTyping = value.trim().isNotEmpty;
    _typingDebounceTimer?.cancel();

    if (!shouldSetTyping) {
      unawaited(_setTypingStatus(false));
      return;
    }

    _typingDebounceTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(_setTypingStatus(true));
    });
  }

  Future<void> send(String rawInput) async {
    final content = rawInput.trim();
    if (content.isEmpty) {
      return;
    }
    await _sendMessageInternal(
      content: content,
      messageType: ChatMessageType.text,
    );
  }

  Future<void> sendImage(String imagePath) async {
    if (imagePath.trim().isEmpty) {
      return;
    }

    await _sendMessageInternal(
      content: '',
      messageType: ChatMessageType.image,
      localMediaPath: imagePath,
    );
  }

  Future<void> sendVoice({
    required String audioPath,
    required int durationMs,
  }) async {
    if (audioPath.trim().isEmpty || durationMs <= 0) {
      return;
    }

    await _sendMessageInternal(
      content: '',
      messageType: ChatMessageType.voice,
      localMediaPath: audioPath,
      mediaDurationMs: durationMs,
    );
  }

  Future<void> _sendMessageInternal({
    required String content,
    required ChatMessageType messageType,
    String? localMediaPath,
    int? mediaDurationMs,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty && localMediaPath == null) {
      return;
    }

    final currentUserId = _currentUserIdResolver();
    final coupleId = _currentCoupleIdResolver();
    if (currentUserId == null ||
        currentUserId.isEmpty ||
        coupleId == null ||
        coupleId.isEmpty) {
      state = state.copyWith(
        errorMessage: '请先完成情侣绑定，再开始聊天。',
      );
      return;
    }

    final clientMessageId = _generateClientMessageId(currentUserId);

    state = state.copyWith(isSending: true, errorMessage: null);

    _typingDebounceTimer?.cancel();
    await _setTypingStatus(false, force: true);

    try {
      await _chatRepository.createOptimisticMessage(
        currentUserId: currentUserId,
        coupleId: coupleId,
        content: trimmedContent,
        clientMessageId: clientMessageId,
        messageType: messageType,
        mediaUrl: localMediaPath,
        mediaDurationMs: mediaDurationMs,
      );
      await _refreshFromLocal(currentUserId: currentUserId, coupleId: coupleId);

      var uploadedMediaUrl = localMediaPath;
      if (localMediaPath != null && localMediaPath.isNotEmpty) {
        try {
          uploadedMediaUrl = await _uploadMedia(
            currentUserId: currentUserId,
            coupleId: coupleId,
            messageType: messageType,
            sourcePath: localMediaPath,
          );
        } catch (error) {
          await _chatRepository.discardOptimisticMessage(
            clientMessageId: clientMessageId,
          );
          await _refreshFromLocal(
            currentUserId: currentUserId,
            coupleId: coupleId,
          );
          state = state.copyWith(
            errorMessage: _mediaUploadErrorMessage(messageType, error),
          );
          return;
        }
      }

      await _sendMessageUseCase(
        currentUserId: currentUserId,
        coupleId: coupleId,
        content: trimmedContent,
        clientMessageId: clientMessageId,
        messageType: messageType,
        mediaUrl: uploadedMediaUrl,
        mediaDurationMs: mediaDurationMs,
      );
      await _reload(syncFirst: true, silent: true);
    } catch (_) {
      await _chatRepository.discardOptimisticMessage(
        clientMessageId: clientMessageId,
      );
      await _refreshFromLocal(currentUserId: currentUserId, coupleId: coupleId);
      state = state.copyWith(errorMessage: '消息发送失败，请稍后再试。');
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  Future<String?> _uploadMedia({
    required String currentUserId,
    required String coupleId,
    required ChatMessageType messageType,
    required String sourcePath,
  }) async {
    switch (messageType) {
      case ChatMessageType.image:
        return _chatRepository.uploadImage(
          currentUserId: currentUserId,
          coupleId: coupleId,
          sourcePath: sourcePath,
        );
      case ChatMessageType.voice:
        return _chatRepository.uploadVoice(
          currentUserId: currentUserId,
          coupleId: coupleId,
          sourcePath: sourcePath,
        );
      case ChatMessageType.text:
        return null;
    }
  }

  String _mediaUploadErrorMessage(ChatMessageType messageType, Object error) {
    final label = switch (messageType) {
      ChatMessageType.image => '图片',
      ChatMessageType.voice => '语音',
      ChatMessageType.text => '消息',
    };
    if (error is ApiClientException) {
      final raw = error.code.toLowerCase();
      if (raw.contains('/chat/upload-image') ||
          raw.contains('/chat/upload-voice') ||
          raw.contains('not found') ||
          raw.contains('404')) {
        return '当前后端还未支持$label上传接口，请先实现 /chat/upload-image 和 /chat/upload-voice。';
      }
      if (raw.contains('invalid_upload_response')) {
        return '$label上传接口已响应，但没有返回可用的媒体 URL。';
      }
    }
    return '$label发送失败，请检查后端媒体上传接口、文件存储和消息 URL 落库链路。';
  }

  Future<void> _setTypingStatus(bool isTyping, {bool force = false}) async {
    if (!force && _lastTypingValue == isTyping) {
      return;
    }

    final currentUserId = _currentUserIdResolver();
    final coupleId = _currentCoupleIdResolver();
    if (currentUserId == null ||
        currentUserId.isEmpty ||
        coupleId == null ||
        coupleId.isEmpty) {
      return;
    }

    try {
      await _chatRepository.setTypingStatus(
        currentUserId: currentUserId,
        coupleId: coupleId,
        isTyping: isTyping,
      );
      _lastTypingValue = isTyping;
    } catch (_) {
      // 输入状态接口失败时，不影响文字聊天主链路。
    }
  }

  String _generateClientMessageId(String currentUserId) {
    final suffix = (_random.nextInt(9000) + 1000).toString();
    return 'cm-$currentUserId-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _typingDebounceTimer?.cancel();
    unawaited(_setTypingStatus(false, force: true));
    super.dispose();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/chat_message.dart';

const String _chatApiBaseUrl = String.fromEnvironment(
  'COUPLES_API_BASE_URL',
  defaultValue: '',
);

class ChatMessageWidget extends StatefulWidget {
  const ChatMessageWidget({super.key, required this.message});

  final ChatMessage message;

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  AudioPlayer? _voicePlayer;
  bool _voiceReady = false;
  bool _isPlaying = false;
  bool _voiceLoadFailed = false;

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void initState() {
    super.initState();
    _initVoicePlayerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ChatMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final typeChanged = oldWidget.message.messageType != widget.message.messageType;
    final urlChanged = oldWidget.message.mediaUrl != widget.message.mediaUrl;
    if (!typeChanged && !urlChanged) {
      return;
    }
    _voiceReady = false;
    _isPlaying = false;
    _voiceLoadFailed = false;
    _voicePlayer?.dispose();
    _voicePlayer = null;
    _initVoicePlayerIfNeeded();
  }

  void _initVoicePlayerIfNeeded() {
    if (widget.message.messageType != ChatMessageType.voice) {
      return;
    }
    _voicePlayer = AudioPlayer();
    _voicePlayer!.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = state.playing;
      });
    });
    _prepareVoice();
  }

  Future<void> _prepareVoice() async {
    final mediaUrl = widget.message.mediaUrl;
    if (_voicePlayer == null || mediaUrl == null || mediaUrl.isEmpty) {
      return;
    }
    try {
      final resolved = _resolveAudioSource(mediaUrl);
      if (resolved == null) {
        throw const FormatException('invalid_audio_source');
      }
      if (_isNetworkUrl(resolved)) {
        await _voicePlayer!.setUrl(resolved);
      } else if (resolved.startsWith('file://')) {
        await _voicePlayer!.setFilePath(Uri.parse(resolved).toFilePath());
      } else {
        await _voicePlayer!.setUrl(resolved);
      }
      if (mounted) {
        setState(() {
          _voiceReady = true;
          _voiceLoadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _voiceReady = false;
          _voiceLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _voicePlayer?.dispose();
    super.dispose();
  }

  Future<void> _toggleVoicePlayback() async {
    if (_voicePlayer == null || !_voiceReady) {
      return;
    }
    if (_isPlaying) {
      await _voicePlayer!.pause();
    } else {
      await _voicePlayer!.seek(Duration.zero);
      await _voicePlayer!.play();
    }
  }

  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String? _resolveAudioSource(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalizedRemote = _normalizeRemoteMediaUrl(trimmed);
    if (normalizedRemote != null && _isNetworkUrl(normalizedRemote)) {
      return normalizedRemote;
    }
    if (trimmed.startsWith('file://')) {
      return trimmed;
    }
    final file = File(trimmed);
    if (!file.existsSync()) {
      return null;
    }
    return file.uri.toString();
  }

  String? _normalizeRemoteMediaUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final base = _chatApiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.startsWith('/')) {
      return base.isEmpty ? null : '$base$trimmed';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      final baseUri = base.isEmpty ? null : Uri.tryParse(base);
      if (uri == null || baseUri == null) {
        return trimmed;
      }
      if (uri.path.startsWith('/media/chat/') && uri.host != baseUri.host) {
        return baseUri
            .replace(
              path: uri.path,
              query: uri.hasQuery ? uri.query : null,
            )
            .toString();
      }
      return trimmed;
    }
    if (trimmed.startsWith('media/chat/')) {
      return base.isEmpty ? null : '$base/$trimmed';
    }
    return null;
  }

  String _formatVoiceDuration(int? durationMs) {
    if (durationMs == null || durationMs <= 0) {
      return '0:00';
    }
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildBubbleContent() {
    switch (widget.message.messageType) {
      case ChatMessageType.image:
        return _ChatImageContent(mediaUrl: widget.message.mediaUrl);
      case ChatMessageType.voice:
        return _ChatVoiceContent(
          durationLabel: _formatVoiceDuration(widget.message.mediaDurationMs),
          onTap: _toggleVoicePlayback,
          isPlayable: _voiceReady,
          isPlaying: _isPlaying,
          hasError: _voiceLoadFailed,
        );
      case ChatMessageType.text:
        return Text(
          widget.message.content,
          style: const TextStyle(
            fontSize: 15.5,
            height: 1.45,
            color: Color(0xFF34242C),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMe = message.sender == ChatSender.me;
    final bubbleColor = isMe ? const Color(0xFFFFE3EB) : CoupleUi.surface;
    final outlineColor = isMe ? const Color(0x33E38BA4) : CoupleUi.sectionBorder;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final crossAxisAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 8),
                    bottomRight: Radius.circular(isMe ? 8 : 20),
                  ),
                  border: Border.all(color: outlineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: _buildBubbleContent(),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isPending) ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: Color(0xFFAD7C89),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '发送中...',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFAD7C89),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A7A80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatImageContent extends StatelessWidget {
  const _ChatImageContent({required this.mediaUrl});

  final String? mediaUrl;

  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (mediaUrl == null || mediaUrl!.isEmpty) {
      return const SizedBox(
        width: 180,
        height: 140,
        child: Center(child: Text('图片暂时无法显示')),
      );
    }

    final normalizedRemote = _normalizeRemoteMediaUrl(mediaUrl!);
    final resolvedFile = _resolveLocalFile(mediaUrl!);
    final imageWidget = normalizedRemote != null && _isNetworkUrl(normalizedRemote)
        ? Image.network(
            normalizedRemote,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const SizedBox(
                width: 180,
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          )
        : resolvedFile != null
        ? Image.file(
            resolvedFile,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          )
        : const _ImageFallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 160,
          maxWidth: 240,
          minHeight: 120,
          maxHeight: 280,
        ),
        child: imageWidget,
      ),
    );
  }

  File? _resolveLocalFile(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.startsWith('file://')) {
      final path = Uri.parse(trimmed).toFilePath();
      final file = File(path);
      return file.existsSync() ? file : null;
    }
    final file = File(trimmed);
    return file.existsSync() ? file : null;
  }

  String? _normalizeRemoteMediaUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final base = _chatApiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.startsWith('/')) {
      return base.isEmpty ? null : '$base$trimmed';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      final baseUri = base.isEmpty ? null : Uri.tryParse(base);
      if (uri == null || baseUri == null) {
        return trimmed;
      }
      if (uri.path.startsWith('/media/chat/') && uri.host != baseUri.host) {
        return baseUri
            .replace(
              path: uri.path,
              query: uri.hasQuery ? uri.query : null,
            )
            .toString();
      }
      return trimmed;
    }
    if (trimmed.startsWith('media/chat/')) {
      return base.isEmpty ? null : '$base/$trimmed';
    }
    return null;
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7EFF2),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, color: Color(0xFF9B6F7D)),
          SizedBox(height: 8),
          Text(
            '图片暂时无法显示',
            style: TextStyle(color: Color(0xFF9B6F7D)),
          ),
        ],
      ),
    );
  }
}

class _ChatVoiceContent extends StatelessWidget {
  const _ChatVoiceContent({
    required this.durationLabel,
    required this.onTap,
    required this.isPlayable,
    required this.isPlaying,
    required this.hasError,
  });

  final String durationLabel;
  final VoidCallback onTap;
  final bool isPlayable;
  final bool isPlaying;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isPlayable ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
            color: const Color(0xFFB75573),
            size: 26,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPlayable
                    ? '语音消息'
                    : (hasError ? '语音加载失败' : '语音准备中...'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF34242C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                durationLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF8A7A80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

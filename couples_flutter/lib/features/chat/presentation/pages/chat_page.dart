import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../app/providers.dart';
import '../../../../core/ui/couple_ui.dart';
import '../../domain/entities/chat_message.dart';
import '../state/chat_state.dart';
import '../widgets/chat_message_widget.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _composerFocusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Set<String> _seenMessageIds = <String>{};
  bool _soundReady = false;
  bool _hasText = false;
  bool _isRecordingVoice = false;
  DateTime? _recordingStartedAt;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    unawaited(_prepareNotificationSound());
  }

  Future<void> _prepareNotificationSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/chat_partner_pop.mp3');
      await _audioPlayer.setVolume(0.75);
      _soundReady = true;
    } catch (_) {
      _soundReady = false;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    _recordingTimer?.cancel();
    unawaited(_audioRecorder.dispose());
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scheduleScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final target = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _playNotificationSound() async {
    if (!_soundReady) {
      return;
    }
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (_) {
      // 提示音失败不影响聊天本身。
    }
  }

  Future<void> _sendCurrentMessage() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) {
      return;
    }

    _inputController.clear();
    setState(() {
      _hasText = false;
    });

    final controller = ref.read(chatControllerProvider.notifier);
    controller.onComposerTextChanged('');
    await controller.send(text);
    _composerFocusNode.requestFocus();
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }

    await ref.read(chatControllerProvider.notifier).sendImage(picked.path);
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecordingVoice) {
      await _stopVoiceRecording(sendAfterStop: true);
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('需要麦克风权限才能录制语音。')),
        );
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    final path =
        '${tempDirectory.path}${Platform.pathSeparator}voice-${DateTime.now().microsecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _recordingStartedAt = DateTime.now();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _recordingStartedAt == null) {
        return;
      }
      setState(() {
        _recordingDuration = DateTime.now().difference(_recordingStartedAt!);
      });
    });

    setState(() {
      _isRecordingVoice = true;
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _stopVoiceRecording({required bool sendAfterStop}) async {
    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();
    final duration = _recordingStartedAt == null
        ? Duration.zero
        : DateTime.now().difference(_recordingStartedAt!);

    if (mounted) {
      setState(() {
        _isRecordingVoice = false;
        _recordingStartedAt = null;
        _recordingDuration = Duration.zero;
      });
    }

    if (!sendAfterStop || path == null || path.isEmpty || duration.inMilliseconds <= 0) {
      return;
    }

    await ref.read(chatControllerProvider.notifier).sendVoice(
          audioPath: path,
          durationMs: duration.inMilliseconds,
        );
  }

  KeyEventResult _handleComposerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) {
      return KeyEventResult.ignored;
    }

    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }

    unawaited(_sendCurrentMessage());
    return KeyEventResult.handled;
  }

  void _handleComposerChanged(String value) {
    setState(() {
      _hasText = value.trim().isNotEmpty;
    });
    ref.read(chatControllerProvider.notifier).onComposerTextChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      final previousIds = previous == null
          ? _seenMessageIds
          : previous.messages.map((message) => message.id).toSet();

      if (_seenMessageIds.isEmpty && previous == null) {
        _seenMessageIds.addAll(next.messages.map((message) => message.id));
      } else {
        for (final message in next.messages) {
          if (!previousIds.contains(message.id) &&
              !_seenMessageIds.contains(message.id) &&
              message.sender == ChatSender.partner) {
            unawaited(_playNotificationSound());
          }
        }
        _seenMessageIds
          ..clear()
          ..addAll(next.messages.map((message) => message.id));
      }

      if ((previous?.messages.length ?? 0) != next.messages.length) {
        _scheduleScrollToBottom();
      }
    });

    final stats = state.stats;
    final meRatio = ((stats?.meInitiativeRatio ?? 0) * 100).round();
    final partnerRatio = ((stats?.partnerInitiativeRatio ?? 0) * 100).round();

    return Scaffold(
      backgroundColor: CoupleUi.pageBackground,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: CoupleUi.surface,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: Color(0xFFE37793),
                ),
                SizedBox(width: 6),
                Text('一起聊天'),
              ],
            ),
            if (state.partnerTyping)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  '对方正在输入...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9C5C70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: CoupleUi.pageBackgroundDecoration(),
          child: Column(
            children: [
              if (state.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state.needsBinding)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        '请先完成情侣绑定，再开始聊天。',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: _StatsPanel(
                    totalMessages: stats?.totalMessages ?? 0,
                    streakDays: stats?.streakDays ?? 0,
                    meRatio: meRatio,
                    partnerRatio: partnerRatio,
                    totalCharacterCount: stats?.totalCharacterCount ?? 0,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageWidget(message: state.messages[index]);
                    },
                  ),
                ),
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _ComposerBar(
                  controller: _inputController,
                  focusNode: _composerFocusNode,
                  onChanged: _handleComposerChanged,
                  onSend: _sendCurrentMessage,
                  onPickImage: _pickAndSendImage,
                  onToggleVoiceRecording: _toggleVoiceRecording,
                  onKeyEvent: _handleComposerKey,
                  canSend: _hasText && !state.isSending,
                  isSending: state.isSending,
                  isRecordingVoice: _isRecordingVoice,
                  recordingDurationLabel: _formatRecordingDuration(
                    _recordingDuration,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatRecordingDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.totalMessages,
    required this.streakDays,
    required this.meRatio,
    required this.partnerRatio,
    required this.totalCharacterCount,
  });

  final int totalMessages;
  final int streakDays;
  final int meRatio;
  final int partnerRatio;
  final int totalCharacterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: CoupleUi.sectionCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(label: '消息数', value: '$totalMessages'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(label: '连续互动', value: '$streakDays 天'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '主动度',
                  value: '我 $meRatio% / TA $partnerRatio%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: '聊天字数',
                  value: '$totalCharacterCount 字',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: CoupleUi.nestedCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8D7B82)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3D2B34),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSend,
    required this.onPickImage,
    required this.onToggleVoiceRecording,
    required this.onKeyEvent,
    required this.canSend,
    required this.isSending,
    required this.isRecordingVoice,
    required this.recordingDurationLabel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onSend;
  final Future<void> Function() onPickImage;
  final Future<void> Function() onToggleVoiceRecording;
  final KeyEventResult Function(FocusNode node, KeyEvent event) onKeyEvent;
  final bool canSend;
  final bool isSending;
  final bool isRecordingVoice;
  final String recordingDurationLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: CoupleUi.surface,
          border: Border(top: BorderSide(color: CoupleUi.sectionBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecordingVoice)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33D96C8A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mic_rounded,
                      size: 18,
                      color: Color(0xFFD85E81),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '正在录音... $recordingDurationLabel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8C3950),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => unawaited(onToggleVoiceRecording()),
                      child: const Text('发送语音'),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IconActionButton(
                  icon: Icons.image_outlined,
                  tooltip: '发送图片',
                  onTap: isSending ? null : () => unawaited(onPickImage()),
                ),
                const SizedBox(width: 8),
                _IconActionButton(
                  icon: isRecordingVoice ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                  tooltip: isRecordingVoice ? '结束录音' : '开始录音',
                  backgroundColor: isRecordingVoice
                      ? const Color(0xFFFFEEF2)
                      : const Color(0xFFF4F2F5),
                  iconColor: isRecordingVoice
                      ? const Color(0xFFD85E81)
                      : const Color(0xFF9A6F7C),
                  onTap: isSending
                      ? null
                      : () => unawaited(onToggleVoiceRecording()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: CoupleUi.surfaceMuted,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: CoupleUi.sectionBorder),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Focus(
                      onKeyEvent: onKeyEvent,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          hintText: '说点温柔的话吧...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: canSend ? () => unawaited(onSend()) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: CoupleUi.primary,
                      disabledBackgroundColor: const Color(0xFFE6CDD6),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(isSending ? '发送中' : '发送'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.backgroundColor = const Color(0xFFF4F2F5),
    this.iconColor = const Color(0xFF9A6F7C),
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CoupleUi.sectionBorder),
          ),
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

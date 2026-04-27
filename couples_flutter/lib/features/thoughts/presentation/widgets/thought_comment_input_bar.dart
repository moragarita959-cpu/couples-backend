import 'package:flutter/material.dart';

import '../theme/thoughts_theme.dart';

class ThoughtCommentInputBar extends StatefulWidget {
  const ThoughtCommentInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
    this.hintText = '写下你的回应...',
  });

  final bool isSending;
  final Future<bool> Function(String value) onSend;
  final String hintText;

  @override
  State<ThoughtCommentInputBar> createState() => _ThoughtCommentInputBarState();
}

class _ThoughtCommentInputBarState extends State<ThoughtCommentInputBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: ThoughtsTheme.divider)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF8F5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ThoughtsTheme.border),
                ),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: ThoughtsTheme.body(
                          size: 14,
                          color: ThoughtsTheme.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: ThoughtsTheme.body(size: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: ThoughtsTheme.softInk,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: widget.isSending
                  ? null
                  : () async {
                      final success = await widget.onSend(_controller.text);
                      if (success) {
                        _controller.clear();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: ThoughtsTheme.rose,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(64, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: widget.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '发送',
                      style: ThoughtsTheme.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

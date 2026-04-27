import 'package:flutter/material.dart';

import '../../../../core/ui/couple_ui.dart';
import 'album_theme.dart';

class PhotoCommentInputBar extends StatelessWidget {
  const PhotoCommentInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF8F8),
          border: Border(top: BorderSide(color: Color(0xFFF1E8E8))),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8EC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF5DADF)),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: CoupleUi.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF0E5E5)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 1,
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: '写下这一刻的想法...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: AlbumTheme.zhBodyFont,
                      color: CoupleUi.textTertiary,
                    ),
                  ),
                  style: const TextStyle(fontFamily: AlbumTheme.zhBodyFont),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              scale: isSending ? 0.92 : 1,
              child: Material(
                color: CoupleUi.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSending ? null : onSend,
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(
                      isSending
                          ? Icons.hourglass_top_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

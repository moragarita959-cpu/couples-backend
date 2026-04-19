import 'package:flutter/material.dart';

class HomePokeCard extends StatefulWidget {
  const HomePokeCard({
    super.key,
    required this.justPoked,
    required this.pokeButtonText,
    required this.lastPokeText,
    required this.onPoke,
    this.initialTodayPokeCount = 2,
    this.interactionStreakDays = 5,
  });

  final bool justPoked;
  final String pokeButtonText;
  final String lastPokeText;
  final VoidCallback? onPoke;
  final int initialTodayPokeCount;
  final int interactionStreakDays;

  @override
  State<HomePokeCard> createState() => _HomePokeCardState();
}

class _HomePokeCardState extends State<HomePokeCard> {
  late int _todayPokeCount;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _todayPokeCount = widget.initialTodayPokeCount;
  }

  @override
  void didUpdateWidget(covariant HomePokeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTodayPokeCount != oldWidget.initialTodayPokeCount &&
        widget.initialTodayPokeCount >= _todayPokeCount) {
      _todayPokeCount = widget.initialTodayPokeCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = const Color(0xFFE85A7A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.justPoked
              ? const [Color(0xFFFFE5EF), Color(0xFFFFF3F7)]
              : const [Colors.white, Color(0xFFFFFBFD)],
        ),
        border: Border.all(
          color: widget.justPoked
              ? const Color(0xFFFFA1BC)
              : const Color(0x1F000000),
          width: widget.justPoked ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.justPoked
                ? const Color(0x33E85A7A)
                : const Color(0x14000000),
            blurRadius: widget.justPoked ? 16 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.justPoked
                      ? const Color(0xFFFFD6E5)
                      : Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.justPoked ? Icons.favorite : Icons.touch_app_outlined,
                  color: accentColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u6233\u4e00\u4e0b',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3E2A30),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\u60f3 TA \u7684\u65f6\u5019\u5c31\u8f7b\u8f7b\u6233\u4e00\u4e0b',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0x993E2A30),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\u4eca\u5929\u7b2c $_todayPokeCount \u6b21\u6233 \u00b7 '
            '\u5df2\u8fde\u7eed\u6709\u6548\u4e92\u52a8 ${widget.interactionStreakDays} \u5929',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xA63E2A30),
              fontWeight: FontWeight.w500,
              fontSize: 13.2,
            ),
          ),
          if (widget.justPoked) ...[
            const SizedBox(height: 6),
            Text(
              '\u521a\u521a\u8f7b\u8f7b\u6233\u4e86 TA \u4e00\u4e0b \ud83d\udc97',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB63E5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTapDown: widget.onPoke == null
                  ? null
                  : (_) => setState(() => _pressed = true),
              onTapCancel: widget.onPoke == null
                  ? null
                  : () => setState(() => _pressed = false),
              onTapUp: widget.onPoke == null
                  ? null
                  : (_) => setState(() => _pressed = false),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: _pressed ? 0.95 : 1,
                curve: Curves.easeOut,
                child: FilledButton(
                  onPressed: widget.onPoke == null
                      ? null
                      : () {
                          setState(() {
                            _todayPokeCount += 1;
                          });
                          widget.onPoke?.call();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0x8CE85A7A),
                    padding: const EdgeInsets.symmetric(vertical: 12.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: widget.justPoked ? 2 : 0,
                  ),
                  child: Text(
                    widget.pokeButtonText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.lastPokeText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0x993E2A30),
            ),
          ),
        ],
      ),
    );
  }
}

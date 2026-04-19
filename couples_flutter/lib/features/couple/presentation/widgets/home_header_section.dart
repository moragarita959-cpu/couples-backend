import 'package:flutter/material.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({
    super.key,
    required this.title,
    required this.coupleIdentity,
    required this.subtitle,
    required this.loveDaysText,
    required this.todayText,
  });

  final String title;
  final String coupleIdentity;
  final String subtitle;
  final String loveDaysText;
  final String todayText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relationTitle = _relationTitle(coupleIdentity);
    final relationHint = _relationHint(coupleIdentity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.shade100,
            Colors.pink.shade50,
            const Color(0xFFFFF8F2),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xC7FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFE85A7A),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3E2A30),
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      relationTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xE6B63E5A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (relationHint != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        relationHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0x733E2A30),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xA63E2A30),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            loveDaysText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB63E5A),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            todayText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0x943E2A30),
              fontWeight: FontWeight.w500,
              fontSize: 11.8,
            ),
          ),
        ],
      ),
    );
  }

  String _relationTitle(String rawIdentity) {
    if (rawIdentity.trim().isEmpty) {
      return '你和 TA 的小宇宙';
    }
    if (_looksLikePhoneIdentity(rawIdentity)) {
      return '你和 TA 的小宇宙';
    }
    return rawIdentity;
  }

  String? _relationHint(String rawIdentity) {
    if (_looksLikePhoneIdentity(rawIdentity)) {
      return rawIdentity;
    }
    return null;
  }

  bool _looksLikePhoneIdentity(String text) {
    return RegExp(r'\d{6,}').hasMatch(text);
  }
}

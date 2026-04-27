import 'package:flutter/material.dart';

import '../theme/thoughts_theme.dart';

class ThoughtsEmptyState extends StatelessWidget {
  const ThoughtsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          decoration: ThoughtsTheme.surfaceDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9E7E3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: ThoughtsTheme.rose),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: ThoughtsTheme.title(size: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: ThoughtsTheme.body(size: 14, height: 1.65),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

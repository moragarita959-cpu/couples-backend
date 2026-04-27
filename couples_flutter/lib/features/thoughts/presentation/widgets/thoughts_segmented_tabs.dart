import 'package:flutter/material.dart';

import '../controllers/thoughts_home_state.dart';
import '../theme/thoughts_theme.dart';

class ThoughtsSegmentedTabs extends StatelessWidget {
  const ThoughtsSegmentedTabs({
    super.key,
    required this.section,
    required this.onChanged,
  });

  final ThoughtsSection section;
  final ValueChanged<ThoughtsSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: ThoughtsTheme.surfaceDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        radius: BorderRadius.circular(999),
        shadowEnabled: false,
      ),
      child: Row(
        children: <Widget>[
          _TabChip(
            label: '想法区',
            selected: section == ThoughtsSection.ideas,
            onTap: () => onChanged(ThoughtsSection.ideas),
          ),
          _TabChip(
            label: '文摘区',
            selected: section == ThoughtsSection.excerpts,
            onTap: () => onChanged(ThoughtsSection.excerpts),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7DCDC) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: ThoughtsTheme.rose.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: ThoughtsTheme.body(
                size: 15,
                weight: FontWeight.w700,
                color: selected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

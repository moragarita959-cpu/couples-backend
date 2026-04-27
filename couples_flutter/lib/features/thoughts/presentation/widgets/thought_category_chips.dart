import 'package:flutter/material.dart';

import '../theme/thoughts_theme.dart';

class ThoughtCategoryChips<T> extends StatelessWidget {
  const ThoughtCategoryChips({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = item == selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelected(item),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: ThoughtsTheme.chipDecoration(selected: isSelected),
              child: Text(
                labelBuilder(item),
                style: ThoughtsTheme.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: isSelected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

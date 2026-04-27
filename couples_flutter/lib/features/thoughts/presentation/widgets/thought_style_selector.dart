import 'package:flutter/material.dart';

import '../theme/thoughts_theme.dart';

class ThoughtStyleSelector extends StatelessWidget {
  const ThoughtStyleSelector({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.labelBuilder,
    required this.onSelected,
    this.previewBuilder,
  });

  final String title;
  final List<String> options;
  final String currentValue;
  final String Function(String value) labelBuilder;
  final ValueChanged<String> onSelected;
  final Widget Function(String value, bool selected)? previewBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: ThoughtsTheme.body(
            size: 14,
            weight: FontWeight.w700,
            color: ThoughtsTheme.ink,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = option == currentValue;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(option),
                child: Container(
                  width: 84,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? ThoughtsTheme.rose.withValues(alpha: 0.68)
                          : ThoughtsTheme.border,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: previewBuilder?.call(option, selected) ??
                            _DefaultPreview(
                              label: labelBuilder(option),
                              selected: selected,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labelBuilder(option),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ThoughtsTheme.body(
                          size: 11,
                          weight: FontWeight.w700,
                          color: selected ? ThoughtsTheme.ink : ThoughtsTheme.softInk,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: options.length,
          ),
        ),
      ],
    );
  }
}

class _DefaultPreview extends StatelessWidget {
  const _DefaultPreview({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF8E6E7) : const Color(0xFFF7F3F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label.characters.first,
          style: ThoughtsTheme.title(size: 20),
        ),
      ),
    );
  }
}

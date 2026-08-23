import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

/// Compact filter chip used on search and jobs.
class DegloorFilterChip extends StatelessWidget {
  const DegloorFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: DegloorTheme.cardBackground,
        selectedColor: DegloorTheme.accent,
        labelStyle: DegloorTheme.labelSmall.copyWith(
          color: selected ? DegloorTheme.primary : DegloorTheme.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? DegloorTheme.primary : DegloorTheme.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

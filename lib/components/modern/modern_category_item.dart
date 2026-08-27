import 'package:flutter/material.dart';
import 'package:degloor_one/core/degloor_theme.dart';

class ModernCategoryItem extends StatelessWidget {
  const ModernCategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
              boxShadow: DegloorTheme.softShadow,
              border: Border.all(color: DegloorTheme.border),
            ),
            child: Center(
              child: IconTheme(
                data: const IconThemeData(
                  color: DegloorTheme.primary,
                  size: 32,
                ),
                child: icon,
              ),
            ),
          ),
          const SizedBox(height: DegloorTheme.spacingSM),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DegloorTheme.labelSmall.copyWith(
                color: DegloorTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

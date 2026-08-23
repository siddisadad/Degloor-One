import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class HomeFeatureShortcuts extends StatelessWidget {
  const HomeFeatureShortcuts({
    super.key,
    required this.onServices,
    required this.onJobs,
    required this.onOrders,
  });

  final VoidCallback onServices;
  final VoidCallback onJobs;
  final VoidCallback onOrders;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutTile(
            icon: Icons.handyman_rounded,
            label: 'Services',
            accent: DegloorTheme.primary,
            onTap: onServices,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShortcutTile(
            icon: Icons.work_rounded,
            label: 'Jobs',
            accent: DegloorTheme.secondary,
            onTap: onJobs,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShortcutTile(
            icon: Icons.receipt_long_rounded,
            label: 'Orders',
            accent: const Color(0xFF2E7D6B),
            onTap: onOrders,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DegloorTheme.cardBackground,
      elevation: 0,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(color: DegloorTheme.border),
            boxShadow: DegloorTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: DegloorTheme.labelSmall.copyWith(
                  color: DegloorTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

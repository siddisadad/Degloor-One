import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

/// Centers auth forms so they stay readable on wide web layouts.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static const maxWidth = 520.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Branded title block used on phone, OTP, and password screens.
class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            color: DegloorTheme.accent,
            borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
            border: Border.all(color: DegloorTheme.border),
          ),
          child: const BrandMark(size: 48, showWordmark: true, compact: true),
        ),
        const SizedBox(height: 22),
        Text(title, style: DegloorTheme.headingLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: DegloorTheme.bodyMedium.copyWith(
            color: DegloorTheme.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

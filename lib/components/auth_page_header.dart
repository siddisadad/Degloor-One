import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centers auth forms so they stay readable on wide web layouts.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: const BrandMark(size: 48, showWordmark: true, compact: true),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          style: theme.headlineMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w800),
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.bodyMedium.override(
            font: GoogleFonts.inter(),
            color: theme.secondaryText,
            lineHeight: 1.45,
          ),
        ),
      ],
    );
  }
}

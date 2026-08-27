import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Shown on Auth screens when a live host probe fails.
/// Guest / dead FlutterFlow-host mode must not show this — Continue as Guest
/// is the path, not restoring a project.
class SupabaseUnreachableBanner extends StatelessWidget {
  const SupabaseUnreachableBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.error),
        ),
        child: Text(
          text,
          style: theme.bodySmall.override(color: theme.error),
        ),
      ),
    );
  }
}

import 'package:degloor_one/backend/supabase/supabase_connection.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Shown on Auth screens when the compiled FlutterFlow Supabase host is down.
class SupabaseUnreachableBanner extends StatelessWidget {
  const SupabaseUnreachableBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message ??
        (SupabaseConnection.shouldSkipAuthRequest
            ? SupabaseConnection.unreachableMessage
            : null);
    if (text == null) return const SizedBox.shrink();

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

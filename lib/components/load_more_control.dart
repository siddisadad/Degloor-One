import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Footer control for paged lists (orders, inbox).
class LoadMoreControl extends StatelessWidget {
  const LoadMoreControl({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      child: TextButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.primary,
                ),
              )
            : Text(
                'Load more',
                style: theme.titleSmall.override(
                  font: GoogleFonts.inter(),
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

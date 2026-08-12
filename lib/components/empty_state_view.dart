import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.buttonText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            ],
            if (buttonText != null && onTap != null) ...[
              const SizedBox(height: 32),
              FFButtonWidget(
                onPressed: onTap,
                text: buttonText!,
                options: FFButtonOptions(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

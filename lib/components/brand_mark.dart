import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared DEGLOOR ONE mark used on splash, auth, and home.
///
/// Swap [kBrandImageAsset] onto a real file under `assets/images/` when a
/// logo is provided; until then this renders a compact D1 monogram.
const kBrandImageAsset = 'assets/images/app_brand.png';
const kBrandName = 'DEGLOOR ONE';
const kBrandTagline = 'Everything Local. One App.';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 72,
    this.showWordmark = false,
    this.wordmarkColor,
    this.taglineColor,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;
  final Color? taglineColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final mark = _Monogram(size: size);

    if (!showWordmark) return mark;

    final titleStyle = (compact ? theme.titleMedium : theme.headlineMedium)
        .override(
      font: GoogleFonts.inter(fontWeight: FontWeight.w800),
      color: wordmarkColor ?? theme.primaryText,
      fontSize: compact ? 18 : 28,
      letterSpacing: compact ? 0.2 : 0.4,
    );
    final taglineStyle = theme.bodySmall.override(
      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
      color: taglineColor ?? theme.secondaryText,
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(kBrandName, style: titleStyle),
                Text(kBrandTagline, style: taglineStyle),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 16),
        Text(kBrandName, style: titleStyle),
        const SizedBox(height: 6),
        Text(kBrandTagline, style: taglineStyle),
      ],
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary,
            theme.primary.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'D1',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
    );
  }
}

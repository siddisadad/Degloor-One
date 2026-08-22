import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared DEGLOOR ONE mark used on splash, auth, home, and profile.
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
    final glow = !compact && showWordmark;
    final mark = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.32),
              blurRadius: size * 0.28,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: const Color(0xFF0A1B3D).withValues(alpha: glow ? 0.28 : 0.16),
            blurRadius: size * 0.16,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          kBrandImageAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          semanticLabel: kBrandName,
        ),
      ),
    );

    if (!showWordmark) return mark;

    final titleColor = wordmarkColor ?? theme.primaryText;
    final accent = taglineColor ?? theme.secondary;
    final titleStyle = (compact ? theme.titleMedium : theme.headlineMedium)
        .override(
      font: GoogleFonts.inter(fontWeight: FontWeight.w800),
      color: titleColor,
      fontSize: compact ? 17 : 28,
      letterSpacing: compact ? 0.15 : 0.4,
    );
    final taglineStyle = theme.bodySmall.override(
      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
      color: accent,
    );

    if (compact) {
      // Scale down instead of flex so this works in start-aligned columns
      // and as a non-flex sibling in a header Row.
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kBrandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
                Text(
                  kBrandTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: taglineStyle,
                ),
              ],
            ),
          ],
        ),
      );
    }

    final onDark = (taglineColor ?? titleColor).computeLuminance() > 0.7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.12)
                : theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : theme.secondary.withValues(alpha: 0.28),
            ),
          ),
          child: Text(kBrandTagline, style: taglineStyle),
        ),
      ],
    );
  }
}

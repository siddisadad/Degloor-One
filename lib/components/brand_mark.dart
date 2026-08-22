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
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        kBrandImageAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        semanticLabel: kBrandName,
      ),
    );

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
      // Auth/profile screens place this in a start-aligned Column. Flexible
      // inside a shrink-wrapped Row throws; Expanded fails as a sibling in
      // another Row. Scale the lockup down when the parent is narrow.
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 10),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 12),
        Text(kBrandTagline, style: taglineStyle),
      ],
    );
  }
}

import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact 5 / 10 / 15 km control plus an optional Open Now chip.
class DiscoveryRadiusBar extends StatelessWidget {
  const DiscoveryRadiusBar({
    super.key,
    required this.selectedKm,
    required this.onChanged,
    this.openNow = false,
    this.onOpenNowToggle,
  });

  final double selectedKm;
  final ValueChanged<double> onChanged;
  final bool openNow;
  final VoidCallback? onOpenNowToggle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final selected = snapDiscoveryRadius(selectedKm).toInt();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.alternate),
            ),
            child: Row(
              children: [
                for (final radius in kDiscoveryRadiiKm)
                  Expanded(
                    child: _RadiusSegment(
                      label: '${radius.toInt()} km',
                      selected: selected == radius.toInt(),
                      onTap: () => onChanged(radius),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (onOpenNowToggle != null) ...[
          const SizedBox(width: 10),
          _OpenNowChip(selected: openNow, onTap: onOpenNowToggle!),
        ],
      ],
    );
  }
}

class _RadiusSegment extends StatelessWidget {
  const _RadiusSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: theme.labelMedium.override(
              fontFamily: GoogleFonts.inter().fontFamily,
              color: selected ? Colors.white : theme.secondaryText,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenNowChip extends StatelessWidget {
  const _OpenNowChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? theme.success : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? theme.success : theme.alternate,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.success.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
                size: 16,
                color: selected ? Colors.white : theme.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                'Open now',
                style: theme.labelMedium.override(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  color: selected ? Colors.white : theme.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

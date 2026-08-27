import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/shared/order_lifecycle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact status pill used on customer, shop, and tracking order cards.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  static Color colorFor(BuildContext context, String status) {
    final theme = FlutterFlowTheme.of(context);
    switch (OrderLifecycle.normalizeStatus(status)) {
      case OrderLifecycle.pending:
        return theme.warning;
      case OrderLifecycle.accepted:
        return theme.info;
      case OrderLifecycle.ready:
        return theme.secondary;
      case OrderLifecycle.shipping:
      case OrderLifecycle.outForDelivery:
        return theme.primary;
      case OrderLifecycle.delivered:
        return theme.success;
      case OrderLifecycle.cancelled:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(context, status);
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
      ),
      child: Text(
        OrderLifecycle.label(status, l10n: AppLocalizations.of(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.labelSmall.override(
          font: GoogleFonts.inter(),
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

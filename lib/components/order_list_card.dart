import 'package:degloor_one/components/order_status_chip.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared order card used by customer and shop lists.
class OrderListCard extends StatelessWidget {
  const OrderListCard({
    super.key,
    required this.title,
    required this.orderId,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    this.leading,
    this.subtitle,
    this.footer,
    this.onTap,
  });

  final String title;
  final String orderId;
  final DateTime? createdAt;
  final double totalAmount;
  final String status;
  final Widget? leading;
  final String? subtitle;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;

    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            border: Border.all(color: theme.alternate),
            boxShadow: [tokens.shadow.sm],
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      SizedBox(width: tokens.spacing.sm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleSmall.override(
                              font: GoogleFonts.inter(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order #$shortId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.labelSmall,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OrderStatusChip(status: status),
                      ),
                    ),
                  ],
                ),
                Divider(height: tokens.spacing.lg, color: theme.alternate),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        createdAt == null
                            ? '—'
                            : dateTimeFormat('MMM d, yyyy · HH:mm', createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall,
                      ),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: theme.titleSmall.override(
                        font: GoogleFonts.inter(),
                        color: theme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (footer != null) ...[
                  SizedBox(height: tokens.spacing.md),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

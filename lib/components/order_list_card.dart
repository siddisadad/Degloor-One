import 'package:degloor_one/components/order_status_chip.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

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
    final shortId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;

    return Material(
      color: DegloorTheme.cardBackground,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusLG),
            border: Border.all(color: DegloorTheme.border),
            boxShadow: DegloorTheme.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(DegloorTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: DegloorTheme.spacingSM),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DegloorTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order #$shortId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DegloorTheme.labelSmall,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DegloorTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: DegloorTheme.spacingSM),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OrderStatusChip(status: status),
                      ),
                    ),
                  ],
                ),
                const Divider(height: DegloorTheme.spacingLG, color: DegloorTheme.border),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        createdAt == null
                            ? '—'
                            : dateTimeFormat('MMM d, yyyy · HH:mm', createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DegloorTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: DegloorTheme.titleMedium.copyWith(
                        color: DegloorTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (footer != null) ...[
                  const SizedBox(height: DegloorTheme.spacingMD),
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

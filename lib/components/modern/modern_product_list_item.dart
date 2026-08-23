import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class ModernProductListItem extends StatelessWidget {
  const ModernProductListItem({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.stockQuantity,
    this.trackInventory = false,
    this.onTap,
    this.onActionPressed,
    this.actionLabel = 'Add',
    this.trailing,
    super.key,
  });

  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final int? stockQuantity;
  final bool trackInventory;
  final VoidCallback? onTap;
  final VoidCallback? onActionPressed;
  final String actionLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final inStock = !trackInventory || (stockQuantity ?? 0) > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
          border: Border.all(color: DegloorTheme.border),
          boxShadow: DegloorTheme.softShadow,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          memCacheWidth: memCachePx(context, 90),
                          memCacheHeight: memCachePx(context, 90),
                          placeholder: (_, __) => Container(color: DegloorTheme.accent),
                          errorWidget: (_, __, ___) => _fallbackImg(),
                        )
                      : _fallbackImg(),
                ),
                if (!inStock)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                    ),
                    child: const Center(
                      child: Text(
                        'OUT OF STOCK',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DegloorTheme.titleMedium.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  if (description?.isNotEmpty == true)
                    Text(
                      description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DegloorTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: DegloorTheme.headingMedium.copyWith(color: DegloorTheme.primary, fontSize: 18),
                          ),
                          if (inStock && trackInventory)
                            Text(
                              'Stock: $stockQuantity',
                              style: DegloorTheme.labelSmall.copyWith(color: DegloorTheme.success),
                            ),
                        ],
                      ),
                      if (onActionPressed != null && inStock)
                        ElevatedButton(
                          onPressed: onActionPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DegloorTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(actionLabel),
                        ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImg() {
    return Container(
      width: 90,
      height: 90,
      color: DegloorTheme.accent,
      child: const Icon(Icons.image_not_supported_rounded, color: DegloorTheme.textSecondary),
    );
  }
}

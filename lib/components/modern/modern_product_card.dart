import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class ModernProductCard extends StatelessWidget {
  const ModernProductCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.discountLabel,
    super.key,
  });

  final String name;
  final double price;
  final String imageUrl;
  final VoidCallback onTap;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(DegloorTheme.radiusMD),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: memCachePx(context, 164),
                    memCacheHeight: memCachePx(context, 140),
                    placeholder: (context, url) => Container(
                      height: 140,
                      width: double.infinity,
                      color: DegloorTheme.accent,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 140,
                      width: double.infinity,
                      color: DegloorTheme.accent,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: DegloorTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (discountLabel != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: DegloorTheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discountLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(DegloorTheme.spacingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DegloorTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: DegloorTheme.titleMedium.copyWith(color: DegloorTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

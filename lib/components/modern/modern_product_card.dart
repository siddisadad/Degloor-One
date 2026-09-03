import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class ModernProductCard extends StatelessWidget {
  const ModernProductCard({
    required this.name,
    required this.price,
    this.imageUrl,
    required this.onTap,
    this.discountLabel,
    super.key,
  });

  final String name;
  final double price;
  final String? imageUrl;
  final VoidCallback onTap;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(color: DegloorTheme.border),
            boxShadow: DegloorTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DegloorTheme.radiusMD),
                    ),
                    child: imageUrl == null || imageUrl!.isEmpty
                        ? degloorImageFallback(
                            width: double.infinity,
                            height: 116,
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl!,
                            height: 116,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            memCacheWidth: memCachePx(context, 164),
                            memCacheHeight: memCachePx(context, 116),
                            placeholder: (context, url) =>
                                degloorImageFallback(width: double.infinity, height: 116),
                            errorWidget: (context, url, error) =>
                                degloorImageFallback(width: double.infinity, height: 116),
                          ),
                  ),
                  if (discountLabel != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DegloorTheme.secondary,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DegloorTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: DegloorTheme.titleMedium.copyWith(
                        color: DegloorTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

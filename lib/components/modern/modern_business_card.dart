import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class ModernBusinessCard extends StatelessWidget {
  const ModernBusinessCard({
    required this.name,
    this.imageUrl,
    required this.category,
    required this.rating,
    required this.distance,
    required this.onTap,
    this.subcategory,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final String category;
  final double rating;
  final String distance;
  final VoidCallback onTap;
  final String? subcategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: DegloorTheme.spacingMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DegloorTheme.radiusMD),
                ),
                child: imageUrl == null || imageUrl!.isEmpty
                    ? degloorImageFallback(
                        width: double.infinity,
                        height: 120,
                        icon: Icons.storefront_rounded,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: memCachePx(context, 220),
                        memCacheHeight: memCachePx(context, 120),
                        placeholder: (context, url) => Container(
                          color: DegloorTheme.accent,
                          height: 120,
                        ),
                        errorWidget: (context, url, error) =>
                            degloorImageFallback(
                          width: double.infinity,
                          height: 120,
                          icon: Icons.storefront_rounded,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(DegloorTheme.spacingSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DegloorTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: DegloorTheme.secondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: DegloorTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DegloorTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: DegloorTheme.bodySmall),
                        const SizedBox(width: 8),
                        Text(distance, style: DegloorTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subcategory != null && subcategory!.isNotEmpty
                          ? '$category • $subcategory'
                          : category,
                      style: DegloorTheme.bodySmall,
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

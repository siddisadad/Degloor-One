import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:flutter/material.dart';

class BusinessCardWidget extends StatelessWidget {
  const BusinessCardWidget({
    super.key,
    this.category = 'Local Business',
    this.distance = 'Nearby',
    this.imgDesc,
    this.name = 'Business Name',
    this.rating = '0.0',
    this.status = 'Closed',
    this.verified = false,
    this.isOpen = false,
    this.subcategory,
  });

  final String category;
  final String distance;
  final String? imgDesc;
  final String name;
  final String rating;
  final String status;
  final bool verified;
  final bool isOpen;
  final String? subcategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        boxShadow: DegloorTheme.softShadow,
        border: Border.all(color: DegloorTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image
              Stack(
                children: [
                  imgDesc == null || imgDesc!.isEmpty
                      ? degloorImageFallback(
                          width: 110,
                          height: 130,
                          icon: Icons.storefront_rounded,
                        )
                      : CachedNetworkImage(
                          imageUrl: imgDesc!,
                          width: 110,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: memCachePx(context, 110),
                          memCacheHeight: memCachePx(context, 140),
                          placeholder: (context, url) =>
                              Container(color: DegloorTheme.accent),
                          errorWidget: (context, url, error) =>
                              degloorImageFallback(
                            width: 110,
                            height: 130,
                            icon: Icons.storefront_rounded,
                          ),
                        ),
                  if (verified)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: DegloorTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),

              // 2. Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DegloorTheme.titleMedium.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: DegloorTheme.accent,
                              borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  rating,
                                  style: DegloorTheme.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: DegloorTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star_rounded, color: DegloorTheme.secondary, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subcategory != null && subcategory!.isNotEmpty
                            ? '$category • $subcategory'
                            : category,
                        style: DegloorTheme.bodySmall
                            .copyWith(color: DegloorTheme.textSecondary),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: DegloorTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(distance, style: DegloorTheme.bodySmall),
                          const SizedBox(width: 12),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isOpen ? DegloorTheme.success : DegloorTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'Open' : 'Closed',
                            style: DegloorTheme.bodySmall.copyWith(
                              color: isOpen ? DegloorTheme.success : DegloorTheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

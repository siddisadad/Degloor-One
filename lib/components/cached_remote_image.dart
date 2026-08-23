import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Decode-size hint so list images do not keep a full-resolution bitmap.
int memCachePx(BuildContext context, double logicalSize) {
  if (!logicalSize.isFinite || logicalSize <= 0) return 1;
  final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
  return (logicalSize * dpr).round().clamp(1, 4096);
}

/// Cached remote image with a compact Degloor fallback.
class CachedRemoteImage extends StatelessWidget {
  const CachedRemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderIcon = Icons.image_not_supported_rounded,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final fallbackColor = FlutterFlowTheme.of(context).alternate;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width == null ? null : memCachePx(context, width!),
      memCacheHeight: height == null ? null : memCachePx(context, height!),
      errorWidget: (_, __, ___) => Icon(placeholderIcon, color: fallbackColor),
      placeholder: (_, __) => Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}

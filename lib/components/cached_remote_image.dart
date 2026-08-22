import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

/// Cached remote image with a compact Degloor fallback.
class CachedRemoteImage extends StatelessWidget {
  const CachedRemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_not_supported_rounded,
  });

  final String url;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final fallbackColor = FlutterFlowTheme.of(context).alternate;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
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

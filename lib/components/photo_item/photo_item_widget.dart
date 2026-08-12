import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'photo_item_model.dart';
export 'photo_item_model.dart';

class PhotoItemWidget extends StatefulWidget {
  const PhotoItemWidget({
    super.key,
    String? desc,
  }) : desc = desc ??
            'https://dimg.dreamflow.cloud/v1/image/interior%20of%20hardware%20store%20shelves';

  final String desc;

  @override
  State<PhotoItemWidget> createState() => _PhotoItemWidgetState();
}

class _PhotoItemWidgetState extends State<PhotoItemWidget> {
  late PhotoItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhotoItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 140.0,
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CachedNetworkImage(
            fadeInDuration: const Duration(),
            fadeOutDuration: const Duration(),
            imageUrl: valueOrDefault<String>(
              widget.desc,
              'https://dimg.dreamflow.cloud/v1/image/interior%20of%20hardware%20store%20shelves',
            ),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(
              color: FlutterFlowTheme.of(context).primaryBackground,
              child: Icon(
                Icons.image_not_supported_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

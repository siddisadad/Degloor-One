import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'business_card_model.dart';
export 'business_card_model.dart';

class BusinessCardWidget extends StatefulWidget {
  const BusinessCardWidget({
    super.key,
    String? category,
    String? distance,
    String? imgDesc,
    String? name,
    String? rating,
    String? status,
    bool? verified,
    bool? isOpen,
  })  : this.category = category ?? 'Hardware & Construction',
        this.distance = distance ?? '0.8',
        this.imgDesc = imgDesc ??
            'https://dimg.dreamflow.cloud/v1/image/hardware%20store%20shelves',
        this.name = name ?? 'Business Name',
        this.rating = rating ?? '0.0',
        this.status = status ?? 'Closed',
        this.verified = verified ?? false,
        this.isOpen = isOpen ?? false;

  final String category;
  final String distance;
  final String imgDesc;
  final String name;
  final String rating;
  final String status;
  final bool verified;
  final bool isOpen;

  @override
  State<BusinessCardWidget> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  late BusinessCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            FlutterFlowTheme.of(context).designToken.shadow.sm,
          ],
          borderRadius: BorderRadius.circular(
            FlutterFlowTheme.of(context).designToken.radius.lg,
          ),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            FlutterFlowTheme.of(context).designToken.spacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  FlutterFlowTheme.of(context).designToken.radius.md,
                ),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      FlutterFlowTheme.of(context).designToken.radius.md,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 0),
                    fadeOutDuration: const Duration(milliseconds: 0),
                    imageUrl: valueOrDefault<String>(
                      widget.imgDesc,
                      'https://dimg.dreamflow.cloud/v1/image/hardware%20store%20shelves',
                    ),
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, 0.0),
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              valueOrDefault<String>(
                                widget.rating,
                                '4.8',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelSmallFamily,
                                    color: FlutterFlowTheme.of(context).secondary,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(FlutterFlowTheme.of(context)
                                            .labelSmallFamily),
                                  ),
                            ),
                            Icon(
                              Icons.star_rounded,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 14.0,
                            ),
                          ].divide(SizedBox(
                              width: FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .xs)),
                        ),
                          if (widget.verified)
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  FlutterFlowTheme.of(context)
                                      .designToken
                                      .radius
                                      .xs,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 2.0, 8.0, 2.0),
                                child: Text(
                                  'VERIFIED',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                      ],
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget.name,
                        'Sharma Hardware & Steel',
                      ),
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget.category,
                        'Hardware & Construction',
                      ),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            useGoogleFonts: GoogleFonts.asMap().containsKey(
                                FlutterFlowTheme.of(context).bodySmallFamily),
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 14.0,
                            ),
                            Text(
                              valueOrDefault<String>(
                                widget.distance,
                                '0.8 km',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(FlutterFlowTheme.of(context)
                                            .bodySmallFamily),
                                  ),
                            ),
                          ].divide(SizedBox(
                              width: FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .xs)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 14.0,
                            ),
                            Text(
                              valueOrDefault<String>(
                                widget.status,
                                'Open',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: valueOrDefault<Color>(
                                      valueOrDefault<bool>(
                                        widget.isOpen,
                                        true,
                                      )
                                          ? FlutterFlowTheme.of(context).success
                                          : FlutterFlowTheme.of(context).error,
                                      FlutterFlowTheme.of(context).success,
                                    ),
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(FlutterFlowTheme.of(context)
                                            .bodySmallFamily),
                                  ),
                            ),
                          ].divide(SizedBox(
                              width: FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .xs)),
                        ),
                      ].divide(SizedBox(
                          width: FlutterFlowTheme.of(context)
                              .designToken
                              .spacing
                              .md)),
                    ),
                  ].divide(SizedBox(
                      height:
                          FlutterFlowTheme.of(context).designToken.spacing.xs)),
                ),
              ),
            ].divide(SizedBox(
                width: FlutterFlowTheme.of(context).designToken.spacing.md)),
          ),
        ),
      ),
    );
  }
}

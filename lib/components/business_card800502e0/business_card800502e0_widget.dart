import 'dart:async';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/app_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'business_card800502e0_model.dart';
export 'business_card800502e0_model.dart';

class BusinessCard800502e0Widget extends StatefulWidget {
  const BusinessCard800502e0Widget({
    super.key,
    this.address = 'Main Market, Degloor',
    this.category = 'Hardware & Steel',
    this.distance = '1.2',
    this.imgDesc = 'https://dimg.dreamflow.cloud/v1/image/hardware%20store%20exterior%20with%20tools',
    this.isOpen = false,
    this.isVerified = false,
    this.name = 'Business Name',
    this.rating = '0.0',
    this.phoneNumber,
    this.whatsappNumber,
    this.latitude,
    this.longitude,
    this.id,
  });

  final String? id;
  final String address;
  final String category;
  final String distance;
  final String imgDesc;
  final bool isOpen;
  final bool isVerified;
  final String name;
  final String rating;
  final String? phoneNumber;
  final String? whatsappNumber;
  final double? latitude;
  final double? longitude;

  @override
  State<BusinessCard800502e0Widget> createState() =>
      _BusinessCard800502e0WidgetState();
}

class _BusinessCard800502e0WidgetState
    extends State<BusinessCard800502e0Widget> {
  late BusinessCard800502e0Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusinessCard800502e0Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140.0,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      fadeInDuration: const Duration(),
                      fadeOutDuration: const Duration(),
                      imageUrl: widget.imgDesc,
                      height: 140.0,
                      fit: BoxFit.cover,
                      memCacheWidth: memCachePx(
                        context,
                        MediaQuery.sizeOf(context).width,
                      ),
                      memCacheHeight: memCachePx(context, 140),
                      errorWidget: (context, url, error) => Container(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 32,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(1.0, -1.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 4.0, 8.0, 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondary,
                                  size: 14.0,
                                ),
                                Text(
                                  widget.rating,
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                        lineHeight: 1.2,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 4.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.name,
                                maxLines: 1,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.isVerified)
                                Icon(
                                  Icons.verified_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .primary,
                                  size: 18.0,
                                ),
                            ].divide(const SizedBox(width: 4.0)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: (widget.isOpen
                                    ? FlutterFlowTheme.of(context).success
                                    : FlutterFlowTheme.of(context).error)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              FlutterFlowTheme.of(context)
                                  .designToken
                                  .radius
                                  .xs,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 4.0, 8.0, 4.0),
                            child: Text(
                              widget.isOpen ? 'Open' : 'Closed',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily:
                                        FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                    color: widget.isOpen
                                        ? FlutterFlowTheme.of(context)
                                            .success
                                        : FlutterFlowTheme.of(context)
                                            .error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.category,
                      style:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodySmall.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodySmall.fontStyle,
                                lineHeight: 1.5,
                              ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: FlutterFlowTheme.of(context).accent3,
                          size: 14.0,
                        ),
                        Expanded(
                          child: Text(
                            widget.address,
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall.fontWeight,
                                    fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall.fontStyle,
                                  lineHeight: 1.5,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ].divide(const SizedBox(width: 4.0)),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 16.0, 0.0, 16.0),
                      child: Divider(
                        height: 16.0,
                        thickness: 1.0,
                        indent: 0.0,
                        endIndent: 0.0,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.distance} away',
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .labelMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium.fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            Text(
                              'Discovery radius: ${FFAppState.instance.discoveryRadius.toInt()}km',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .labelSmall.fontWeight,
                                      fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .labelSmall.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .accent3,
                                    letterSpacing: 0.0,
                                    fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .labelSmall.fontWeight,
                                    fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelSmall.fontStyle,
                                    lineHeight: 1.2,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              icon: Icon(
                                Icons.call_outlined,
                                color:
                                    FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                if (widget.phoneNumber != null) {
                                  final url = Uri.parse('tel:${widget.phoneNumber}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                    // Log Call Click
                                    if (widget.id != null) {
                                      unawaited(
                                        ShopService.instance.trackEvent(
                                          businessId: widget.id!,
                                          eventType: ShopEvents.callClick,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              icon: Icon(
                                Icons.chat_outlined,
                                color:
                                    FlutterFlowTheme.of(context).success,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                if (widget.whatsappNumber != null) {
                                  await WhatsAppService.launchWhatsApp(
                                    phoneNumber: widget.whatsappNumber!,
                                    message: 'Hello ${widget.name}, I found your shop on DEGLOOR ONE.',
                                  );
                                  // Log WhatsApp Click
                                  if (widget.id != null) {
                                    unawaited(
                                      ShopService.instance.trackEvent(
                                        businessId: widget.id!,
                                        eventType: ShopEvents.whatsappClick,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              icon: Icon(
                                Icons.near_me_rounded,
                                color:
                                    FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                if (widget.latitude != null && widget.longitude != null) {
                                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                    // Log Directions Click
                                    if (widget.id != null) {
                                      unawaited(
                                        ShopService.instance.trackEvent(
                                          businessId: widget.id!,
                                          eventType: ShopEvents.directionsClick,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ].divide(const SizedBox(width: 8.0)),
                        ),
                      ],
                    ),
                  ].divide(const SizedBox(height: 4.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

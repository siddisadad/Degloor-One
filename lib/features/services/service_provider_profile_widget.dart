import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/components/request_service_sheet/request_service_sheet_widget.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:degloor_one/features/services/service_provider_profile_model.dart';
export 'package:degloor_one/features/services/service_provider_profile_model.dart';

class ServiceProviderProfileWidget extends StatefulWidget {
  const ServiceProviderProfileWidget({
    super.key,
    required this.providerId,
  });

  final String providerId;

  static String routeName = 'ServiceProviderProfile';
  static String routePath = '/serviceProviderProfile';

  @override
  State<ServiceProviderProfileWidget> createState() =>
      _ServiceProviderProfileWidgetState();
}

class _ServiceProviderProfileWidgetState
    extends State<ServiceProviderProfileWidget> {
  late ServiceProviderProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceProviderProfileModel());

    if (widget.providerId.isEmpty) {
      return;
    }
    _model.providerFuture =
        ServiceMarketplaceService.instance.providerById(widget.providerId);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: !kUseShowcaseData && kUsesDeadFlutterFlowHost
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: SupabaseUnreachableBanner(),
              )
            : widget.providerId.isEmpty
            ? const Center(child: Text('Provider not found.'))
            : FutureBuilder<ServiceProviderCard?>(
          future: _model.providerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading provider details: ${snapshot.error}'));
            }

            final provider = snapshot.data;
            if (provider == null || provider.id.isEmpty) {
              return const Center(child: Text('Provider not found.'));
            }
            final displayName = provider.displayName;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: provider.photoUrl == null
                        ? degloorImageFallback(
                            icon: Icons.person_rounded,
                          )
                        : CachedNetworkImage(
                            imageUrl: provider.photoUrl!,
                            fit: BoxFit.cover,
                            memCacheWidth: memCachePx(context, 400),
                            memCacheHeight: memCachePx(context, 250),
                            errorWidget: (_, __, ___) => degloorImageFallback(
                              icon: Icons.person_rounded,
                            ),
                          ),
                  ),
                  leading: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    borderWidth: 1.0,
                    buttonSize: 60.0,
                    fillColor: Colors.black26,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () => context.safePop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: FlutterFlowTheme.of(context).headlineMedium,
                                ),
                                Text(
                                  provider.categoryName,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                ),
                              ],
                            ),
                            if (provider.isVerified)
                              Icon(
                                Icons.verified_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 32,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Experience', '${provider.experienceYears ?? 0} Years'),
                            _buildStatItem(
                              'Hourly Rate',
                              provider.hourlyRateLabel,
                            ),
                          ],
                        ),
                        const Divider(height: 48),
                        Text(
                          'About',
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.bio ?? 'No bio provided.',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                lineHeight: 1.6,
                              ),
                        ),
                        const SizedBox(height: 32),
                        FFButtonWidget(
                          onPressed: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: RequestServiceSheetWidget(
                                    providerId: provider.id,
                                    providerName: displayName,
                                  ),
                                );
                              },
                            );
                          },
                          text: 'Book Service',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: Colors.white,
                                ),
                            elevation: 3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
        ),
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelSmall,
        ),
      ],
    );
  }
}

import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/components/category_item/category_item_widget.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/supabase_unreachable_banner.dart';
import 'package:degloor_one/components/request_service_sheet/request_service_sheet_widget.dart';
import 'package:degloor_one/features/services/service_provider_display.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services_model.dart';
export 'services_model.dart';

class ServicesWidget extends StatefulWidget {
  const ServicesWidget({super.key});

  static String routeName = 'Services';
  static String routePath = '/services';

  @override
  State<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {
  late ServicesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServicesModel());

    _model.categoriesFuture = ServiceMarketplaceService.instance.categories();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProviders());
  }

  Future<void> _loadProviders({bool loadMore = false}) async {
    if (_model.providersLoading) return;
    setState(() {
      _model.providersLoading = true;
      if (!loadMore) {
        _model.providers = [];
        _model.providersOffset = 0;
        _model.providersHasMore = true;
      }
    });
    try {
      final page = await ServiceMarketplaceService.instance.providers(
        categoryId: _model.selectedCategoryId,
        page: PageQuery(limit: 20, offset: _model.providersOffset),
      );
      if (!mounted) return;
      setState(() {
        _model.providers.addAll(page.items);
        _model.providersOffset += 20;
        _model.providersHasMore = page.hasMore;
        _model.providersLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _model.providersLoading = false);
    }
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      if (_model.selectedCategoryId == categoryId) {
        _model.selectedCategoryId = null;
      } else {
        _model.selectedCategoryId = categoryId;
      }
    });
    _loadProviders();
  }

  Widget getIconFromData(String? iconName) {
    switch (iconName) {
      case 'electrical_services':
        return Icon(Icons.electrical_services_rounded,
            color: FlutterFlowTheme.of(context).primary, size: 24.0);
      case 'plumbing':
        return Icon(Icons.plumbing_rounded,
            color: FlutterFlowTheme.of(context).primary, size: 24.0);
      case 'construction':
        return Icon(Icons.construction_rounded,
            color: FlutterFlowTheme.of(context).primary, size: 24.0);
      case 'cleaning_services':
        return Icon(Icons.cleaning_services_rounded,
            color: FlutterFlowTheme.of(context).primary, size: 24.0);
      default:
        return Icon(Icons.category_rounded,
            color: FlutterFlowTheme.of(context).primary, size: 24.0);
    }
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          title: Text(
            'Find local services',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            IconButton(
              tooltip: 'Offer a service',
              onPressed: () => context.pushNamed('ServiceProviderRegistration'),
              icon: Icon(
                Icons.add_business_outlined,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!kUseShowcaseData)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SupabaseUnreachableBanner(),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Text(
                  'Categories',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(
                height: 100.0,
                child: FutureBuilder<List<ServiceCategoriesRow>>(
                  future: _model.categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load categories.',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12.0),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _model.selectedCategoryId == category.id;
                        return InkWell(
                          onTap: () => _onCategorySelected(category.id),
                          child: Container(
                            decoration: isSelected ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0),
                            ) : null,
                            child: CategoryItemWidget(
                              label: category.name,
                              icon: getIconFromData(category.iconName),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 12.0),
                child: Text(
                  'Service providers',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_model.providersLoading && _model.providers.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final providers = _model.providers;
                    if (providers.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.handyman_outlined,
                        title: 'No providers here',
                        description: kUsesDeadFlutterFlowHost && !kUseShowcaseData
                            ? 'Service listings are unavailable until the server is restored.'
                            : 'Try another category or offer your own service.',
                        buttonText: _model.selectedCategoryId != null
                            ? 'Show all'
                            : 'Offer a service',
                        onTap: () {
                          if (_model.selectedCategoryId != null) {
                            _onCategorySelected(_model.selectedCategoryId!);
                          } else {
                            context.pushNamed('ServiceProviderRegistration');
                          }
                        },
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: providers.length +
                          (_model.providersHasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        if (index >= providers.length) {
                          return TextButton(
                            onPressed: _model.providersLoading
                                ? null
                                : () => _loadProviders(loadMore: true),
                            child: Text(
                              _model.providersLoading
                                  ? 'Loading...'
                                  : 'Load more',
                            ),
                          );
                        }
                        final provider = providers[index];
                        final user = provider['users'];
                        final category = provider['service_categories'];
                        final displayName = ServiceProviderDisplay.name(user);

                        return InkWell(
                          onTap: () => context.pushNamed(
                            'ServiceProviderProfile',
                            queryParameters: {
                              'providerId': serializeParam(
                                provider['id'],
                                ParamType.string,
                              ),
                            }.withoutNulls,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(
                                FlutterFlowTheme.of(context).designToken.radius.lg,
                              ),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              boxShadow: [
                                FlutterFlowTheme.of(context).designToken.shadow.sm,
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: ServiceProviderDisplay.avatarUrl(user),
                                      width: 60.0,
                                      height: 60.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: FlutterFlowTheme.of(context).titleSmall,
                                        ),
                                        Text(
                                          ServiceProviderDisplay.categoryName(category),
                                          style: FlutterFlowTheme.of(context).labelSmall,
                                        ),
                                        Text(
                                          ServiceProviderDisplay.hourlyRateLabel(
                                            provider['hourly_rate'],
                                          ),
                                          style: FlutterFlowTheme.of(context).bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
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
                                              providerId: provider['id'],
                                              providerName: displayName,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    text: 'Request',
                                    options: FFButtonOptions(
                                      width: 80.0,
                                      height: 36.0,
                                      color: FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.inter(),
                                            color: Colors.white,
                                            fontSize: 12.0,
                                          ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

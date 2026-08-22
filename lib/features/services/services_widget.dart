import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/components/category_item/category_item_widget.dart';
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

    _model.categoriesFuture = ServiceCategoriesTable().queryRows(
      queryFn: (q) => q.order('name', ascending: true),
    );

    _fetchProviders();
  }

  void _fetchProviders() {
    setState(() {
      var query = SupaFlow.client
          .from('service_providers')
          .select('*, users(full_name, avatar_url), service_categories(name)');

      if (_model.selectedCategoryId != null) {
        query = query.eq('category_id', _model.selectedCategoryId!);
      }

      _model.providersFuture = query.then((value) => value as List<dynamic>);
    });
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
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Text(
                  'Categories',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              SizedBox(
                height: 100.0,
                child: FutureBuilder<List<ServiceCategoriesRow>>(
                  future: _model.categoriesFuture,
                  builder: (context, snapshot) {
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
                          onTap: () {
                            setState(() {
                              if (_model.selectedCategoryId == category.id) {
                                _model.selectedCategoryId = null;
                              } else {
                                _model.selectedCategoryId = category.id;
                              }
                              _fetchProviders();
                            });
                          },
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
                  'Service Providers',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.inter(),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _model.providersFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final providers = snapshot.data!;
                    if (providers.isEmpty) {
                      return const Center(child: Text('No providers found in this category.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: providers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
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
                              borderRadius: BorderRadius.circular(12.0),
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

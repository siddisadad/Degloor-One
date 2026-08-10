import '/backend/supabase/supabase.dart';
import '/components/business_card800502e0/business_card800502e0_widget.dart';
import '/components/button/button_widget.dart';
import '/components/filter_chip/filter_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_results_model.dart';
export 'search_results_model.dart';

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({
    super.key,
    this.searchTerm,
    this.categoryId,
  });

  final String? searchTerm;
  final String? categoryId;

  static String routeName = 'SearchResults';
  static String routePath = '/searchResults';

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  late SearchResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<BusinessesRow>>? _searchResultsFuture;
  Future<Map<String, bool>>? _openStatusesFuture;
  Future<List<ProductsRow>>? _productResultsFuture;
  String? _currentSearchTerm;
  String? _currentCategoryId;
  Map<String, String> _categoryIdToName = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultsModel());
    _currentSearchTerm = widget.searchTerm;
    _currentCategoryId = widget.categoryId;
    _performSearch(_currentSearchTerm, categoryId: _currentCategoryId);

    BusinessCategoriesTable().queryRows().then((rows) {
      if (mounted) {
        setState(() {
          for (var row in rows) {
            _categoryIdToName[row.id] = row.name;
          }
        });
      }
    });
  }

    setState(() {
      _currentSearchTerm = term;
      _currentCategoryId = categoryId;

      if (categoryId != null) {
        _searchResultsFuture = BusinessesTable().queryRows(
          queryFn: (q) => q.eq('category_id', categoryId),
        );
      } else if (term == null || term.isEmpty) {
        _searchResultsFuture = BusinessesTable().queryRows(
          queryFn: (q) => q.order('rating', ascending: false),
        );
      } else {
        _searchResultsFuture = BusinessesTable().queryRows(
          queryFn: (q) => q.ilike('name', '%$term%'),
        );
      }

      if (term != null && term.isNotEmpty && categoryId == null) {
        _productResultsFuture = ProductsTable().queryRows(
          queryFn: (q) => q.ilike('name', '%$term%'),
        );
      } else {
        _productResultsFuture = Future.value([]);
      }

      _openStatusesFuture = _searchResultsFuture?.then((rows) =>
          getMultipleBusinessesOpenStatus(rows.map((r) => r.id).toList()));
    });
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 12.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FlutterFlowIconButton(
                                borderRadius: 8.0,
                                buttonSize: 40.0,
                                fillColor: Colors.transparent,
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  context.safePop();
                                },
                              ),
                              Expanded(
                                flex: 1,
                                child: wrapWithModel(
                                  model: _model.textFieldModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TextFieldWidget(
                                    label: '',
                                    labelPresent: false,
                                    helper: '',
                                    helperPresent: false,
                                    leadingIcon: Icon(
                                      Icons.search_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
                                    leadingIconPresent: true,
                                    trailingIconPresent: false,
                                    hint: 'Search hardware, food...',
                                    value: _currentSearchTerm,
                                    onSubmit: (val) {
                                      _performSearch(val);
                                    },
                                    variant: 'filled',
                                    error: false,
                                  ),
                                ),
                              ),
                              FlutterFlowIconButton(
                                borderColor:
                                    FlutterFlowTheme.of(context).alternate,
                                borderRadius: 8.0,
                                borderWidth: 1.0,
                                buttonSize: 40.0,
                                fillColor: Colors.transparent,
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  print('IconButton pressed ...');
                                },
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                wrapWithModel(
                                  model: _model.filterChipModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: true,
                                    label: '10 km',
                                    selected: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: 'Verified',
                                    selected: false,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: 'Open Now',
                                    selected: false,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: 'Rating 4.0+',
                                    selected: false,
                                  ),
                                ),
                              ].divide(SizedBox(width: 0.0)),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FutureBuilder<List<BusinessesRow>>(
                                future: _searchResultsFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final businesses = snapshot.data!;
                                  return FutureBuilder<Map<String, bool>>(
                                    future: _openStatusesFuture,
                                    builder: (context, statusSnapshot) {
                                      final statuses =
                                          statusSnapshot.data ?? {};
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${businesses.length} Businesses found',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelLarge
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Sort by: Relevance',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                          lineHeight: 1.2,
                                                        ),
                                                  ),
                                                  Icon(
                                                    Icons.sort_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 14.0,
                                                  ),
                                                ].divide(SizedBox(width: 4.0)),
                                              ),
                                            ],
                                          ),
                                          if (businesses.isEmpty)
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(40.0),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.search_off_rounded,
                                                      size: 64,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                    ),
                                                    Text('No results found'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ...businesses.map((business) {
                                            final isOpen =
                                                statuses[business.id] ?? false;
                                            return InkWell(
                                              onTap: () async {
                                                context.pushNamed(
                                                  'BusinessProfile',
                                                  queryParameters: {
                                                    'businessId':
                                                        serializeParam(
                                                      business.id,
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );
                                              },
                                              child: BusinessCard800502e0Widget(
                                                key: Key(
                                                    'search_${business.id}'),
                                                address: business.addressText ??
                                                    'Degloor',
                                                category: _categoryIdToName[
                                                        business.categoryId] ??
                                                    'Local Business',
                                                distance: getSimulatedDistance(
                                                        business.latitude,
                                                        business.longitude)
                                                    .replaceAll(' km', ''),
                                                imgDesc: business.imageUrl ??
                                                    'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                                                isOpen: isOpen,
                                                isVerified:
                                                    business.isVerified ??
                                                        false,
                                                name: business.name,
                                                rating: (business.rating ?? 0.0)
                                                    .toString(),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    },
                                  );
                                      FutureBuilder<List<ProductsRow>>(
                                        future: _productResultsFuture,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return Container();
                                          }
                                          final products = snapshot.data!;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.0),
                                                child: Text(
                                                  'Products found',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleMedium,
                                                ),
                                              ),
                                              ...products.map((product) {
                                                return InkWell(
                                                  onTap: () async {
                                                    context.pushNamed(
                                                      'BusinessProfile',
                                                      queryParameters: {
                                                        'businessId':
                                                            serializeParam(
                                                          product.businessId,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0.0,
                                                                0.0,
                                                                0.0,
                                                                12.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        leading: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: product
                                                                        .imageUrl ??
                                                                    'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&h=300&q=80',
                                                                width: 60,
                                                                height: 60,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                            if (product.trackInventory == true && (product.stockQuantity ?? 0) <= 0)
                                                              Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black45,
                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                ),
                                                                child: Center(
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(context).error,
                                                                      borderRadius: BorderRadius.circular(2),
                                                                    ),
                                                                    child: Text(
                                                                      'OOS',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 8,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        title:
                                                            Text(product.name),
                                                        subtitle: Text(
                                                            '₹${product.price}'),
                                                        trailing: Icon(Icons
                                                            .chevron_right_rounded),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          );
                                        },
                                      ),
                                    ].divide(SizedBox(height: 16.0)),
                                  );
                                },
                              ),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Container(
                                    child: Container(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onBackground,
                                            size: 32.0,
                                          ),
                                          Text(
                                            'Looking for more?',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                          wrapWithModel(
                                            model: _model.buttonModel,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ButtonWidget(
                                              iconPresent: false,
                                              iconEndPresent: false,
                                              content:
                                                  'Increase Radius to 15 km',
                                              variant: 'outline',
                                              size: 'small',
                                              fullWidth: false,
                                              loading: false,
                                              disabled: false,
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

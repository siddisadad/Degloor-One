import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/components/button/button_widget.dart';
import 'package:degloor_one/components/filter_chip/filter_chip_widget.dart';
import 'package:degloor_one/components/text_field/text_field_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart' as ff_widgets;
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/components/discovery_radius_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_results_model.dart';
export 'search_results_model.dart';

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({
    super.key,
    this.searchTerm,
    this.categoryId,
    this.openNow,
  });

  final String? searchTerm;
  final String? categoryId;
  final bool? openNow;

  static String routeName = 'SearchResults';
  static String routePath = '/searchResults';

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  late SearchResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusinessesRow> _businesses = [];
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoading = false;

  String? _currentSearchTerm;
  String? _currentCategoryId;
  final Map<String, String> _categoryIdToName = {};

  bool _onlyVerified = false;
  bool _onlyOpen = false;
  bool _minRating4 = false;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultsModel());
    _currentSearchTerm = widget.searchTerm;
    _currentCategoryId = widget.categoryId;
    _onlyOpen = widget.openNow ?? false;
    _performSearch(_currentSearchTerm, categoryId: _currentCategoryId);

    DiscoveryService.instance.categories().then((rows) {
      if (mounted) {
        setState(() {
          for (var row in rows) {
            _categoryIdToName[row.id] = row.name;
          }
        });
      }
    });
  }

  Future<void> _performSearch(String? term, {String? categoryId, bool loadMore = false}) async {
    if (loadMore && _isLoading) return;
    final token = loadMore ? _searchToken : ++_searchToken;

    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _businesses = [];
        _offset = 0;
        _hasMore = true;
      }
      _currentSearchTerm = term;
      _currentCategoryId = categoryId;
    });

    final userLoc = FFAppState.instance.userLocation;
    final radius = FFAppState.instance.discoveryRadius;

    if (userLoc != null) {
      try {
        final page = await DiscoveryService.instance.search(
          DiscoverySearch(
            latitude: userLoc.latitude,
            longitude: userLoc.longitude,
            radiusKm: radius,
            searchTerm: term,
            categoryId: categoryId,
            verifiedOnly: _onlyVerified,
            openNow: _onlyOpen,
            minRating: _minRating4 ? 4.0 : 0.0,
            page: PageQuery(limit: _limit, offset: _offset),
          ),
        );
        final newBusinesses = page.items;
        if (!mounted || token != _searchToken) return;

        setState(() {
          _businesses.addAll(newBusinesses);
          _isLoading = false;
          _offset += _limit;
          if (newBusinesses.length < _limit) {
            _hasMore = false;
          }
        });
      } catch (e) {
        if (mounted && token == _searchToken) {
          setState(() => _isLoading = false);
        }
        AppLogger.error('Search error', e);
      }
    } else if (mounted && token == _searchToken) {
      setState(() {
        _businesses = [];
        _isLoading = false;
        _hasMore = false;
      });
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 12.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
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
                                    hint: AppLocalizations.of(context)!.searchPlaceholder,
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
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Sort By', style: FlutterFlowTheme.of(context).titleMedium),
                                          const SizedBox(height: 16),
                                          ListTileTheme(
                                            data: const ListTileThemeData(
                                              iconColor: DegloorTheme.primary,
                                              textColor: DegloorTheme.textPrimary,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Material(
                                                  color: Colors.transparent,
                                                  child: ListTile(
                                                    leading: const Icon(Icons.social_distance_rounded),
                                                    title: const Text('Distance (Nearest First)'),
                                                    onTap: () {
                                                      setState(() {
                                                        _businesses.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                                Material(
                                                  color: Colors.transparent,
                                                  child: ListTile(
                                                    leading: const Icon(Icons.star_rounded, color: Colors.amber),
                                                    title: const Text('Rating (Highest First)'),
                                                    onTap: () {
                                                      setState(() {
                                                        _businesses.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ].divide(const SizedBox(width: 16.0)),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                wrapWithModel(
                                  model: _model.filterChipModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: true,
                                    label:
                                        '${FFAppState.instance.discoveryRadius.toInt()} km',
                                    selected: true,
                                    onTap: () async {
                                      final result =
                                          await showModalBottomSheet<double>(
                                        context: context,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          var draft = snapDiscoveryRadius(
                                            FFAppState
                                                .instance.discoveryRadius,
                                          );
                                          return StatefulBuilder(
                                            builder: (context, setSheetState) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        24, 12, 24, 28),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: 36,
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .alternate,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Search radius',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Show shops within this distance of your pin.',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontFamily:
                                                                GoogleFonts
                                                                        .inter()
                                                                    .fontFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    DiscoveryRadiusBar(
                                                      selectedKm: draft,
                                                      onChanged: (radius) {
                                                        setSheetState(() =>
                                                            draft = radius);
                                                      },
                                                    ),
                                                    const SizedBox(height: 20),
                                                    ff_widgets.FFButtonWidget(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, draft),
                                                      text: 'Apply',
                                                      options: ff_widgets
                                                          .FFButtonOptions(
                                                        width:
                                                            double.infinity,
                                                        height: 48,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        elevation: 0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                      if (result != null) {
                                        setState(() {
                                          FFAppState.instance.discoveryRadius =
                                              result;
                                        });
                                        _performSearch(_currentSearchTerm,
                                            categoryId: _currentCategoryId);
                                      }
                                    },
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: AppLocalizations.of(context)!.verified,
                                    selected: _onlyVerified,
                                    onTap: () {
                                      setState(() {
                                        _onlyVerified = !_onlyVerified;
                                        _performSearch(_currentSearchTerm, categoryId: _currentCategoryId);
                                      });
                                    },
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: AppLocalizations.of(context)!.openNow,
                                    selected: _onlyOpen,
                                    onTap: () {
                                      setState(() {
                                        _onlyOpen = !_onlyOpen;
                                        _performSearch(_currentSearchTerm, categoryId: _currentCategoryId);
                                      });
                                    },
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterChipModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterChipWidget(
                                    hasIcon: false,
                                    label: 'Rating 4.0+',
                                    selected: _minRating4,
                                    onTap: () {
                                      setState(() {
                                        _minRating4 = !_minRating4;
                                        _performSearch(_currentSearchTerm, categoryId: _currentCategoryId);
                                      });
                                    },
                                  ),
                                ),
                              ].divide(const SizedBox(width: 0.0)),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Builder(
                                builder: (context) {
                                  final businesses = _businesses;
                                  final showNoResults = businesses.isEmpty && !_isLoading;

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (businesses.isNotEmpty) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                      .spaceBetween,
                                          children: [
                                            Text(
                                              '${businesses.length} shops within ${FFAppState.instance.discoveryRadius.toInt()} km',
                                              style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge.override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLargeFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        ...businesses.map((business) {
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor:
                                                Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                'BusinessProfile',
                                                queryParameters: {
                                                  'businessId':
                                                      serializeParam(
                                                    business.id,
                                                    ParamType.string,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: BusinessCardWidget(
                                              key: Key(
                                                  'search_${business.id}'),
                                              name: business.name,
                                              category: _categoryIdToName[
                                                      business.categoryId] ??
                                                  'Local Business',
                                              distance: business.distanceKm !=
                                                      null
                                                  ? (business.distanceKm! <
                                                          1.0
                                                      ? '${(business.distanceKm! * 1000).toInt()} m'
                                                      : '${business.distanceKm!.toStringAsFixed(1)} km')
                                                  : 'Nearby',
                                              imgDesc: business.imageUrl ??
                                                  'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                                              rating: (business.rating ?? 0.0)
                                                  .toString(),
                                              status:
                                                  (business.isOpen ?? false)
                                                      ? 'Open'
                                                      : 'Closed',
                                              verified:
                                                  business.isVerified ??
                                                      false,
                                              isOpen:
                                                  business.isOpen ?? false,
                                            ),
                                          );
                                        }),
                                        if (_hasMore)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                                            child: ff_widgets.FFButtonWidget(
                                              onPressed: () => _performSearch(_currentSearchTerm, categoryId: _currentCategoryId, loadMore: true),
                                              text: 'Load More',
                                              options: ff_widgets.FFButtonOptions(
                                                height: 40.0,
                                                color: FlutterFlowTheme.of(context).primary,
                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                  fontFamily: GoogleFonts.inter().fontFamily,
                                                  color: Colors.white,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                      ],
                                      if (_isLoading && businesses.isEmpty)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      if (showNoResults)
                                        EmptyStateView(
                                          icon: FFAppState.instance.userLocation == null
                                              ? Icons.location_off_rounded
                                              : Icons.search_off_rounded,
                                          title: FFAppState.instance.userLocation == null
                                              ? AppLocalizations.of(context)!.locationRequired
                                              : AppLocalizations.of(context)!.noResultsFound,
                                          description: FFAppState.instance.userLocation == null
                                              ? AppLocalizations.of(context)!.enableLocationDescription
                                              : AppLocalizations.of(context)!.noResultsDescription,
                                          buttonText: FFAppState.instance.userLocation == null
                                              ? AppLocalizations.of(context)!.enableLocation
                                              : null,
                                          onTap: FFAppState.instance.userLocation == null
                                              ? () => LocationService.updateCurrentLocation(context)
                                              : null,
                                        ),
                                    ].divide(const SizedBox(height: 16.0)),
                                  );
                                },
                              ),
                              if (_businesses.isEmpty &&
                                  !_isLoading &&
                                  nextDiscoveryRadius(FFAppState
                                          .instance.discoveryRadius) !=
                                      null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Looking for more?',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: GoogleFonts.inter()
                                                  .fontFamily,
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .secondaryText,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      wrapWithModel(
                                        model: _model.buttonModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonWidget(
                                          iconPresent: false,
                                          iconEndPresent: false,
                                          content:
                                              'Increase radius to ${nextDiscoveryRadius(FFAppState.instance.discoveryRadius)!.toInt()} km',
                                          variant: 'outline',
                                          size: 'small',
                                          fullWidth: false,
                                          loading: false,
                                          disabled: false,
                                          onTap: () async {
                                            final next = nextDiscoveryRadius(
                                                FFAppState.instance
                                                    .discoveryRadius);
                                            if (next == null) return;
                                            setState(() {
                                              FFAppState.instance
                                                      .discoveryRadius =
                                                  next;
                                            });
                                            _performSearch(
                                                _currentSearchTerm,
                                                categoryId:
                                                    _currentCategoryId);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ].divide(const SizedBox(height: 16.0)),
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

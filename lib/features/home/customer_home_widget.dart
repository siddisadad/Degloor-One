import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';

import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/components/category_item/category_item_widget.dart';
import 'package:degloor_one/backend/cart_service.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_theme.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_widgets.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_icon_button.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/components/brand_mark.dart';
import 'package:degloor_one/components/discovery_radius_bar.dart';
import 'package:degloor_one/components/home_feature_shortcuts.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'customer_home_model.dart';
export 'customer_home_model.dart';

class CustomerHomeWidget extends StatefulWidget {
  const CustomerHomeWidget({super.key});

  static String routeName = 'CustomerHome';
  static String routePath = '/customerHome';

  @override
  State<CustomerHomeWidget> createState() => _CustomerHomeWidgetState();
}

class _CustomerHomeWidgetState extends State<CustomerHomeWidget> {
  late CustomerHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<BusinessCategoriesRow>>? _categoriesFuture;
  List<BusinessesRow> _nearbyBusinesses = [];
  bool _nearbyLoading = false;
  bool _nearbyHasMore = true;
  int _nearbyOffset = 0;
  int _nearbyToken = 0;
  static const _nearbyPageSize = 6;
  final Map<String, String> _categoryIdToName = {};
  int _cartItemCount = 0;

  void _onAppStateChanged() {
    if (mounted) {
      _resolveLocation();
      _fetchBusinesses();
      _fetchCartCount();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomerHomeModel());

    // Listen to global app state changes (like location updates)
    FFAppState.instance.addListener(_onAppStateChanged);

    if (loggedIn && currentUserUid.length > 10) {
      _model.userProfileFuture = DiscoveryService.instance.profile(currentUserUid);
    }
    _categoriesFuture = DiscoveryService.instance.categories();
    _categoriesFuture?.then((rows) {
      if (mounted) {
        setState(() {
          for (var row in rows) {
            _categoryIdToName[row.id] = row.name;
          }
        });
      }
    });
    _fetchBusinesses();
    _resolveLocation();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    final count = await CartService.getCartItemCount();
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  Future<void> _resolveLocation() async {
    if (kIsWeb) {
      // Geocoding package does not support web.
      return;
    }
    final userLoc = FFAppState.instance.userLocation;
    if (userLoc != null) {
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          userLoc.latitude,
          userLoc.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final name = [p.locality, p.administrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .join(', ');
          if (name.isNotEmpty) {
            if (mounted) {
              setState(() {
                _model.locationName = name;
              });
            }
          }
        }
      } catch (e) {
        AppLogger.error('Error resolving location name', e);
      }
    }
  }

  void _fetchBusinesses() {
    final userLoc = FFAppState.instance.userLocation;
    final radius = FFAppState.instance.discoveryRadius;

    _nearbyToken++;
    _nearbyBusinesses = [];
    _nearbyOffset = 0;
    _nearbyLoading = false;
    _nearbyHasMore = userLoc != null;
    if (userLoc != null) {
      _model.openNowBusinessesFuture = DiscoveryService.instance
          .search(
            DiscoverySearch(
              latitude: userLoc.latitude,
              longitude: userLoc.longitude,
              radiusKm: radius,
              openNow: true,
              page: const PageQuery(limit: 8),
            ),
          )
          .then((page) => page.items);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMoreNearby();
      });
    } else {
      _model.openNowBusinessesFuture = Future.value([]);
      _nearbyLoading = false;
    }
  }

  Future<void> _loadMoreNearby() async {
    final userLoc = FFAppState.instance.userLocation;
    if (userLoc == null || _nearbyLoading || !_nearbyHasMore) return;

    final token = _nearbyToken;
    setState(() => _nearbyLoading = true);
    try {
      final page = await DiscoveryService.instance.search(
        DiscoverySearch(
          latitude: userLoc.latitude,
          longitude: userLoc.longitude,
          radiusKm: FFAppState.instance.discoveryRadius,
          openNow: _model.openNow,
          page: PageQuery(limit: _nearbyPageSize, offset: _nearbyOffset),
        ),
      );
      if (!mounted || token != _nearbyToken) return;
      setState(() {
        _nearbyBusinesses.addAll(page.items);
        _nearbyOffset += _nearbyPageSize;
        _nearbyHasMore = page.hasMore;
        _nearbyLoading = false;
      });
    } catch (e) {
      AppLogger.error('Nearby businesses error', e);
      if (mounted && token == _nearbyToken) {
        setState(() => _nearbyLoading = false);
      }
    }
  }

  Widget getIconFromData(String? iconName) {
    final iconMap = {
      'shopping_basket_rounded': Icons.shopping_basket_rounded,
      'restaurant_rounded': Icons.restaurant_rounded,
      'construction_rounded': Icons.construction_rounded,
      'bolt_rounded': Icons.bolt_rounded,
      'medical_services_rounded': Icons.medical_services_rounded,
      'directions_car_rounded': Icons.directions_car_rounded,
      'checkroom_rounded': Icons.checkroom_rounded,
      'content_cut_rounded': Icons.content_cut_rounded,
      'home_repair_service_rounded': Icons.home_repair_service_rounded,
      'local_pharmacy_rounded': Icons.local_pharmacy_rounded,
      'electrical_services_rounded': Icons.electrical_services_rounded,
      'agriculture_rounded': Icons.agriculture_rounded,
    };

    return Icon(
      iconMap[iconName] ?? Icons.category_rounded,
      color: FlutterFlowTheme.of(context).primary,
      size: 24.0,
    );
  }

  @override
  void dispose() {
    FFAppState.instance.removeListener(_onAppStateChanged);
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryRadius = context.select<FFAppState, double>(
      (state) => state.discoveryRadius,
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      FlutterFlowTheme.of(context).designToken.spacing.lg,
                      FlutterFlowTheme.of(context).designToken.spacing.lg,
                      FlutterFlowTheme.of(context).designToken.spacing.lg,
                      FlutterFlowTheme.of(context).designToken.spacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BrandMark(size: 44),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('LocationRadiusSelector');
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: FlutterFlowTheme.of(context).secondary,
                                    size: 18.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                    _model.locationName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.4,
                                        ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color:
                                        FlutterFlowTheme.of(context).secondaryText,
                                    size: 18.0,
                                  ),
                                ].divide(const SizedBox(width: 4.0)),
                              ),
                              Text(
                                'Within ${discoveryRadius.toInt()} km radius',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.5,
                                        ),
                              ),
                            ].divide(const SizedBox(height: 2.0)),
                          ),
                          ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Row(
                          children: [
                            Stack(
                              children: [
                                FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 8.0,
                                  buttonSize: 44.0,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await context.pushNamed('Cart');
                                    _fetchCartCount();
                                  },
                                ),
                                if (_cartItemCount > 0)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).error,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      child: Text(
                                        '$_cartItemCount',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 8.0,
                              buttonSize: 44.0,
                              fillColor:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                context.pushNamed('Notifications');
                              },
                            ),
                            if (!kBypassAuth)
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 8.0,
                              buttonSize: 44.0,
                              fillColor:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              icon: Icon(
                                Icons.logout_rounded,
                                color: FlutterFlowTheme.of(context).error,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Sign Out'),
                                    content: const Text(
                                        'Are you sure you want to sign out?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await authManager.signOut();
                                  if (mounted) {
                                    if (!context.mounted) return;
                                    context.goNamed('Authentication');
                                  }
                                }
                              },
                            ),
                            InkWell(
                              onTap: () {
                                context.pushNamed('UserProfileReports');
                              },
                              child: Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  boxShadow: [
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .shadow
                                        .sm,
                                  ],
                                  borderRadius: BorderRadius.circular(
                                      FlutterFlowTheme.of(context)
                                          .designToken
                                          .radius
                                          .md),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: FutureBuilder<List<UsersRow>>(
                                  future: _model.userProfileFuture,
                                  builder: (context, snapshot) {
                                    final userRow = snapshot.data?.firstOrNull;
                                    final fullName = userRow?.fullName ?? '';
                                    final initials = fullName
                                        .split(' ')
                                        .take(2)
                                        .map((e) => e.isNotEmpty ? e[0] : '')
                                        .join()
                                        .toUpperCase();
                                    return Text(
                                      initials.isEmpty ? 'U' : initials,
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .onPrimary,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .fontStyle,
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ].divide(SizedBox(
                            width:
                                FlutterFlowTheme.of(context).designToken.spacing.sm,
                          )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    0.0,
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    FlutterFlowTheme.of(context).designToken.spacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kUseShowcaseData)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              FlutterFlowTheme.of(context).designToken.radius.lg,
                            ),
                          ),
                          child: Row(
                            children: [
                              const BrandMark(size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Demo catalog is on — shops, cart, orders, jobs, and services are ready to tap.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            FlutterFlowTheme.of(context).designToken.shadow.sm,
                          ],
                          borderRadius: BorderRadius.circular(
                              FlutterFlowTheme.of(context)
                                  .designToken
                                  .radius
                                  .lg),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed('SearchResults');
                              },
                              child: Padding(
                                padding: EdgeInsets.all(
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .spacing
                                        .md),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .onSurface,
                                      size: 24.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Search shops, services, or jobs',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge,
                                      ),
                                    ),
                                    Icon(
                                      Icons.tune_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 20.0,
                                    ),
                                  ].divide(SizedBox(
                                      width: FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .md)),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: DiscoveryRadiusBar(
                                selectedKm: discoveryRadius,
                                openNow: _model.openNow,
                                onChanged: (radius) {
                                  setState(() {
                                    FFAppState.instance.discoveryRadius = radius;
                                    _fetchBusinesses();
                                  });
                                },
                                onOpenNowToggle: () {
                                  setState(() {
                                    _model.openNow = !_model.openNow;
                                    _fetchBusinesses();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      HomeFeatureShortcuts(
                        onServices: () => context.pushNamed('Services'),
                        onJobs: () => context.pushNamed('JobsMarketplace'),
                        onOrders: () => context.pushNamed('CustomerOrders'),
                      ),
                    ].divide(SizedBox(
                        height:
                            FlutterFlowTheme.of(context).designToken.spacing.md)),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    0.0,
                    0.0,
                    0.0,
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          FlutterFlowTheme.of(context).designToken.spacing.lg,
                          0.0,
                          FlutterFlowTheme.of(context).designToken.spacing.lg,
                          0.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                              AppLocalizations.of(context)!.categories,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            ),
                            InkWell(
                              onTap: () async {
                                context.pushNamed('Categories');
                              },
                              child: Text(
                                AppLocalizations.of(context)!.seeAll,
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      color: FlutterFlowTheme.of(context).primary,
                                      lineHeight: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<BusinessCategoriesRow>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: FlutterFlowTheme.of(context).error),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Failed to load categories',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _categoriesFuture =
                                          DiscoveryService.instance.categories();
                                    }),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          final categories = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .spacing
                                        .lg,
                                    0.0,
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .spacing
                                        .lg,
                                    0.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: categories
                                        .map((category) {
                                          return InkWell(
                                            onTap: () async {
                                              context.pushNamed(
                                                'SearchResults',
                                                queryParameters: {
                                                  'categoryId': serializeParam(
                                                    category.id,
                                                    ParamType.string,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: CategoryItemWidget(
                                              key: Key('category_${category.id}'),
                                              icon: getIconFromData(
                                                  category.iconName),
                                              label: category.name,
                                            ),
                                          );
                                        })
                                        .toList()
                                        .divide(SizedBox(
                                            width: FlutterFlowTheme.of(context)
                                                .designToken
                                                .spacing
                                                .md)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ].divide(SizedBox(
                        height:
                            FlutterFlowTheme.of(context).designToken.spacing.md)),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    0.0,
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.openNow,
                            style: FlutterFlowTheme.of(context).titleLarge,
                          ),
                          InkWell(
                            onTap: () async {
                              context.pushNamed(
                                'SearchResults',
                                queryParameters: {
                                  'openNow': serializeParam(
                                    true,
                                    ParamType.bool,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: Text(
                              'Filter',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelLargeFamily,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<List<BusinessesRow>>(
                        future: _model.openNowBusinessesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .spacing
                                        .lg),
                                child: Column(
                                  children: [
                                    const Text('Unable to load businesses'),
                                    FFButtonWidget(
                                      onPressed: () => setState(() {
                                        _fetchBusinesses();
                                      }),
                                      text: 'Try Again',
                                      options: FFButtonOptions(
                                        height: 40,
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Colors.white,
                                              useGoogleFonts: GoogleFonts.asMap()
                                                  .containsKey(
                                                      FlutterFlowTheme.of(context)
                                                          .titleSmallFamily),
                                            ),
                                        borderRadius: BorderRadius.circular(
                                            FlutterFlowTheme.of(context)
                                                .designToken
                                                .radius
                                                .md),
                                      ),
                                    ),
                                  ].divide(SizedBox(
                                      height: FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .md)),
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container();
                          }
                          final businesses = snapshot.data!;
                          if (businesses.isEmpty) return Container();
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: businesses.map((business) {
                                    final isOpen = business.isOpen ?? false;
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0,
                                          0.0,
                                          FlutterFlowTheme.of(context)
                                              .designToken
                                              .spacing
                                              .md,
                                          0.0),
                                      child: InkWell(
                                        onTap: () async {
                                          context.pushNamed(
                                            'BusinessProfile',
                                            queryParameters: {
                                              'businessId': serializeParam(
                                                business.id,
                                                ParamType.string,
                                              ),
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: 280.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            boxShadow: [
                                              FlutterFlowTheme.of(context)
                                                  .designToken
                                                  .shadow
                                                  .sm,
                                            ],
                                            borderRadius: BorderRadius.circular(
                                                FlutterFlowTheme.of(context)
                                                    .designToken
                                                    .radius
                                                    .lg),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                      FlutterFlowTheme.of(context)
                                                          .designToken
                                                          .radius
                                                          .lg),
                                                  topRight: Radius.circular(
                                                      FlutterFlowTheme.of(context)
                                                          .designToken
                                                          .radius
                                                          .lg),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: business.imageUrl ??
                                                      'https://images.unsplash.com/photo-1534723452862-4c874018d66d?auto=format&fit=crop&w=400&h=300&q=80',
                                                  height: 120.0,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_rounded,
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                    FlutterFlowTheme.of(context)
                                                        .designToken
                                                        .spacing
                                                        .md),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          business.name,
                                                          style:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium,
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isOpen
                                                                ? FlutterFlowTheme.of(context).success
                                                                : FlutterFlowTheme.of(context).error,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .designToken
                                                                        .radius
                                                                        .xs),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal: 6,
                                                                    vertical: 2),
                                                            child: Text(
                                                              isOpen ? 'OPEN' : 'CLOSED',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmallFamily,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    useGoogleFonts: GoogleFonts
                                                                            .asMap()
                                                                        .containsKey(
                                                                            FlutterFlowTheme.of(context)
                                                                                .labelSmallFamily),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${_categoryIdToName[business.categoryId] ?? 'Local Business'} • ${business.distanceKm != null ? (business.distanceKm! < 1.0 ? '${(business.distanceKm! * 1000).toInt()} m' : '${business.distanceKm!.toStringAsFixed(1)} km') : 'Nearby'}',
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall,
                                                    ),
                                                  ].divide(SizedBox(
                                                      height: FlutterFlowTheme.of(
                                                              context)
                                                          .designToken
                                                          .spacing
                                                          .xs)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        },
                      ),
                    ].divide(SizedBox(
                        height:
                            FlutterFlowTheme.of(context).designToken.spacing.md)),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    0.0,
                    FlutterFlowTheme.of(context).designToken.spacing.lg,
                    FlutterFlowTheme.of(context).designToken.spacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                            AppLocalizations.of(context)!.nearbyBusinesses,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).titleLarge,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed('SearchResults');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.seeAll,
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          if (_nearbyLoading && _nearbyBusinesses.isEmpty) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            );
                          }
                          final businesses = _nearbyBusinesses;
                          if (businesses.isEmpty) {
                            final hasLocation =
                                FFAppState.instance.userLocation != null;
                            return EmptyStateView(
                              icon: hasLocation
                                  ? Icons.search_off_rounded
                                  : Icons.location_off_rounded,
                              title: hasLocation
                                  ? AppLocalizations.of(context)!.noResultsFound
                                  : AppLocalizations.of(context)!
                                      .locationRequired,
                              description: hasLocation
                                  ? AppLocalizations.of(context)!
                                      .noResultsDescription
                                  : AppLocalizations.of(context)!
                                      .enableLocationDescription,
                              buttonText: hasLocation
                                  ? AppLocalizations.of(context)!.discoveryArea
                                  : AppLocalizations.of(context)!.enableLocation,
                              onTap: hasLocation
                                  ? () =>
                                      context.pushNamed('LocationRadiusSelector')
                                  : () => LocationService.updateCurrentLocation(
                                      context),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...businesses
                                  .map((business) {
                                    final isOpen = business.isOpen ?? false;
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          'BusinessProfile',
                                          queryParameters: {
                                            'businessId': serializeParam(
                                              business.id,
                                              ParamType.string,
                                            ),
                                          },
                                        );
                                      },
                                      child: BusinessCardWidget(
                                        key: Key('business_${business.id}'),
                                        name: business.name,
                                        category: _categoryIdToName[
                                                business.categoryId] ??
                                            'Local Business',
                                        distance: business.distanceKm != null
                                            ? (business.distanceKm! < 1.0
                                                ? '${(business.distanceKm! * 1000).toInt()} m'
                                                : '${business.distanceKm!.toStringAsFixed(1)} km')
                                            : 'Nearby',
                                        imgDesc: business.imageUrl ??
                                            'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
                                        rating:
                                            (business.rating ?? 0.0).toString(),
                                        status: isOpen ? 'Open' : 'Closed',
                                        verified: business.isVerified ?? false,
                                        isOpen: isOpen,
                                      ),
                                    );
                                  })
                                  .toList()
                                  .divide(SizedBox(
                                      height: FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .md)),
                              if (_nearbyHasMore)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: FFButtonWidget(
                                    onPressed:
                                        _nearbyLoading ? null : _loadMoreNearby,
                                    text: _nearbyLoading
                                        ? 'Loading...'
                                        : 'Load more',
                                    options: FFButtonOptions(
                                      height: 40,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                          ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ].divide(SizedBox(
                        height:
                            FlutterFlowTheme.of(context).designToken.spacing.md)),
                  ),
                ),
                Container(
                  height: FlutterFlowTheme.of(context).designToken.spacing.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

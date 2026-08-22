import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';

import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/components/category_item/category_item_widget.dart';
import 'package:degloor_one/backend/cart_service.dart';
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
  Future<List<BusinessesRow>>? _businessesFuture;
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
      _model.userProfileFuture = UsersTable().queryRows(
        queryFn: (q) => q.eq('id', currentUserUid),
      );
    }
    _categoriesFuture = BusinessCategoriesTable().queryRows(
      queryFn: (q) => q.order('display_order', ascending: true),
    );
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

    if (userLoc != null) {
      _businessesFuture = BusinessesTable().searchInRadius(
        latitude: userLoc.latitude,
        longitude: userLoc.longitude,
        radiusKm: radius,
        openNow: _model.openNow,
      );
      // Always fetch open businesses for the horizontal section
      _model.openNowBusinessesFuture = BusinessesTable().searchInRadius(
        latitude: userLoc.latitude,
        longitude: userLoc.longitude,
        radiusKm: radius,
        openNow: true,
      );
    } else {
      _businessesFuture = Future.value([]);
      _model.openNowBusinessesFuture = Future.value([]);
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
    final appState = Provider.of<FFAppState>(context);
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
                        Expanded(
                          child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('LocationRadiusSelector');
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
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
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .fontWeight,
                                          ),
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
                                'Within ${appState.discoveryRadius.toInt()} km radius',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    FlutterFlowTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontStyle,
                                          lineHeight: 1.5,
                                        ),
                              ),
                            ].divide(const SizedBox(height: 4.0)),
                          ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Row(
                          children: [
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 8.0,
                              buttonSize: 44.0,
                              fillColor:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              icon: Icon(
                                Icons.handyman_outlined,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              onPressed: () {
                                context.pushNamed('Services');
                              },
                            ),
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 8.0,
                              buttonSize: 44.0,
                              fillColor:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              icon: Icon(
                                Icons.work_outline_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                              onPressed: () {
                                context.pushNamed('JobsMarketplace');
                              },
                            ),
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
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed('SearchResults');
                        },
                        child: Container(
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
                          child: Padding(
                            padding: EdgeInsets.all(FlutterFlowTheme.of(context)
                                .designToken
                                .spacing
                                .md),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: FlutterFlowTheme.of(context).onSurface,
                                  size: 24.0,
                                ),
                                Expanded(
                                  child: Text(
                                    'What do you need? (e.g. Electrician)',
                                    style: FlutterFlowTheme.of(context).bodyLarge,
                                  ),
                                ),
                                Icon(
                                  Icons.tune_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
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
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [2, 5, 10, 15, 25]
                                  .map((radius) {
                                    final isSelected =
                                        appState.discoveryRadius.toInt() ==
                                            radius;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          appState.discoveryRadius =
                                              radius.toDouble();
                                          _fetchBusinesses();
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        height: 34.0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          borderRadius: BorderRadius.circular(
                                              FlutterFlowTheme.of(context)
                                                  .designToken
                                                  .radius
                                                  .full),
                                          border: Border.all(
                                            color: isSelected
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .alternate,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${radius}km',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmallFamily,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList()
                                  .divide(SizedBox(
                                      width: FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .sm)),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _model.openNow = !_model.openNow;
                                  _fetchBusinesses();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 34.0,
                                decoration: BoxDecoration(
                                  color: _model.openNow
                                      ? FlutterFlowTheme.of(context).success
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  borderRadius: BorderRadius.circular(
                                      FlutterFlowTheme.of(context)
                                          .designToken
                                          .radius
                                          .full),
                                  border: Border.all(
                                    color: _model.openNow
                                        ? FlutterFlowTheme.of(context).success
                                        : FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .md,
                                      0.0,
                                      FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .md,
                                      0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _model.openNow
                                            ? Icons.check_circle_rounded
                                            : Icons.access_time_filled_rounded,
                                        size: 14,
                                        color: _model.openNow
                                            ? Colors.white
                                            : FlutterFlowTheme.of(context)
                                                .secondaryText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Open Now',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMediumFamily,
                                              fontWeight: _model.openNow
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: _model.openNow
                                                  ? Colors.white
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 13.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(
                              width: FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .sm)),
                        ),
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
                                          BusinessCategoriesTable().queryRows(
                                        queryFn: (q) => q.order('display_order',
                                            ascending: true),
                                      );
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
                      FutureBuilder<List<BusinessesRow>>(
                        future: _businessesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            );
                          }
                          final businesses = snapshot.data!;
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
                            children: businesses
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
                                      rating: (business.rating ?? 0.0).toString(),
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

import 'package:degloor_one/components/cached_remote_image.dart';
import 'package:degloor_one/components/category_icon.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/components/modern/hero_banner.dart';
import 'package:degloor_one/components/modern/modern_category_item.dart';
import 'package:degloor_one/components/modern/modern_business_card.dart';
import 'package:degloor_one/components/modern/modern_product_card.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/l10n/app_localizations.dart';

import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/features/catalogue/product_detail_widget.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/core/app_flags.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'customer_home_model.dart';
export 'customer_home_model.dart';

@visibleForTesting
bool discoveryInputsChanged({
  required LatLng? previousLocation,
  required double? previousRadius,
  required LatLng? nextLocation,
  required double nextRadius,
}) {
  return previousLocation != nextLocation || previousRadius != nextRadius;
}

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

  Future<List<ShopCategory>>? _categoriesFuture;
  Future<List<ServiceProviderCard>>? _servicesFuture;
  final Map<String, String> _categoryIdToName = {};
  LatLng? _lastDiscoveryLocation;
  double? _lastDiscoveryRadius;

  void _onAppStateChanged() {
    if (!mounted) return;
    final userLoc = FFAppState.instance.userLocation;
    final radius = FFAppState.instance.discoveryRadius;
    if (!discoveryInputsChanged(
      previousLocation: _lastDiscoveryLocation,
      previousRadius: _lastDiscoveryRadius,
      nextLocation: userLoc,
      nextRadius: radius,
    )) {
      return;
    }
    if (userLoc != _lastDiscoveryLocation) {
      _resolveLocation();
    }
    _fetchBusinesses();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomerHomeModel());

    _lastDiscoveryLocation = FFAppState.instance.userLocation;
    _lastDiscoveryRadius = FFAppState.instance.discoveryRadius;
    FFAppState.instance.addListener(_onAppStateChanged);

    if (loggedIn && currentUserUid.length > 10) {
      _model.userProfileFuture = UserService.instance.profile(currentUserUid);
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
    _fetchServices();
    _resolveLocation();
  }

  void _fetchServices() {
    _servicesFuture = ServiceMarketplaceService.instance
        .providers(page: const PageQuery(limit: 6))
        .then((page) => page.items);
  }

  Future<void> _resolveLocation() async {
    if (kIsWeb || kUseShowcaseData) return;
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
    _lastDiscoveryLocation = userLoc;
    _lastDiscoveryRadius = radius;

    if (userLoc != null) {
      _model.openNowBusinessesFuture = DiscoveryService.instance
          .search(
            DiscoverySearch(
              latitude: userLoc.latitude,
              longitude: userLoc.longitude,
              radiusKm: radius,
              page: const PageQuery(limit: 8),
              openNow: true,
            ),
          )
          .then((page) => page.items);

      _model.newBusinessesFuture = DiscoveryService.instance
          .search(
            DiscoverySearch(
              latitude: userLoc.latitude,
              longitude: userLoc.longitude,
              radiusKm: radius,
              page: const PageQuery(limit: 15),
            ),
          )
          .then((page) {
        final now = DateTime.now();
        if (recent.isNotEmpty) {
          recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return recent;
        }
        final sorted = [...page.items]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(5).toList();
      });

      _model.recommendedProductsFuture = DiscoveryService.instance
          .searchProducts(
            DiscoverySearch(
              latitude: userLoc.latitude,
              longitude: userLoc.longitude,
              radiusKm: radius,
              page: const PageQuery(limit: 10),
            ),
          )
          .then((page) => page.items);
    } else {
      _model.openNowBusinessesFuture = Future.value([]);
      _model.newBusinessesFuture = Future.value([]);
      _model.recommendedProductsFuture = Future.value([]);
    }
  }

  String get _locationLabel {
    final name = _model.locationName.trim();
    if (name.isEmpty) return 'Degloor';
    return name.split(',').first.trim();
  }

  @override
  void dispose() {
    FFAppState.instance.removeListener(_onAppStateChanged);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.select<FFAppState, double>((state) => state.discoveryRadius);

    return Scaffold(
      backgroundColor: DegloorTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchBusinesses();
            _fetchServices();
            setState(() {});
          },
          color: DegloorTheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: DegloorTheme.background,
                elevation: 0,
                leadingWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.only(left: DegloorTheme.spacingMD),
                  child: InkWell(
                    onTap: () => context.pushNamed('LocationRadiusSelector'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: DegloorTheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _locationLabel,
                            style: DegloorTheme.titleMedium.copyWith(height: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: DegloorTheme.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: DegloorTheme.textPrimary,
                    ),
                    onPressed: () => context.pushNamed('Notifications'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: DegloorTheme.spacingMD),
                    child: InkWell(
                      onTap: () => context.pushNamed('MyProfile'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: DegloorTheme.primary,
                          borderRadius:
                              BorderRadius.circular(DegloorTheme.radiusSM),
                        ),
                        child: Center(
                          child: FutureBuilder<List<UserProfile>>(
                            future: _model.userProfileFuture,
                            builder: (context, snapshot) {
                              final name =
                                  snapshot.data?.firstOrNull?.fullName ?? 'U';
                              return Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _searchBar(l10n)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DegloorTheme.spacingLG),
                  child: HeroBanner(
                    onExplore: () => context.pushNamed('SearchResults'),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _categories(l10n)),
              SliverToBoxAdapter(child: _newInDegloor(l10n)),
              SliverToBoxAdapter(child: _nearbyBusinesses(l10n)),
              SliverToBoxAdapter(child: _popularProducts()),
              SliverToBoxAdapter(child: _servicesNearYou()),
              const SliverToBoxAdapter(
                child: SizedBox(height: DegloorTheme.spacingXL),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DegloorTheme.spacingMD,
        0,
        DegloorTheme.spacingMD,
        DegloorTheme.spacingMD,
      ),
      child: InkWell(
        onTap: () => context.pushNamed('SearchResults'),
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            boxShadow: DegloorTheme.softShadow,
            border: Border.all(color: DegloorTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: DegloorTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n?.searchPlaceholder ?? 'Search anything...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DegloorTheme.bodyLarge
                      .copyWith(color: DegloorTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DegloorTheme.headingMedium,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: DegloorTheme.primary,
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(AppLocalizations.of(context)?.seeAll ?? 'See all'),
            ),
        ],
      ),
    );
  }

  Widget _categories(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n?.categories ?? 'Categories'),
        const SizedBox(height: DegloorTheme.spacingMD),
        FutureBuilder<List<ShopCategory>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            final shopCategories = snapshot.data ?? const <ShopCategory>[];
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DegloorTheme.spacingMD,
              ),
              child: Row(
                children: [
                  for (final cat in shopCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: DegloorTheme.spacingMD),
                      child: ModernCategoryItem(
                        label: cat.name,
                        icon: CategoryIcon(iconName: cat.iconName),
                        onTap: () => context.pushNamed(
                          'SearchResults',
                          queryParameters: {'categoryId': cat.id},
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: DegloorTheme.spacingMD),
                    child: ModernCategoryItem(
                      label: l10n?.services ?? 'Services',
                      icon: const Icon(Icons.handyman_rounded),
                      onTap: () => context.pushNamed('LocalServices'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: DegloorTheme.spacingMD),
                    child: ModernCategoryItem(
                      label: 'Jobs',
                      icon: const Icon(Icons.work_rounded),
                      onTap: () => context.pushNamed('JobsMarketplace'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: DegloorTheme.spacingLG),
      ],
    );
  }

  Widget _newInDegloor(AppLocalizations? l10n) {
    return FutureBuilder<List<Shop>>(
      future: _model.newBusinessesFuture,
      builder: (context, snapshot) {
        final businesses = snapshot.data ?? [];
        if (businesses.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('New in Degloor'),
            const SizedBox(height: DegloorTheme.spacingSM),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: DegloorTheme.spacingMD,
                ),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final biz = businesses[index];
                  return ModernBusinessCard(
                    name: biz.name,
                    imageUrl: biz.imageUrl,
                    category: _categoryIdToName[biz.categoryId] ?? 'Shop',
                    rating: biz.rating ?? 0.0,
                    distance: biz.distanceKm != null
                        ? '${biz.distanceKm!.toStringAsFixed(1)} km'
                        : 'New',
                    subcategory: biz.subcategory,
                    onTap: () => context.pushNamed(
                      'BusinessProfile',
                      queryParameters: {'businessId': biz.id},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DegloorTheme.spacingLG),
          ],
        );
      },
    );
  }

  Widget _nearbyBusinesses(AppLocalizations? l10n) {
    return FutureBuilder<List<Shop>>(
      future: _model.openNowBusinessesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 210,
            child: Center(
              child: CircularProgressIndicator(color: DegloorTheme.primary),
            ),
          );
        }
        final businesses = snapshot.data!;
        if (businesses.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              l10n?.nearbyBusinesses ?? 'Nearby Businesses',
              onSeeAll: () => context.pushNamed('SearchResults'),
            ),
            const SizedBox(height: DegloorTheme.spacingSM),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: DegloorTheme.spacingMD,
                ),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final biz = businesses[index];
                  return ModernBusinessCard(
                    name: biz.name,
                    imageUrl: biz.imageUrl,
                    category: _categoryIdToName[biz.categoryId] ?? 'Shop',
                    rating: biz.rating ?? 0.0,
                    distance: biz.distanceKm != null
                        ? '${biz.distanceKm!.toStringAsFixed(1)} km'
                        : 'Nearby',
                    subcategory: biz.subcategory,
                    onTap: () => context.pushNamed(
                      'BusinessProfile',
                      queryParameters: {'businessId': biz.id},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DegloorTheme.spacingLG),
          ],
        );
      },
    );
  }

  Widget _popularProducts() {
    return FutureBuilder<List<CatalogProduct>>(
      future: _model.recommendedProductsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 230,
            child: Center(
              child: CircularProgressIndicator(color: DegloorTheme.primary),
            ),
          );
        }
        final products = snapshot.data!;
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Popular Products',
              onSeeAll: () => context.pushNamed('SearchResults'),
            ),
            const SizedBox(height: DegloorTheme.spacingSM),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: DegloorTheme.spacingMD,
                ),
                itemCount: products.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: DegloorTheme.spacingSM + 4),
                itemBuilder: (context, index) {
                  final prod = products[index];
                  return SizedBox(
                    width: 164,
                    child: ModernProductCard(
                      name: prod.name,
                      price: prod.price ?? 0.0,
                      imageUrl: prod.imageUrl,
                      onTap: () => context.pushNamed(
                        ProductDetailWidget.routeName,
                        pathParameters: {'productId': prod.id},
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DegloorTheme.spacingLG),
          ],
        );
      },
    );
  }

  Widget _servicesNearYou() {
    return FutureBuilder<List<ServiceProviderCard>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 118,
            child: Center(
              child: CircularProgressIndicator(color: DegloorTheme.primary),
            ),
          );
        }
        final providers = snapshot.data!;
        if (providers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Services Near You',
              onSeeAll: () => context.pushNamed('LocalServices'),
            ),
            const SizedBox(height: DegloorTheme.spacingSM),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: DegloorTheme.spacingMD,
                ),
                itemCount: providers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return InkWell(
                    onTap: () => context.pushNamed(
                      'ServiceProviderProfile',
                      queryParameters: {'providerId': provider.id},
                    ),
                    borderRadius:
                        BorderRadius.circular(DegloorTheme.radiusMD),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DegloorTheme.cardBackground,
                        borderRadius:
                            BorderRadius.circular(DegloorTheme.radiusMD),
                        border: Border.all(color: DegloorTheme.border),
                        boxShadow: DegloorTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: provider.photoUrl == null
                                  ? const ColoredBox(
                                      color: DegloorTheme.accent,
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: DegloorTheme.primary,
                                        size: 22,
                                      ),
                                    )
                                  : CachedRemoteImage(
                                      url: provider.photoUrl!,
                                      width: 40,
                                      height: 40,
                                      placeholderIcon: Icons.person_rounded,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            provider.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DegloorTheme.titleMedium
                                .copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DegloorTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DegloorTheme.spacingLG),
          ],
        );
      },
    );
  }
}

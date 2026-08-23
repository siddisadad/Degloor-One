import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/components/home_feature_shortcuts.dart';
import 'package:degloor_one/components/modern/hero_banner.dart';
import 'package:degloor_one/components/modern/modern_category_item.dart';
import 'package:degloor_one/components/modern/modern_business_card.dart';
import 'package:degloor_one/components/modern/modern_product_card.dart';
import 'package:degloor_one/auth/supabase_auth/auth_util.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/l10n/app_localizations.dart';

import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/features/catalogue/product_detail_widget.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:degloor_one/app_state.dart';
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
  Future<List<ServiceProviderCard>>? _servicesFuture;
  final Map<String, String> _categoryIdToName = {};

  void _onAppStateChanged() {
    if (mounted) {
      _resolveLocation();
      _fetchBusinesses();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomerHomeModel());

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
    if (kIsWeb) return;
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
      _model.recommendedProductsFuture = Future.value([]);
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
              // 1. App Bar with Location & User
              SliverAppBar(
                floating: true,
                pinned: false,
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
                        const Icon(Icons.location_on_rounded, color: DegloorTheme.secondary, size: 20),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _model.locationName,
                                style: DegloorTheme.titleMedium.copyWith(height: 1.2),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${discoveryRadius.toInt()} km radius',
                                style: DegloorTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: DegloorTheme.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: DegloorTheme.textPrimary),
                    onPressed: () => context.pushNamed('Notifications'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: DegloorTheme.spacingMD),
                    child: InkWell(
                      onTap: () => context.pushNamed('UserProfileReports'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: DegloorTheme.primary,
                          borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                        ),
                        child: Center(
                          child: FutureBuilder<List<UserProfile>>(
                            future: _model.userProfileFuture,
                            builder: (context, snapshot) {
                              final name = snapshot.data?.firstOrNull?.fullName ?? 'U';
                              return Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(DegloorTheme.spacingMD),
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
                          Text(
                            'What are you looking for?',
                            style: DegloorTheme.bodyLarge.copyWith(color: DegloorTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DegloorTheme.spacingMD,
                    0,
                    DegloorTheme.spacingMD,
                    DegloorTheme.spacingLG,
                  ),
                  child: HomeFeatureShortcuts(
                    onServices: () => context.goNamed('Services'),
                    onJobs: () => context.pushNamed('JobsMarketplace'),
                    onOrders: () => context.pushNamed('CustomerOrders'),
                  ),
                ),
              ),

              // 3. Hero Promotion
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: DegloorTheme.spacingLG),
                  child: HeroBanner(),
                ),
              ),

              // 4. Categories
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
                      child: Text(AppLocalizations.of(context)!.categories, style: DegloorTheme.headingMedium),
                    ),
                    const SizedBox(height: DegloorTheme.spacingMD),
                    FutureBuilder<List<BusinessCategoriesRow>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox(height: 100);
                        final categories = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
                          child: Row(
                            children: categories.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ModernCategoryItem(
                                label: cat.name,
                                icon: getIconFromData(cat.iconName),
                                onTap: () => context.pushNamed('SearchResults', queryParameters: {'categoryId': cat.id}),
                              ),
                            )).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DegloorTheme.spacingLG),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DegloorTheme.spacingMD),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Local Services',
                              style: DegloorTheme.headingMedium),
                          TextButton(
                            onPressed: () => context.goNamed('Services'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DegloorTheme.spacingSM),
                    SizedBox(
                      height: 118,
                      child: FutureBuilder<List<ServiceProviderCard>>(
                        future: _servicesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          final providers = snapshot.data!;
                          if (providers.isEmpty) {
                            return const SizedBox();
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: DegloorTheme.spacingMD),
                            itemCount: providers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final provider = providers[index];
                              return InkWell(
                                onTap: () => context.pushNamed(
                                  'ServiceProviderProfile',
                                  queryParameters: {
                                    'providerId': provider.id,
                                  },
                                ),
                                borderRadius: BorderRadius.circular(
                                    DegloorTheme.radiusMD),
                                child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: DegloorTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(
                                        DegloorTheme.radiusMD),
                                    border: Border.all(
                                        color: DegloorTheme.border),
                                    boxShadow: DegloorTheme.softShadow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.handyman_rounded,
                                        color: DegloorTheme.primary,
                                        size: 22,
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: DegloorTheme.spacingLG),
                  ],
                ),
              ),

              // 5. Popular Near You (Horizontal)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Popular Near You', style: DegloorTheme.headingMedium),
                          TextButton(
                            onPressed: () => context.pushNamed('SearchResults'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DegloorTheme.spacingSM),
                    SizedBox(
                      height: 210,
                      child: FutureBuilder<List<BusinessesRow>>(
                        future: _model.openNowBusinessesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final businesses = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
                            itemCount: businesses.length,
                            itemBuilder: (context, index) {
                              final biz = businesses[index];
                              return ModernBusinessCard(
                                name: biz.name,
                                imageUrl: biz.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80',
                                category: _categoryIdToName[biz.categoryId] ?? 'Shop',
                                rating: biz.rating ?? 0.0,
                                distance: biz.distanceKm != null ? '${biz.distanceKm!.toStringAsFixed(1)} km' : 'Nearby',
                                onTap: () => context.pushNamed('BusinessProfile', queryParameters: {'businessId': biz.id}),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: DegloorTheme.spacingLG),
                  ],
                ),
              ),

              // 6. Recommended Products (Grid)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DegloorTheme.spacingMD),
                sliver: SliverToBoxAdapter(
                  child: Text('Recommended for You', style: DegloorTheme.headingMedium),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                sliver: FutureBuilder<List<ProductsRow>>(
                  future: _model.recommendedProductsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }
                    final products = snapshot.data!;
                    if (products.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox(height: 100, child: Center(child: Text('No recommendations yet'))));
                    }
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: DegloorTheme.spacingMD,
                        mainAxisSpacing: DegloorTheme.spacingMD,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prod = products[index];
                          return ModernProductCard(
                            name: prod.name,
                            price: prod.price ?? 0.0,
                            imageUrl: prod.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
                            onTap: () => context.pushNamed(
                              ProductDetailWidget.routeName,
                              pathParameters: {'productId': prod.id},
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: DegloorTheme.spacingXL)),
            ],
          ),
        ),
      ),
    );
  }
}

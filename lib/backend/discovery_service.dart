import 'package:degloor_one/backend/job_service.dart';
import 'package:degloor_one/backend/native_service_bridge.dart';
import 'package:degloor_one/backend/repositories/discovery_repository.dart';
import 'package:degloor_one/backend/service_marketplace_service.dart';
import 'package:degloor_one/backend/shop_service.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/user_service.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/search_query.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/shop_category.dart';
import 'package:degloor_one/shared/shop_event.dart';
import 'package:degloor_one/shared/showcase_catalog.dart';
import 'package:degloor_one/shared/user_profile.dart';

export 'package:degloor_one/backend/repositories/discovery_repository.dart'
    show DiscoverySearch;

class DiscoveryService {
  DiscoveryService({DiscoveryRepository? repository})
      : _repository = repository ?? DiscoveryRepository();

  final DiscoveryRepository _repository;

  static final instance = DiscoveryService();

  Future<PageResult<Shop>> search(DiscoverySearch query) async {
    final rows = await _repository.search(query);
    return PageResult(
      items: rows,
      hasMore: rows.length >= query.page.limit,
    );
  }

  Future<PageResult<CatalogProduct>> searchProducts(
    DiscoverySearch query,
  ) async {
    final rows = await _repository.searchProducts(query);
    return PageResult(
      items: rows.map(CatalogProduct.fromRow).toList(),
      hasMore: rows.length >= query.page.limit,
    );
  }

  /// Unified Degloor search across shops, products, services, and jobs.
  ///
  /// Product hits also pull in their shop so a query like "milk" surfaces
  /// Patil Kirana as well as the carton.
  Future<MasterSearchResult> masterSearch({
    required DiscoverySearch query,
    MasterSearchScope scope = MasterSearchScope.all,
  }) async {
    final wantShops =
        scope == MasterSearchScope.all || scope == MasterSearchScope.shops;
    final wantProducts =
        scope == MasterSearchScope.all || scope == MasterSearchScope.products;
    final wantServices =
        scope == MasterSearchScope.all || scope == MasterSearchScope.services;
    final wantJobs =
        scope == MasterSearchScope.all || scope == MasterSearchScope.jobs;
    final typed = SearchQuery.parse(query.searchTerm);
    final emptyAll = scope == MasterSearchScope.all && typed.isEmpty;

    final shopsFuture = wantShops
        ? search(query)
        : Future.value(const PageResult<Shop>(items: [], hasMore: false));
    final productsFuture = wantProducts && !emptyAll
        ? searchProducts(query)
        : Future.value(
            const PageResult<CatalogProduct>(items: [], hasMore: false),
          );
    final servicesFuture = wantServices && !emptyAll
        ? _searchServices(typed, page: query.page)
        : Future.value(const <ServiceProviderCard>[]);
    final jobsFuture = wantJobs && !emptyAll
        ? JobService.instance.listActive(
            search: typed.raw,
            page: query.page,
          )
        : Future.value(
            const PageResult<JobListing>(items: [], hasMore: false),
          );

    final shopsPage = await shopsFuture;
    final productsPage = await productsFuture;
    final services = await servicesFuture;
    final jobsPage = await jobsFuture;

    var shops = shopsPage.items;
    if (wantShops && productsPage.items.isNotEmpty) {
      final known = shops.map((shop) => shop.id).toSet();
      final extraIds = productsPage.items
          .map((product) => product.businessId)
          .where((id) => id.isNotEmpty && !known.contains(id))
          .toSet()
          .toList();
      if (extraIds.isNotEmpty) {
        final extra = await businessesByIds(extraIds);
        shops = [...shops, ...extra];
      }
    }

    return MasterSearchResult(
      shops: shops,
      products: productsPage.items,
      services: services,
      jobs: jobsPage.items,
    );
  }

  Future<List<ServiceProviderCard>> _searchServices(
    SearchQuery query, {
    required PageQuery page,
  }) async {
    if (kUseShowcaseData) {
      final all = ShowcaseCatalog.serviceProviders()
          .map(ServiceProviderCard.fromJoin)
          .where(
            (provider) => query.matches([
              provider.displayName,
              provider.categoryName,
              provider.bio,
            ]),
          )
          .toList();
      return all.skip(page.offset).take(page.limit).toList();
    }
    final pageResult = await ServiceMarketplaceService.instance.providers(
      page: page,
    );
    if (query.isEmpty) return pageResult.items;
    return pageResult.items
        .where(
          (provider) => query.matches([
            provider.displayName,
            provider.categoryName,
            provider.bio,
          ]),
        )
        .toList();
  }

  Future<List<ShopCategory>> categories() async {
    if (!kUseShowcaseData) {
      final native = await NativeServiceBridge.getDiscoveryCategories();
      if (native.isNotEmpty) return native;
    }
    final rows = await _repository.categories();
    return rows.map(ShopCategory.fromRow).toList();
  }

  Future<List<UserProfile>> profile(String userId) =>
      UserService.instance.profile(userId);

  Future<List<UserProfile>> usersByIds(List<String> ids) =>
      UserService.instance.byIds(ids);

  Future<List<Shop>> businessesByIds(List<String> ids) {
    return _repository.businessesByIds(ids);
  }

  Future<List<Shop>> ownedBy(String userId) {
    return _repository.ownedBy(userId);
  }

  Future<ShopInsights> insightsFor(String businessId) async {
    if (businessId.isEmpty) return ShopInsights.empty;
    final reviews = await _repository.reviewCount(businessId);
    final events = await _repository.analyticsFor(businessId);
    final summary = ShopService.summarizeEvents(
      events.map(ShopEvent.fromRow).toList(),
    );
    return ShopInsights(
      reviewCount: reviews,
      profileViews: summary.profileViews,
      callClicks: summary.callClicks,
      whatsappClicks: summary.whatsappClicks,
      directionsClicks: summary.directionsClicks,
    );
  }
}

enum MasterSearchScope { all, shops, products, services, jobs }

class MasterSearchResult {
  const MasterSearchResult({
    this.shops = const [],
    this.products = const [],
    this.services = const [],
    this.jobs = const [],
  });

  static const empty = MasterSearchResult();

  final List<Shop> shops;
  final List<CatalogProduct> products;
  final List<ServiceProviderCard> services;
  final List<JobListing> jobs;

  bool get isEmpty =>
      shops.isEmpty && products.isEmpty && services.isEmpty && jobs.isEmpty;

  int get totalCount =>
      shops.length + products.length + services.length + jobs.length;
}

class ShopInsights {
  const ShopInsights({
    required this.reviewCount,
    required this.profileViews,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directionsClicks,
  });

  static const empty = ShopInsights(
    reviewCount: 0,
    profileViews: 0,
    callClicks: 0,
    whatsappClicks: 0,
    directionsClicks: 0,
  );

  final int reviewCount;
  final int profileViews;
  final int callClicks;
  final int whatsappClicks;
  final int directionsClicks;
}

import 'dart:async';

import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/components/discovery_radius_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/components/modern/modern_product_list_item.dart';
import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/search_history.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:flutter/material.dart';
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
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  MasterSearchResult _result = MasterSearchResult.empty;
  MasterSearchScope _scope = MasterSearchScope.all;
  bool _isLoading = false;
  int _searchToken = 0;
  Timer? _debounce;

  String? _currentCategoryId;
  final Map<String, String> _categoryIdToName = {};
  List<String> _recent = const [];

  bool _onlyVerified = false;
  bool _onlyOpen = false;
  bool _minRating4 = false;
  _SearchSort _sort = _SearchSort.distance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultsModel());
    _currentCategoryId = widget.categoryId;
    _onlyOpen = widget.openNow ?? false;
    if (widget.categoryId != null) {
      _scope = MasterSearchScope.shops;
    }
    final initial = widget.searchTerm?.trim() ?? '';
    _searchController.text = initial;
    _searchController.addListener(_onQueryChanged);
    SearchHistory.load().then((items) {
      if (mounted) setState(() => _recent = items);
    });
    DiscoveryService.instance.categories().then((rows) {
      if (!mounted) return;
      setState(() {
        for (final row in rows) {
          _categoryIdToName[row.id] = row.name;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (initial.isEmpty && widget.categoryId == null) {
        _searchFocus.requestFocus();
      }
      _runSearch();
    });
  }

  void _onQueryChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final token = ++_searchToken;
    final term = _searchController.text.trim();
    setState(() => _isLoading = true);

    final userLoc = FFAppState.instance.userLocation;
    final radius = FFAppState.instance.discoveryRadius;
    if (userLoc == null) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _result = MasterSearchResult.empty;
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await DiscoveryService.instance.masterSearch(
        query: DiscoverySearch(
          latitude: userLoc.latitude,
          longitude: userLoc.longitude,
          radiusKm: radius,
          searchTerm: term,
          categoryId: _currentCategoryId,
          verifiedOnly: _onlyVerified,
          openNow: _onlyOpen,
          minRating: _minRating4 ? 4.0 : 0.0,
          page: const PageQuery(limit: 20),
        ),
        scope: _scope,
      );
      if (!mounted || token != _searchToken) return;
      setState(() {
        _result = _sorted(result);
        _isLoading = false;
      });
      if (term.isNotEmpty) {
        _recent = await SearchHistory.remember(term);
      }
    } catch (error) {
      AppLogger.error('Search error', error);
      if (mounted && token == _searchToken) {
        setState(() => _isLoading = false);
      }
    }
  }

  MasterSearchResult _sorted(MasterSearchResult result) {
    final shops = [...result.shops];
    final products = [...result.products];
    switch (_sort) {
      case _SearchSort.distance:
        shops.sort(
          (a, b) => (a.distanceKm ?? 1e9).compareTo(b.distanceKm ?? 1e9),
        );
        products.sort(
          (a, b) => (a.distanceKm ?? 1e9).compareTo(b.distanceKm ?? 1e9),
        );
      case _SearchSort.rating:
        shops.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
    return MasterSearchResult(
      shops: shops,
      products: products,
      services: result.services,
      jobs: result.jobs,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _canPop => Navigator.of(context).canPop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DegloorTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: _canPop
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: DegloorTheme.textPrimary,
                  ),
                  onPressed: () => context.safePop(),
                )
              : null,
          titleSpacing: _canPop ? 0 : 16,
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _runSearch(),
            decoration: InputDecoration(
              hintText: l10n?.searchPlaceholder ?? 'Search hardware, food...',
              hintStyle: DegloorTheme.bodyMedium.copyWith(
                color: DegloorTheme.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: DegloorTheme.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _runSearch();
                      },
                    )
                  : null,
              filled: true,
              fillColor: DegloorTheme.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                borderSide: const BorderSide(color: DegloorTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                borderSide: const BorderSide(color: DegloorTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                borderSide: const BorderSide(color: DegloorTheme.primary),
              ),
            ),
            style: DegloorTheme.bodyMedium,
          ),
          actions: [
            IconButton(
              tooltip: 'Sort',
              icon: const Icon(Icons.tune_rounded, color: DegloorTheme.primary),
              onPressed: _showSortSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final scope in MasterSearchScope.values)
                      _filterChip(
                        _scopeLabel(scope),
                        _scope == scope,
                        onTap: () {
                          setState(() => _scope = scope);
                          _runSearch();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip(
                    '${FFAppState.instance.discoveryRadius.toInt()} km',
                    true,
                    onTap: _showRadiusSheet,
                  ),
                  _filterChip(
                    l10n?.verified ?? 'Verified',
                    _onlyVerified,
                    onTap: () {
                      setState(() => _onlyVerified = !_onlyVerified);
                      _runSearch();
                    },
                  ),
                  _filterChip(
                    l10n?.openNow ?? 'Open Now',
                    _onlyOpen,
                    onTap: () {
                      setState(() => _onlyOpen = !_onlyOpen);
                      _runSearch();
                    },
                  ),
                  _filterChip(
                    'Rating 4.0+',
                    _minRating4,
                    onTap: () {
                      setState(() => _minRating4 = !_minRating4);
                      _runSearch();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(l10n)),
          ],
        ),
      ),
    );
  }

  String _scopeLabel(MasterSearchScope scope) {
    switch (scope) {
      case MasterSearchScope.all:
        return 'All';
      case MasterSearchScope.shops:
        return 'Shops';
      case MasterSearchScope.products:
        return 'Products';
      case MasterSearchScope.services:
        return 'Services';
      case MasterSearchScope.jobs:
        return 'Jobs';
    }
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading && _result.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: DegloorTheme.primary),
      );
    }
    if (FFAppState.instance.userLocation == null) {
      return EmptyStateView(
        icon: Icons.location_off_rounded,
        title: l10n?.locationRequired ?? 'Location required',
        description: l10n?.enableLocationDescription ??
            'We need your location to show nearby businesses',
        buttonText: l10n?.enableLocation ?? 'Enable location',
        onTap: () => LocationService.updateCurrentLocation(context),
      );
    }
    if (_searchController.text.trim().isEmpty &&
        _scope == MasterSearchScope.all &&
        _recent.isNotEmpty &&
        _result.shops.isEmpty) {
      return _recentList();
    }
    if (_result.isEmpty && !_isLoading) {
      if (_searchController.text.trim().isEmpty &&
          _scope == MasterSearchScope.all) {
        return _recentList();
      }
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: l10n?.noResultsFound ?? 'No results found',
        description: l10n?.noResultsDescription ??
            'Try adjusting your filters or searching for something else',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      children: [
        if (_scope == MasterSearchScope.all ||
            _scope == MasterSearchScope.shops)
          ..._shopSection(),
        if (_scope == MasterSearchScope.all ||
            _scope == MasterSearchScope.products)
          ..._productSection(),
        if (_scope == MasterSearchScope.all ||
            _scope == MasterSearchScope.services)
          ..._serviceSection(),
        if (_scope == MasterSearchScope.all || _scope == MasterSearchScope.jobs)
          ..._jobSection(),
      ],
    );
  }

  Widget _recentList() {
    if (_recent.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_rounded,
        title: 'Search Degloor',
        description:
            'Find shops, products, local services, and jobs in one place.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(DegloorTheme.spacingMD),
      children: [
        Row(
          children: [
            Text('Recent searches', style: DegloorTheme.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final cleared = await SearchHistory.clear();
                if (mounted) setState(() => _recent = cleared);
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in _recent)
              ActionChip(
                label: Text(term),
                onPressed: () {
                  _searchController
                    ..text = term
                    ..selection = TextSelection.collapsed(offset: term.length);
                  _runSearch();
                },
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _shopSection() {
    if (_result.shops.isEmpty) return const [];
    return [
      _sectionHeader('Shops', _result.shops.length, MasterSearchScope.shops),
      const SizedBox(height: 8),
      for (final shop in _result.shops) ...[
        InkWell(
          onTap: () => context.pushNamed(
            'BusinessProfile',
            queryParameters: {'businessId': shop.id},
          ),
          borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
          child: BusinessCardWidget(
            name: shop.name,
            category: _categoryIdToName[shop.categoryId] ?? 'Local Business',
            distance: shop.distanceKm != null
                ? '${shop.distanceKm!.toStringAsFixed(1)} km'
                : 'Nearby',
            imgDesc: shop.imageUrl,
            rating: (shop.rating ?? 0.0).toStringAsFixed(1),
            status: (shop.isOpen ?? false) ? 'Open' : 'Closed',
            verified: shop.isVerified ?? false,
            isOpen: shop.isOpen ?? false,
          ),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _productSection() {
    if (_result.products.isEmpty) return const [];
    return [
      _sectionHeader(
        'Products',
        _result.products.length,
        MasterSearchScope.products,
      ),
      const SizedBox(height: 8),
      for (final product in _result.products) ...[
        ModernProductListItem(
          name: product.name,
          price: product.price ?? 0,
          description: product.description,
          imageUrl: product.imageUrl,
          stockQuantity: product.stockQuantity,
          trackInventory: product.trackInventory ?? false,
          onTap: () => context.pushNamed(
            'ProductDetail',
            pathParameters: {'productId': product.id},
          ),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _serviceSection() {
    if (_result.services.isEmpty) return const [];
    return [
      _sectionHeader(
        'Services',
        _result.services.length,
        MasterSearchScope.services,
      ),
      const SizedBox(height: 8),
      for (final provider in _result.services) ...[
        _simpleTile(
          icon: Icons.handyman_rounded,
          title: provider.displayName,
          subtitle: provider.categoryName,
          onTap: () => context.pushNamed(
            'ServiceProviderProfile',
            queryParameters: {'providerId': provider.id},
          ),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _jobSection() {
    if (_result.jobs.isEmpty) return const [];
    return [
      _sectionHeader('Jobs', _result.jobs.length, MasterSearchScope.jobs),
      const SizedBox(height: 8),
      for (final job in _result.jobs) ...[
        _simpleTile(
          icon: Icons.work_outline_rounded,
          title: job.title,
          subtitle:
              '${job.shop?.displayName ?? 'Employer'} · ${job.jobType}',
          onTap: () => context.pushNamed('JobsMarketplace'),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _sectionHeader(String title, int count, MasterSearchScope scope) {
    return Row(
      children: [
        Text(title, style: DegloorTheme.headingMedium),
        const SizedBox(width: 8),
        Text('$count', style: DegloorTheme.bodySmall),
        const Spacer(),
        if (_scope == MasterSearchScope.all)
          TextButton(
            onPressed: () {
              setState(() => _scope = scope);
              _runSearch();
            },
            child: Text(AppLocalizations.of(context)?.seeAll ?? 'See All'),
          ),
      ],
    );
  }

  Widget _simpleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: DegloorTheme.cardBackground,
      borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
            border: Border.all(color: DegloorTheme.border),
            boxShadow: DegloorTheme.softShadow,
          ),
          padding: const EdgeInsets.all(DegloorTheme.spacingMD),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DegloorTheme.accent,
                  borderRadius: BorderRadius.circular(DegloorTheme.radiusSM),
                ),
                child: Icon(icon, color: DegloorTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DegloorTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DegloorTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DegloorTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: DegloorTheme.accent,
        labelStyle: TextStyle(
          color: isSelected ? DegloorTheme.primary : DegloorTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? DegloorTheme.primary : DegloorTheme.border,
          ),
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: DegloorTheme.headingMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.social_distance_rounded),
              title: const Text('Distance (nearest first)'),
              trailing: _sort == _SearchSort.distance
                  ? const Icon(Icons.check, color: DegloorTheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _sort = _SearchSort.distance;
                  _result = _sorted(_result);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text('Rating (highest first)'),
              trailing: _sort == _SearchSort.rating
                  ? const Icon(Icons.check, color: DegloorTheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _sort = _SearchSort.rating;
                  _result = _sorted(_result);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRadiusSheet() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        var draft = snapDiscoveryRadius(FFAppState.instance.discoveryRadius);
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DegloorTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Search radius', style: DegloorTheme.headingMedium),
                const SizedBox(height: 8),
                Text(
                  'Show shops within this distance of your pin.',
                  style: DegloorTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                DiscoveryRadiusBar(
                  selectedKm: draft,
                  onChanged: (radius) => setSheetState(() => draft = radius),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, draft),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DegloorTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => FFAppState.instance.discoveryRadius = result);
      _runSearch();
    }
  }
}

enum _SearchSort { distance, rating }

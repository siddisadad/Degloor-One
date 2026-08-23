import 'package:degloor_one/core/degloor_theme.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/backend/location_service.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/l10n/app_localizations.dart';
import 'package:degloor_one/components/business_card/business_card_widget.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/app_state.dart';
import 'package:degloor_one/components/discovery_radius_bar.dart';
import 'package:degloor_one/components/empty_state_view.dart';
import 'package:degloor_one/core/error_handler.dart';
import 'package:degloor_one/shared/discovery_radius.dart';
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
        backgroundColor: DegloorTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            _currentSearchTerm?.isNotEmpty == true ? _currentSearchTerm! : 'Search results',
            style: DegloorTheme.titleMedium,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: DegloorTheme.primary),
              onPressed: () => _showSortSheet(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters Row
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
                    hasIcon: true,
                  ),
                  _filterChip(
                    AppLocalizations.of(context)!.verified,
                    _onlyVerified,
                    onTap: () => setState(() { _onlyVerified = !_onlyVerified; _performSearch(_currentSearchTerm); }),
                  ),
                  _filterChip(
                    AppLocalizations.of(context)!.openNow,
                    _onlyOpen,
                    onTap: () => setState(() { _onlyOpen = !_onlyOpen; _performSearch(_currentSearchTerm); }),
                  ),
                  _filterChip(
                    'Rating 4.0+',
                    _minRating4,
                    onTap: () => setState(() { _minRating4 = !_minRating4; _performSearch(_currentSearchTerm); }),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Results List
            Expanded(
              child: _isLoading && _businesses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _businesses.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(DegloorTheme.spacingMD),
                          itemCount: _businesses.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == _businesses.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: TextButton(
                                  onPressed: () => _performSearch(_currentSearchTerm, loadMore: true),
                                  child: const Text('Load More'),
                                ),
                              );
                            }
                            final biz = _businesses[index];
                            return InkWell(
                              onTap: () => context.pushNamed('BusinessProfile', queryParameters: {'businessId': biz.id}),
                              borderRadius: BorderRadius.circular(DegloorTheme.radiusMD),
                              child: BusinessCardWidget(
                                name: biz.name,
                                category: _categoryIdToName[biz.categoryId] ?? 'Local Business',
                                distance: biz.distanceKm != null ? '${biz.distanceKm!.toStringAsFixed(1)} km' : 'Nearby',
                                imgDesc: biz.imageUrl,
                                rating: (biz.rating ?? 0.0).toStringAsFixed(1),
                                status: (biz.isOpen ?? false) ? 'Open' : 'Closed',
                                verified: biz.isVerified ?? false,
                                isOpen: biz.isOpen ?? false,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, {required VoidCallback onTap, bool hasIcon = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: DegloorTheme.primary.withValues(alpha: 0.1),
        checkmarkColor: DegloorTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? DegloorTheme.primary : DegloorTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: StadiumBorder(side: BorderSide(color: isSelected ? DegloorTheme.primary : DegloorTheme.border)),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (FFAppState.instance.userLocation == null) {
      return EmptyStateView(
        icon: Icons.location_off_rounded,
        title: AppLocalizations.of(context)!.locationRequired,
        description: AppLocalizations.of(context)!.enableLocationDescription,
        buttonText: AppLocalizations.of(context)!.enableLocation,
        onTap: () => LocationService.updateCurrentLocation(context),
      );
    }
    return EmptyStateView(
      icon: Icons.search_off_rounded,
      title: AppLocalizations.of(context)!.noResultsFound,
      description: AppLocalizations.of(context)!.noResultsDescription,
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort By', style: DegloorTheme.headingMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.social_distance_rounded),
              title: const Text('Distance (Nearest First)'),
              onTap: () {
                setState(() => _businesses.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text('Rating (Highest First)'),
              onTap: () {
                setState(() => _businesses.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0)));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusSheet() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        var draft = snapDiscoveryRadius(FFAppState.instance.discoveryRadius);
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: DegloorTheme.border, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 24),
                Text('Search radius', style: DegloorTheme.headingMedium),
                const SizedBox(height: 8),
                Text('Show shops within this distance of your pin.', style: DegloorTheme.bodySmall),
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
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => FFAppState.instance.discoveryRadius = result);
      _performSearch(_currentSearchTerm);
    }
  }
}

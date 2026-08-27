import 'package:degloor_one/backend/discovery_service.dart';
import 'package:degloor_one/flutter_flow/flutter_flow_util.dart';
import 'package:degloor_one/shared/catalog_product.dart';
import 'package:degloor_one/shared/page_query.dart';
import 'package:degloor_one/shared/shop.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'customer_home_widget.dart' show CustomerHomeWidget;
import 'package:flutter/material.dart';

class CustomerHomeModel extends FlutterFlowModel<CustomerHomeWidget> {
  ///  State fields for stateful widgets in this page.

  Future<List<UserProfile>>? userProfileFuture;
  Future<List<Shop>>? openNowBusinessesFuture;
  Future<List<Shop>>? newBusinessesFuture;
  Future<List<CatalogProduct>>? recommendedProductsFuture;
  String locationName = 'Degloor, Maharashtra';
  bool openNow = false;

  /// Newest nearby shops for the New in Degloor strip.
  List<Shop> newestShops(List<Shop> shops, {int limit = 5}) {
    final recent = [...shops]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(limit).toList();
  }

  /// The widget does not search discovery for this strip.
  void loadNewBusinesses({
    double? latitude,
    double? longitude,
    required double radiusKm,
  }) {
    if (latitude == null || longitude == null) {
      newBusinessesFuture = Future.value(const []);
      return;
    }
    newBusinessesFuture = DiscoveryService.instance
        .search(
          DiscoverySearch(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            page: const PageQuery(limit: 15),
          ),
        )
        .then((page) => newestShops(page.items));
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

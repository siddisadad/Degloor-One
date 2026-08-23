import 'package:flutter/services.dart';
import 'package:degloor_one/backend/supabase/database/tables/business_categories_table.dart';
import 'package:degloor_one/backend/supabase/database/tables/service_categories_table.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/shop_category.dart';

class NativeServiceBridge {
  static const _serviceChannel = MethodChannel('com.deshmukh.degloorone/services');
  static const _discoveryChannel = MethodChannel('com.deshmukh.degloorone/discovery');

  static List<Map<String, dynamic>> _channelMaps(List<dynamic>? rows) {
    if (rows == null) return const [];
    return [
      for (final row in rows)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
  }

  static T? _tryParse<T>(T Function() parse) {
    try {
      return parse();
    } catch (_) {
      return null;
    }
  }

  static Future<List<ServiceCategory>> getCategories() async {
    try {
      final result = await _serviceChannel.invokeMethod('getNativeCategories');
      return [
        for (final row in _channelMaps(result is List ? result : null))
          if (_tryParse(() => ServiceCategory.fromRow(ServiceCategoriesRow(row)))
              case final category?)
            category,
      ];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ServiceProviderCard>> getProviders(String? categoryId) async {
    try {
      final result = await _serviceChannel.invokeMethod(
        'getNativeProviders',
        {'categoryId': categoryId},
      );
      return [
        for (final row in _channelMaps(result is List ? result : null))
          if (_tryParse(() => ServiceProviderCard.fromJoin(row)) case final card?)
            if (card.id.isNotEmpty) card,
      ];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ShopCategory>> getDiscoveryCategories() async {
    try {
      final result =
          await _discoveryChannel.invokeMethod('getNativeDiscoveryCategories');
      return [
        for (final row in _channelMaps(result is List ? result : null))
          if (_tryParse(() => ShopCategory.fromRow(BusinessCategoriesRow(row)))
              case final category?)
            category,
      ];
    } catch (e) {
      return [];
    }
  }
}

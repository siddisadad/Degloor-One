import 'package:flutter/services.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';
import 'package:degloor_one/shared/service_category.dart';
import 'package:degloor_one/shared/shop_category.dart';

class NativeServiceBridge {
  static const _serviceChannel = MethodChannel('com.deshmukh.degloorone/services');
  static const _discoveryChannel = MethodChannel('com.deshmukh.degloorone/discovery');

  static Future<List<ServiceCategory>> getCategories() async {
    try {
      final List<dynamic>? result = await _serviceChannel.invokeMethod('getNativeCategories');
      if (result == null) return [];
      
      return result.map((e) {
        final map = Map<String, dynamic>.from(e);
        return ServiceCategory.fromRow(ServiceCategoriesRow(map));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<ServiceProviderCard>> getProviders(String? categoryId) async {
    try {
      final List<dynamic>? result = await _serviceChannel.invokeMethod('getNativeProviders', {
        'categoryId': categoryId,
      });
      if (result == null) return [];

      return [
        for (final row in result)
          if (row is Map)
            ServiceProviderCard.fromJoin(Map<String, dynamic>.from(row)),
      ];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ShopCategory>> getDiscoveryCategories() async {
    try {
      final List<dynamic>? result = await _discoveryChannel.invokeMethod('getNativeDiscoveryCategories');
      if (result == null) return [];
      
      return result.map((e) {
        final map = Map<String, dynamic>.from(e);
        return ShopCategory.fromRow(BusinessCategoriesRow(map));
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

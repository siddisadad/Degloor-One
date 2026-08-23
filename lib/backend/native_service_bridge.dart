import 'package:flutter/services.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/shared/shop_category.dart';

class NativeServiceBridge {
  static const _serviceChannel = MethodChannel('com.deshmukh.degloorone/services');
  static const _discoveryChannel = MethodChannel('com.deshmukh.degloorone/discovery');

  static Future<List<ServiceCategoriesRow>> getCategories() async {
    try {
      final List<dynamic>? result = await _serviceChannel.invokeMethod('getNativeCategories');
      if (result == null) return [];
      
      return result.map((e) {
        final map = Map<String, dynamic>.from(e);
        return ServiceCategoriesRow(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getProviders(String? categoryId) async {
    try {
      final List<dynamic>? result = await _serviceChannel.invokeMethod('getNativeProviders', {
        'categoryId': categoryId,
      });
      if (result == null) return [];
      
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
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

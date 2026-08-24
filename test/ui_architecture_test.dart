import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _barrel = "package:degloor_one/backend/supabase/supabase.dart";
const _table = 'backend/supabase/database/tables/';

void main() {
  test('screens and router do not import the Supabase table barrel', () {
    final roots = [
      Directory('lib/features'),
      Directory('lib/components'),
      Directory('lib/flutter_flow'),
    ];
    final offenders = <String>[];
    for (final root in roots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains(_barrel)) {
          offenders.add(entity.path);
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('address service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/address_service.dart',
      'lib/data/repositories/address_repository.dart',
      'lib/features/profile/address_controller.dart',
      'lib/shared/saved_address.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java address repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_address_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('user service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/user_service.dart',
      'lib/data/repositories/user_repository.dart',
      'lib/shared/user_profile.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java user repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_user_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('shop repository interface stays off Supabase', () {
    const paths = [
      'lib/backend/shop_service.dart',
      'lib/data/repositories/shop_repository.dart',
      'lib/shared/shop.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('shop listing type keeps fromJson and stays off table rows', () {
    final source = File('lib/shared/shop.dart').readAsStringSync();
    expect(source.contains('factory Shop.fromJson'), isTrue);
    expect(source.contains('BusinessesRow'), isFalse);
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('Java shop repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_shop_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('job service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/job_service.dart',
      'lib/data/repositories/job_repository.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java job repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_job_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('cart service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/cart_service.dart',
      'lib/data/repositories/cart_repository.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources') ||
          source.contains('SupaFlow.client') ||
          source.contains('core/api/cart_api.dart')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java cart repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_cart_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('order service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/order_service.dart',
      'lib/data/repositories/order_repository.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources') ||
          source.contains('SupaFlow.client') ||
          source.contains('core/api/order_api.dart')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java order repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_order_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('order leftover table repo stays off product joins and RPCs', () {
    const path = 'lib/backend/repositories/order_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains("from('order_items')"), isFalse);
    expect(source.contains('SupaFlow.client.rpc'), isFalse);
    expect(source.contains('core/api/order_api.dart'), isFalse);
  });

  test('delivery service stays off OrderApi', () {
    const path = 'lib/backend/delivery_service.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('core/api/order_api.dart'), isFalse);
    expect(source.contains('OrderApi.'), isFalse);
  });

  test('delivery service and repository interface stay off Supabase', () {
    const paths = [
      'lib/backend/delivery_service.dart',
      'lib/data/repositories/delivery_repository.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources') ||
          source.contains('SupaFlow.client') ||
          source.contains('core/api/delivery_api.dart')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java delivery repository stays off Supabase tables', () {
    const path = 'lib/data/datasources/java_delivery_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('delivery leftover table repo stays off DeliveryApi', () {
    const path = 'lib/backend/repositories/delivery_repository.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('core/api/delivery_api.dart'), isFalse);
    expect(source.contains('SupaFlow.client.rpc'), isFalse);
  });

  test('order tracking fetches OTP through OrderService', () {
    const path = 'lib/features/orders/order_tracking_widget.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('OrderService.instance.deliveryOtp'), isTrue);
    expect(source.contains('fetchMyDeliveryOtp'), isFalse);
    expect(source.contains('core/api/order_api.dart'), isFalse);
  });

  test('job leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/job_posting.dart',
      'lib/shared/job_application.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('cart leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/shopping_cart.dart',
      'lib/shared/join_rows.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('order leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/placed_order.dart',
      'lib/shared/order_status_change.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java shop orders map the customer onto JoinedUser', () {
    const path = 'lib/shared/placed_order.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('JoinedUser.fromJoin'), isTrue);
    expect(
      File('lib/features/orders/manage_orders_widget.dart')
          .readAsStringSync()
          .contains('order.user?'),
      isTrue,
    );
  });

  test('notification leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/app_notification.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java notification clear uses read-all, not table delete', () {
    const path = 'lib/backend/notification_service.dart';
    final source = File(path).readAsStringSync();
    final start = source.indexOf('Future<void> clearAll');
    expect(start, greaterThanOrEqualTo(0));
    final stop = source.indexOf('Stream<List<AppNotification>> watchForUser');
    expect(stop, greaterThan(start));
    final body = source.substring(start, stop);
    expect(body.contains('JavaApiConfig.enabled'), isTrue);
    expect(body.contains('NotificationApi.markAllRead'), isTrue);
    expect(body.contains('_repository.deleteAll'), isTrue);
  });

  test('delivery leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/delivery_assignment.dart',
      'lib/shared/delivery_partner.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java service-request inbox uses the joined customer photo', () {
    const path = 'lib/features/services/manage_service_requests_widget.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('CachedRemoteImage'), isTrue);
    expect(source.contains('photoUrl'), isTrue);
    expect(source.contains('joinedUserIds'), isTrue);
    expect(source.contains('usersByIds'), isTrue);
    final start = source.indexOf('final joinedUserIds');
    final stop = source.indexOf('DiscoveryService.instance.usersByIds');
    expect(start, greaterThanOrEqualTo(0));
    expect(stop, greaterThan(start));
    final body = source.substring(start, stop);
    expect(body.contains('joinedUserIds.add'), isTrue);
    expect(body.contains('existingUserIds.contains'), isTrue);
  });

  test('marketplace leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/service_category.dart',
      'lib/shared/service_provider_profile.dart',
      'lib/shared/service_request.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java auth user stays off Supabase tables', () {
    const path = 'lib/auth/java_auth_user.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('shop leftover domain types stay off Supabase tables', () {
    const paths = [
      'lib/shared/shop.dart',
      'lib/shared/shop_hours.dart',
      'lib/shared/catalog_product.dart',
      'lib/shared/shop_category.dart',
      'lib/shared/product_category.dart',
      'lib/shared/listing_complaint.dart',
      'lib/shared/shop_event.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) || source.contains(_table)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('shop detail and catalog interfaces stay off Supabase', () {
    const paths = [
      'lib/data/repositories/shop_detail_repository.dart',
      'lib/data/repositories/catalog_repository.dart',
      'lib/data/repositories/discovery_repository.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java leftover shop repositories stay off Supabase tables', () {
    const paths = [
      'lib/data/datasources/java_shop_detail_repository.dart',
      'lib/data/datasources/java_catalog_repository.dart',
      'lib/data/datasources/java_discovery_repository.dart',
      'lib/data/datasources/java_shop_insights.dart',
    ];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(source.contains(_barrel), isFalse, reason: path);
      expect(source.contains(_table), isFalse, reason: path);
      expect(
        source.contains('backend/shop_service.dart'),
        isFalse,
        reason: path,
      );
    }
  });

  test('profile address screens talk to the controller, not the service', () {
    const paths = [
      'lib/features/profile/add_address_widget.dart',
      'lib/features/profile/address_list_widget.dart',
    ];
    final offenders = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      if (source.contains('backend/address_service.dart') ||
          source.contains(_barrel) ||
          source.contains(_table) ||
          source.contains('data/datasources')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('Java admin API stays off Supabase tables', () {
    const path = 'lib/core/api/admin_api.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains(_barrel), isFalse);
    expect(source.contains(_table), isFalse);
  });

  test('Java public catalog GETs do not include owner or applicant routes', () {
    const path =
        'degloor-one-backend/src/main/java/com/degloor/one/common/security/SecurityConfig.java';
    final source = File(path).readAsStringSync();
    expect(source.contains('/api/v1/jobs/**'), isFalse);
    expect(source.contains('/api/v1/businesses/**'), isFalse);
    expect(source.contains('/api/v1/businesses/mine'), isTrue);
    expect(source.contains('/api/v1/businesses/search'), isTrue);
    expect(source.contains('/api/v1/businesses/nearby'), isTrue);
    expect(source.contains('/api/v1/businesses/category/*'), isTrue);
    expect(source.contains('authenticationEntryPoint'), isTrue);
  });

  test('Java API client refreshes an expired access token once', () {
    const path = 'lib/core/api/api_client.dart';
    final source = File(path).readAsStringSync();
    expect(source.contains('_tryRefresh'), isTrue);
    expect(source.contains("path != '/api/v1/auth/refresh'"), isTrue);
    expect(source.contains('allowRefresh: false'), isTrue);
  });
}

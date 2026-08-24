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
}

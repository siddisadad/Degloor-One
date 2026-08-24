import 'dart:async';
import 'dart:math';

import 'package:degloor_one/auth/guest_auth_user.dart';
import 'package:degloor_one/backend/supabase/database/showcase_query.dart';
import 'package:degloor_one/flutter_flow/lat_lng.dart';
import 'package:degloor_one/shared/search_query.dart';

class ShowcaseCatalog {
  ShowcaseCatalog._();

  static const degloorLat = 18.5522;
  static const degloorLng = 77.5844;
  static const degloor = LatLng(degloorLat, degloorLng);

  static const guestId = GuestAuthUser.guestUid;
  static const owner2 = '00000000-0000-4000-8000-000000000002';
  static const owner3 = '00000000-0000-4000-8000-000000000003';
  static const owner4 = '00000000-0000-4000-8000-000000000004';
  static const owner5 = '00000000-0000-4000-8000-000000000005';
  static const owner6 = '00000000-0000-4000-8000-000000000006';
  static const riderId = '00000000-0000-4000-8000-000000000007';
  static const customer2 = '00000000-0000-4000-8000-000000000008';
  static const adminId = '00000000-0000-4000-8000-000000000009';

  static const catGrocery = 'cat-grocery';
  static const catFood = 'cat-food';
  static const catHardware = 'cat-hardware';
  static const catElectronics = 'cat-electronics';
  static const catPharmacy = 'cat-pharmacy';
  static const catAutomotive = 'cat-automotive';
  static const catClothing = 'cat-clothing';

  static const bizPatil = 'biz-patil';
  static const bizHotel = 'biz-hotel';
  static const bizHardware = 'biz-hardware';
  static const bizMedical = 'biz-medical';
  static const bizElectronics = 'biz-electronics';
  static const bizClothing = 'biz-clothing';
  static const bizAuto = 'biz-auto';
  static const bizPending = 'biz-pending';

  static const prodMilk = 'prod-milk';
  static const prodRice = 'prod-rice';
  static const prodThali = 'prod-thali';
  static const prodPaneer = 'prod-paneer';

  static const cartGuest = 'cart-guest';
  static const orderReady = 'order-ready';
  static const orderOut = 'order-out-for-delivery';
  static const orderDelivered = 'order-delivered';

  static final Map<String, List<Map<String, dynamic>>> _tables = {};
  static final StreamController<void> _changes =
      StreamController<void>.broadcast();
  static bool _ready = false;
  static int _seq = 200;

  static Stream<void> get changes => _changes.stream;

  static void notifyChanged() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  static String nextId(String prefix) => '$prefix-${_seq++}';

  static String get _now => DateTime.now().toIso8601String();

  static void reset() {
    _ready = false;
    _tables.clear();
    _seq = 200;
  }

  static void ensureLoaded() {
    if (_ready) return;
    _ready = true;
    _seed().forEach((table, rows) {
      _tables[table] = rows.map(Map<String, dynamic>.from).toList();
    });
  }

  static List<Map<String, dynamic>> table(String name) {
    ensureLoaded();
    return _tables[name] ?? const [];
  }

  static bool matches(Map<String, dynamic> row, ShowcaseQuery q) {
    for (final entry in q.equals.entries) {
      if (!_same(row[entry.key], entry.value)) return false;
    }
    for (final entry in q.notEquals.entries) {
      if (_same(row[entry.key], entry.value)) return false;
    }
    for (final entry in q.inFilters.entries) {
      if (!entry.value.any((v) => _same(row[entry.key], v))) return false;
    }
    return true;
  }

  static List<Map<String, dynamic>> query(String tableName, ShowcaseQuery q) {
    var rows = table(tableName).where((row) => matches(row, q)).toList();

    if (q.orderColumn != null) {
      rows.sort((a, b) {
        final av = a[q.orderColumn];
        final bv = b[q.orderColumn];
        final cmp = Comparable.compare(
          av is Comparable ? av : '$av',
          bv is Comparable ? bv : '$bv',
        );
        return q.ascending ? cmp : -cmp;
      });
    }
    final start = q.offsetCount ?? 0;
    if (start > 0) {
      rows = start >= rows.length ? <Map<String, dynamic>>[] : rows.sublist(start);
    }
    if (q.limitCount != null && rows.length > q.limitCount!) {
      rows = rows.take(q.limitCount!).toList();
    }
    return rows.map(Map<String, dynamic>.from).toList();
  }

  static Map<String, dynamic> insert(
    String tableName,
    Map<String, dynamic> data,
  ) {
    ensureLoaded();
    final row = Map<String, dynamic>.from(data);
    row['id'] ??= nextId(tableName);
    row['created_at'] ??= _now;
    _tables.putIfAbsent(tableName, () => []);
    _tables[tableName]!.add(row);
    notifyChanged();
    return Map<String, dynamic>.from(row);
  }

  static List<Map<String, dynamic>> update(
    String tableName,
    Map<String, dynamic> data,
    ShowcaseQuery q,
  ) {
    final updated = <Map<String, dynamic>>[];
    for (final row in table(tableName)) {
      if (!matches(row, q)) continue;
      row.addAll(data);
      updated.add(Map<String, dynamic>.from(row));
    }
    if (updated.isNotEmpty) notifyChanged();
    return updated;
  }

  static List<Map<String, dynamic>> delete(String tableName, ShowcaseQuery q) {
    ensureLoaded();
    final kept = <Map<String, dynamic>>[];
    final removed = <Map<String, dynamic>>[];
    final hasFilter = q.equals.isNotEmpty ||
        q.notEquals.isNotEmpty ||
        q.inFilters.isNotEmpty;
    for (final row in table(tableName)) {
      if (hasFilter && matches(row, q)) {
        removed.add(Map<String, dynamic>.from(row));
      } else {
        kept.add(row);
      }
    }
    _tables[tableName] = kept;
    if (removed.isNotEmpty) notifyChanged();
    return removed;
  }

  static List<Map<String, dynamic>> searchBusinesses({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    String? categoryId,
    bool openNow = false,
    bool verifiedOnly = false,
    double minRating = 0.0,
    int limit = 20,
    int offset = 0,
  }) {
    final matches = <Map<String, dynamic>>[];
    for (final raw in table('businesses')) {
      final lat = (raw['latitude'] as num?)?.toDouble();
      final lng = (raw['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final distance = _haversineKm(latitude, longitude, lat, lng);
      if (distance > radiusKm) continue;
      if (categoryId != null && raw['category_id'] != categoryId) continue;
      if (verifiedOnly && raw['is_verified'] != true) continue;
      if (openNow && raw['is_open'] != true) continue;
      final rating = (raw['rating'] as num?)?.toDouble() ?? 0;
      if (rating < minRating) continue;
      final query = SearchQuery.parse(searchTerm);
      if (!query.isEmpty) {
        final categoryName = table('business_categories')
            .where((row) => row['id'] == raw['category_id'])
            .map((row) => '${row['name']}')
            .join(' ');
        final productNames = table('products')
            .where((row) => row['business_id'] == raw['id'])
            .map((row) => '${row['name']} ${row['description']}')
            .join(' ');
        if (!query.matches([
          raw['name']?.toString(),
          raw['description']?.toString(),
          raw['address_text']?.toString(),
          categoryName,
          productNames,
        ])) {
          continue;
        }
      }
      matches.add({
        ...raw,
        'distance_km': double.parse(distance.toStringAsFixed(2)),
      });
    }
    matches.sort((a, b) =>
        (a['distance_km'] as num).compareTo(b['distance_km'] as num));
    final sliced = matches.skip(offset).take(limit).toList();
    return sliced;
  }

  static List<Map<String, dynamic>> searchProducts({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    final bizById = {for (final b in table('businesses')) b['id']: b};
    final matches = <Map<String, dynamic>>[];
    for (final product in table('products')) {
      final biz = bizById[product['business_id']];
      if (biz == null) continue;
      final lat = (biz['latitude'] as num?)?.toDouble();
      final lng = (biz['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final distance = _haversineKm(latitude, longitude, lat, lng);
      if (distance > radiusKm) continue;
      final query = SearchQuery.parse(searchTerm);
      if (!query.matches([
        product['name']?.toString(),
        product['description']?.toString(),
        biz['name']?.toString(),
      ])) {
        continue;
      }
      matches.add({
        ...product,
        'distance_km': double.parse(distance.toStringAsFixed(2)),
      });
    }
    matches.sort((a, b) =>
        (a['distance_km'] as num).compareTo(b['distance_km'] as num));
    return matches.skip(offset).take(limit).toList();
  }

  static List<Map<String, dynamic>> orderItemsWithProducts(String orderId) {
    return query('order_items', ShowcaseQuery()..eq('order_id', orderId))
        .map((item) {
      final products =
          query('products', ShowcaseQuery()..eq('id', item['product_id']));
      return {
        ...item,
        'products': products.isEmpty ? <String, dynamic>{} : products.first,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> cartItemsWithProducts(String cartId) {
    return query('cart_items', ShowcaseQuery()..eq('cart_id', cartId))
        .map((item) {
      final products =
          query('products', ShowcaseQuery()..eq('id', item['product_id']));
      return {
        ...item,
        'products': products.isEmpty ? <String, dynamic>{} : products.first,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> reviewsForBusiness(String businessId) {
    return query('reviews', ShowcaseQuery()..eq('business_id', businessId))
        .map((review) {
      final users = query('users', ShowcaseQuery()..eq('id', review['user_id']));
      return {
        ...review,
        'users': {
          'full_name': users.isEmpty ? 'Guest' : users.first['full_name'],
        },
      };
    }).toList();
  }

  static List<Map<String, dynamic>> serviceProviders({
    String? categoryId,
    int? limit,
    int offset = 0,
  }) {
    final q = ShowcaseQuery();
    if (categoryId != null) q.eq('category_id', categoryId);
    var rows = query('service_providers', q).map((provider) {
      final users =
          query('users', ShowcaseQuery()..eq('id', provider['user_id']));
      final cats = query(
        'service_categories',
        ShowcaseQuery()..eq('id', provider['category_id']),
      );
      return {
        ...provider,
        'users': users.isEmpty
            ? {'full_name': 'Provider', 'avatar_url': null}
            : users.first,
        'service_categories':
            cats.isEmpty ? {'name': 'General'} : cats.first,
      };
    }).toList();
    if (offset > 0) {
      rows = offset >= rows.length ? <Map<String, dynamic>>[] : rows.sublist(offset);
    }
    if (limit != null && rows.length > limit) {
      rows = rows.take(limit).toList();
    }
    return rows;
  }

  static Map<String, dynamic>? serviceProvider(String id) {
    final rows = serviceProviders().where((p) => p['id'] == id);
    return rows.isEmpty ? null : rows.first;
  }

  static List<Map<String, dynamic>> activeJobs({
    String? search,
    String? jobType,
    int? limit,
    int offset = 0,
  }) {
    final q = ShowcaseQuery()..eq('is_active', true);
    if (jobType != null && jobType != 'All') q.eq('job_type', jobType);
    final parsed = SearchQuery.parse(search);
    var rows = query('jobs', q).where((job) {
      if (parsed.isEmpty) return true;
      final businesses =
          query('businesses', ShowcaseQuery()..eq('id', job['business_id']));
      final biz = businesses.isEmpty ? <String, dynamic>{} : businesses.first;
      return parsed.matches([
        job['title']?.toString(),
        job['description']?.toString(),
        job['job_type']?.toString(),
        biz['name']?.toString(),
      ]);
    }).map((job) {
      final businesses =
          query('businesses', ShowcaseQuery()..eq('id', job['business_id']));
      final biz = businesses.isEmpty ? <String, dynamic>{} : businesses.first;
      return {
        ...job,
        'businesses': {
          'name': biz['name'] ?? 'Local business',
          'location': biz['address_text'] ?? 'Degloor',
        },
      };
    }).toList();
    if (offset > 0) {
      rows = offset >= rows.length ? <Map<String, dynamic>>[] : rows.sublist(offset);
    }
    if (limit != null && rows.length > limit) {
      rows = rows.take(limit).toList();
    }
    return rows;
  }

  static List<Map<String, dynamic>> jobApplicants(String jobId) {
    return query('job_applications', ShowcaseQuery()..eq('job_id', jobId))
        .map((app) {
      final users =
          query('users', ShowcaseQuery()..eq('id', app['applicant_id']));
      return {
        ...app,
        'users': users.isEmpty
            ? {'full_name': 'Applicant'}
            : users.first,
      };
    }).toList();
  }

  static bool _same(dynamic left, dynamic right) {
    if (left == right) return true;
    if (left is num && right is num) return left.toDouble() == right.toDouble();
    return '$left' == '$right';
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earth = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * earth * asin(min(1, sqrt(a)));
  }

  static double _rad(double deg) => deg * pi / 180;

  static Map<String, List<Map<String, dynamic>>> _seed() {
    return {};
  }
}


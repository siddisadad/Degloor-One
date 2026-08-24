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
  static String _ago(Duration d) => DateTime.now().subtract(d).toIso8601String();

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
    return {
      'users': [
        _user(guestId, 'guest@local', 'Guest Customer', 'customer',
            phone: '+919890000001'),
        _user(owner2, 'suresh@degloor.local', 'Suresh Deshmukh',
            'business_owner'),
        _user(owner3, 'anjali@degloor.local', 'Anjali Kulkarni',
            'business_owner'),
        _user(owner4, 'vinod@degloor.local', 'Vinod Gupta', 'business_owner'),
        _user(owner5, 'meena@degloor.local', 'Meena Sharma', 'business_owner'),
        _user(owner6, 'rahul@degloor.local', 'Rahul More', 'business_owner'),
        _user(riderId, 'rider@degloor.local', 'Amit Jadhav', 'delivery_partner',
            phone: '+919890000007'),
        _user(customer2, 'priya@degloor.local', 'Priya Kale', 'customer'),
        _user(adminId, 'admin@degloor.local', 'Sadad Siddi', 'admin'),
        _user('user-electrician', 'ravi.e@degloor.local', 'Ravi Electrician',
            'service_provider'),
        _user('user-plumber', 'sunil.p@degloor.local', 'Sunil Plumber',
            'service_provider'),
        _user('user-carpenter', 'kishor.c@degloor.local', 'Kishor Carpenter',
            'service_provider'),
        _user('user-cleaner', 'lata.k@degloor.local', 'Lata Kamble',
            'service_provider'),
      ],
      'cities': [
        {
          'id': 'city-degloor',
          'name': 'Degloor',
          'state': 'Maharashtra',
          'district': 'Nanded',
          'created_at': _ago(const Duration(days: 40)),
        },
      ],
      'business_categories': [
        _bizCat(catGrocery, 'Grocery', 'shopping_basket_rounded', 1),
        _bizCat(catFood, 'Food', 'restaurant_rounded', 2),
        _bizCat(catHardware, 'Hardware', 'construction_rounded', 3),
        _bizCat(catElectronics, 'Electronics', 'bolt_rounded', 4),
        _bizCat(catPharmacy, 'Pharmacy', 'medical_services_rounded', 5),
        _bizCat(catAutomotive, 'Automotive', 'directions_car_rounded', 6),
        _bizCat(catClothing, 'Clothing', 'checkroom_rounded', 7),
      ],
      'businesses': [
        _biz(
          bizPatil,
          'Patil Kirana Store',
          guestId,
          'Rajesh Patil',
          catGrocery,
          'One stop shop for daily groceries and household needs.',
          'Main Road, Degloor',
          18.5525,
          77.5845,
          4.5,
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizHotel,
          'Hotel Degloor Deluxe',
          owner2,
          'Suresh Deshmukh',
          catFood,
          'Authentic Maharashtrian thalis and snacks.',
          'Bus Stand Road, Degloor',
          18.5510,
          77.5860,
          4.2,
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizHardware,
          'Om Hardware & Tools',
          owner3,
          'Anjali Kulkarni',
          catHardware,
          'Quality hardware, plumbing, and electrical supplies.',
          'Industrial Area, Degloor',
          18.5550,
          77.5800,
          4.8,
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizMedical,
          'City Medical',
          guestId,
          'Dr. Patil',
          catPharmacy,
          '24/7 pharmacy and health essentials.',
          'Near Civil Hospital, Degloor',
          18.5530,
          77.5830,
          4.9,
          'https://images.unsplash.com/photo-1576602976047-174e57a47881?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizElectronics,
          'Modern Electronics',
          owner4,
          'Vinod Gupta',
          catElectronics,
          'Mobiles, appliances, and accessories.',
          'Market Yard Road, Degloor',
          18.5540,
          77.5820,
          4.6,
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizClothing,
          'Style Point Clothing',
          owner5,
          'Meena Sharma',
          catClothing,
          'Trendy fashion for the whole family.',
          'Opposite Shivaji Statue, Degloor',
          18.5515,
          77.5855,
          4.4,
          'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizAuto,
          'Degloor Auto Care',
          owner6,
          'Rahul More',
          catAutomotive,
          'Servicing, tyres, and roadside help.',
          'Nanded-Bidar Highway, Degloor',
          18.5600,
          77.5750,
          4.7,
          'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?auto=format&fit=crop&w=800&q=80',
        ),
        _biz(
          bizPending,
          'New Corner Cafe',
          owner5,
          'Meena Sharma',
          catFood,
          'Pending verification — tea and snacks.',
          'College Road, Degloor',
          18.5498,
          77.5872,
          0,
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
          verified: false,
          open: false,
        ),
      ],
      'business_hours': [
        for (final biz in [
          bizPatil,
          bizHotel,
          bizHardware,
          bizMedical,
          bizElectronics,
          bizClothing,
          bizAuto,
        ])
          for (var day = 0; day <= 6; day++)
            {
              'id': 'hours-$biz-$day',
              'business_id': biz,
              'day_of_week': day,
              'open_time': '09:00:00',
              'close_time': biz == bizMedical ? '23:00:00' : '21:00:00',
              'is_closed': false,
              'created_at': _ago(const Duration(days: 40)),
            },
      ],
      'product_categories': [
        _pCat('pcat-dairy', bizPatil, 'Dairy'),
        _pCat('pcat-grains', bizPatil, 'Grains'),
        _pCat('pcat-veg', bizHotel, 'Vegetarian'),
        _pCat('pcat-tools', bizHardware, 'Tools'),
      ],
      'products': [
        _product(
          prodMilk,
          bizPatil,
          'pcat-dairy',
          'Fresh Milk (1L)',
          'Pure buffalo milk from nearby dairies.',
          60,
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=400&q=80',
        ),
        _product(
          prodRice,
          bizPatil,
          'pcat-grains',
          'Basmati Rice (1kg)',
          'Premium long-grain rice.',
          120,
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80',
        ),
        _product(
          prodThali,
          bizHotel,
          'pcat-veg',
          'Special Veg Thali',
          'Dal, two sabzi, roti, rice, and sweet.',
          150,
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
        ),
        _product(
          prodPaneer,
          bizHotel,
          'pcat-veg',
          'Paneer Butter Masala',
          'Creamy restaurant-style curry.',
          180,
          'https://images.unsplash.com/photo-1601050634129-416a24699182?auto=format&fit=crop&w=400&q=80',
        ),
        _product(
          'prod-hammer',
          bizHardware,
          'pcat-tools',
          'Steel Hammer',
          '16oz claw hammer.',
          249,
          'https://images.unsplash.com/photo-1586864387967-d02ef85d93e8?auto=format&fit=crop&w=400&q=80',
        ),
      ],
      'addresses': [
        {
          'id': 'addr-home',
          'user_id': guestId,
          'title': 'Home',
          'address_text': 'Lane 3, Near Bus Stand, Degloor, Maharashtra',
          'latitude': 18.5518,
          'longitude': 77.5850,
          'is_default': true,
          'created_at': _ago(const Duration(days: 40)),
        },
        {
          'id': 'addr-work',
          'user_id': guestId,
          'title': 'Work',
          'address_text': 'Market Yard Office, Degloor',
          'latitude': 18.5542,
          'longitude': 77.5824,
          'is_default': false,
          'created_at': _ago(const Duration(days: 40)),
        },
      ],
      'carts': [
        {
          'id': cartGuest,
          'user_id': guestId,
          'business_id': bizPatil,
          'created_at': _ago(const Duration(hours: 2)),
        },
      ],
      'cart_items': [
        {
          'id': 'ci-milk',
          'cart_id': cartGuest,
          'product_id': prodMilk,
          'quantity': 2,
          'created_at': _ago(const Duration(hours: 2)),
        },
        {
          'id': 'ci-rice',
          'cart_id': cartGuest,
          'product_id': prodRice,
          'quantity': 1,
          'created_at': _ago(const Duration(hours: 1)),
        },
      ],
      'orders': [
        {
          'id': 'order-pending',
          'user_id': customer2,
          'business_id': bizPatil,
          'total_amount': 120.0,
          'status': 'pending',
          'payment_status': 'pending',
          'delivery_address_id': 'addr-home',
          'delivery_fee': 25.0,
          'payment_method': 'COD',
          'delivery_otp': '2201',
          'created_at': _ago(const Duration(minutes: 50)),
        },
        {
          'id': orderReady,
          'user_id': customer2,
          'business_id': bizPatil,
          'total_amount': 145.0,
          'status': 'ready',
          'payment_status': 'pending',
          'delivery_address_id': 'addr-home',
          'delivery_fee': 25.0,
          'payment_method': 'COD',
          'delivery_otp': '3310',
          'created_at': _ago(const Duration(minutes: 20)),
        },
        {
          'id': orderOut,
          'user_id': guestId,
          'business_id': bizPatil,
          'total_amount': 265.0,
          'status': 'out_for_delivery',
          'payment_status': 'pending',
          'delivery_address_id': 'addr-home',
          'delivery_fee': 25.0,
          'payment_method': 'COD',
          'delivery_otp': '4821',
          'created_at': _ago(const Duration(hours: 3)),
        },
        {
          'id': orderDelivered,
          'user_id': guestId,
          'business_id': bizHotel,
          'total_amount': 175.0,
          'status': 'delivered',
          'payment_status': 'paid',
          'delivery_address_id': 'addr-home',
          'delivery_fee': 25.0,
          'payment_method': 'COD',
          'delivery_otp': '1190',
          'created_at': _ago(const Duration(days: 2)),
        },
      ],
      'order_items': [
        {
          'id': 'oi-0',
          'order_id': 'order-pending',
          'product_id': prodRice,
          'quantity': 1,
          'price_at_purchase': 120.0,
        },
        {
          'id': 'oi-ready',
          'order_id': orderReady,
          'product_id': prodRice,
          'quantity': 1,
          'price_at_purchase': 120.0,
        },
        {
          'id': 'oi-1',
          'order_id': orderOut,
          'product_id': prodMilk,
          'quantity': 2,
          'price_at_purchase': 60.0,
        },
        {
          'id': 'oi-2',
          'order_id': orderOut,
          'product_id': prodRice,
          'quantity': 1,
          'price_at_purchase': 120.0,
        },
        {
          'id': 'oi-3',
          'order_id': orderDelivered,
          'product_id': prodThali,
          'quantity': 1,
          'price_at_purchase': 150.0,
        },
      ],
      'order_status_history': [
        _hist(orderReady, 'placed', 'Order placed', const Duration(minutes: 20)),
        _hist(orderReady, 'accepted', 'Patil Kirana accepted',
            const Duration(minutes: 12)),
        _hist(orderReady, 'ready', 'Packed and waiting for a rider',
            const Duration(minutes: 5)),
        _hist(orderOut, 'placed', 'Order placed', const Duration(hours: 3)),
        _hist(orderOut, 'accepted', 'Patil Kirana accepted',
            const Duration(hours: 2, minutes: 40)),
        _hist(orderOut, 'out_for_delivery', 'Amit is on the way',
            const Duration(minutes: 40)),
        _hist(orderDelivered, 'placed', 'Order placed', const Duration(days: 2)),
        _hist(orderDelivered, 'delivered', 'Delivered to Home',
            const Duration(days: 2, hours: -1)),
      ],
      'reviews': [
        {
          'id': 'rev-1',
          'user_id': customer2,
          'business_id': bizPatil,
          'order_id': orderDelivered,
          'rating': 5,
          'comment': 'Fresh milk and quick packing. Best kirana in Degloor.',
          'created_at': _ago(const Duration(days: 5)),
        },
        {
          'id': 'rev-2',
          'user_id': owner2,
          'business_id': bizPatil,
          'rating': 4,
          'comment': 'Good stock. Rice quality is consistent.',
          'created_at': _ago(const Duration(days: 12)),
        },
        {
          'id': 'rev-3',
          'user_id': customer2,
          'business_id': bizHotel,
          'rating': 5,
          'comment': 'Thali tastes like home. Generous portions.',
          'created_at': _ago(const Duration(days: 3)),
        },
      ],
      'notifications': [
        {
          'id': 'nt-1',
          'user_id': guestId,
          'title': 'Order on the way',
          'message': 'Amit is delivering your Patil Kirana order. OTP 4821.',
          'type': 'order_update',
          'is_read': false,
          'created_at': _ago(const Duration(minutes: 25)),
        },
        {
          'id': 'nt-2',
          'user_id': guestId,
          'title': 'Welcome to DEGLOOR ONE',
          'message': 'Browse nearby shops, services, and jobs in Degloor.',
          'type': 'system',
          'is_read': true,
          'created_at': _ago(const Duration(days: 1)),
        },
      ],
      'complaints': [
        {
          'id': 'cmp-1',
          'user_id': guestId,
          'order_id': orderDelivered,
          'business_id': bizHotel,
          'subject': 'Missing sweet in thali',
          'description': 'Yesterday’s thali did not include the advertised sweet.',
          'status': 'pending',
          'created_at': _ago(const Duration(hours: 20)),
        },
      ],
      'service_categories': [
        _svcCat('scat-electric', 'Electrician', 'electrical_services'),
        _svcCat('scat-plumb', 'Plumber', 'plumbing'),
        _svcCat('scat-carp', 'Carpenter', 'construction'),
        _svcCat('scat-clean', 'Cleaner', 'cleaning_services'),
      ],
      'service_providers': [
        _provider(
          'sp-ravi',
          'user-electrician',
          'scat-electric',
          'House wiring, inverter, and fan repair across Degloor.',
          350,
          8,
        ),
        _provider(
          'sp-sunil',
          'user-plumber',
          'scat-plumb',
          'Leak repair, motor, and bathroom fitting.',
          300,
          6,
        ),
        _provider(
          'sp-kishor',
          'user-carpenter',
          'scat-carp',
          'Furniture, doors, and kitchen cabinets.',
          400,
          10,
        ),
        _provider(
          'sp-lata',
          'user-cleaner',
          'scat-clean',
          'Home and shop deep cleaning.',
          250,
          4,
        ),
      ],
      'service_requests': [
        {
          'id': 'sr-1',
          'user_id': guestId,
          'provider_id': 'sp-ravi',
          'description': 'Ceiling fan sparking in the front room.',
          'status': 'pending',
          'scheduled_at': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
          'created_at': _ago(const Duration(hours: 6)),
        },
      ],
      'jobs': [
        {
          'id': 'job-counter',
          'business_id': bizPatil,
          'poster_id': guestId,
          'title': 'Counter assistant',
          'description': 'Evening shift billing and packing at Patil Kirana.',
          'category': 'Retail',
          'job_type': 'Part-time',
          'salary_range': '₹8,000 – ₹10,000',
          'location_text': 'Main Road, Degloor',
          'is_active': true,
          'created_at': _ago(const Duration(days: 4)),
        },
        {
          'id': 'job-cook',
          'business_id': bizHotel,
          'poster_id': owner2,
          'title': 'Kitchen helper',
          'description': 'Prep and tandoor support for lunch and dinner.',
          'category': 'Hospitality',
          'job_type': 'Full-time',
          'salary_range': '₹12,000 – ₹15,000',
          'location_text': 'Bus Stand Road, Degloor',
          'is_active': true,
          'created_at': _ago(const Duration(days: 2)),
        },
        {
          'id': 'job-tech',
          'business_id': bizElectronics,
          'poster_id': owner4,
          'title': 'Mobile technician',
          'description': 'Screen and battery replacement. Tools provided.',
          'category': 'Electronics',
          'job_type': 'Full-time',
          'salary_range': '₹14,000 – ₹18,000',
          'location_text': 'Market Yard Road, Degloor',
          'is_active': true,
          'created_at': _ago(const Duration(days: 1)),
        },
      ],
      'job_applications': [
        {
          'id': 'ja-1',
          'job_id': 'job-counter',
          'applicant_id': customer2,
          'experience_summary': '1 year at a medical store counter.',
          'status': 'applied',
          'created_at': _ago(const Duration(days: 1)),
        },
      ],
      'delivery_partners': [
        {
          'id': 'dp-amit',
          'user_id': riderId,
          'vehicle_type': 'Bike',
          'vehicle_number': 'MH 26 AB 4321',
          'is_available': true,
          'is_verified': true,
          'current_latitude': 18.5520,
          'current_longitude': 77.5840,
          'created_at': _ago(const Duration(days: 40)),
        },
      ],
      'delivery_assignments': [
        {
          'id': 'da-1',
          'order_id': orderOut,
          'delivery_partner_id': 'dp-amit',
          'status': 'picked_up',
          'created_at': _ago(const Duration(minutes: 40)),
        },
      ],
      'business_analytics': [
        for (var i = 0; i < 18; i++)
          {
            'id': 'an-view-$i',
            'business_id': bizPatil,
            'user_id': guestId,
            'event_type': 'PROFILE_VIEW',
            'created_at': _ago(Duration(hours: 6 + i * 5)),
          },
        for (var i = 0; i < 5; i++)
          {
            'id': 'an-call-$i',
            'business_id': bizPatil,
            'user_id': guestId,
            'event_type': 'CALL_CLICK',
            'created_at': _ago(Duration(hours: 8 + i * 10)),
          },
        for (var i = 0; i < 7; i++)
          {
            'id': 'an-wa-$i',
            'business_id': bizPatil,
            'user_id': guestId,
            'event_type': 'WHATSAPP_CLICK',
            'created_at': _ago(Duration(hours: 4 + i * 8)),
          },
        for (var i = 0; i < 3; i++)
          {
            'id': 'an-dir-$i',
            'business_id': bizPatil,
            'user_id': guestId,
            'event_type': 'DIRECTIONS_CLICK',
            'created_at': _ago(Duration(hours: 12 + i * 15)),
          },
      ],
    };
  }

  static Map<String, dynamic> _user(
    String id,
    String email,
    String name,
    String role, {
    String? phone,
  }) {
    return {
      'id': id,
      'email': email,
      'full_name': name,
      'avatar_url': null,
      'role': role,
      'phone_number': phone ?? '+919876543210',
      'created_at': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _bizCat(
    String id,
    String name,
    String icon,
    int order,
  ) {
    return {
      'id': id,
      'name': name,
      'icon_name': icon,
      'display_order': order,
      'created_at': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _biz(
    String id,
    String name,
    String ownerId,
    String ownerName,
    String categoryId,
    String description,
    String address,
    double lat,
    double lng,
    double rating,
    String image, {
    bool verified = true,
    bool open = true,
  }) {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'owner_name': ownerName,
      'description': description,
      'category_id': categoryId,
      'city_id': 'city-degloor',
      'address_text': address,
      'whatsapp_number': '+919876543210',
      'phone_number': '+919876543210',
      'rating': rating,
      'is_open': open,
      'is_verified': verified,
      'image_url': image,
      'photos': [image],
      'source': 'owner',
      'latitude': lat,
      'longitude': lng,
      'discovery_radius': 12.0,
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _pCat(String id, String bizId, String name) {
    return {
      'id': id,
      'business_id': bizId,
      'name': name,
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _product(
    String id,
    String bizId,
    String catId,
    String name,
    String description,
    double price,
    String image,
  ) {
    return {
      'id': id,
      'business_id': bizId,
      'category_id': catId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': image,
      'is_available': true,
      'stock_quantity': 40,
      'track_inventory': true,
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _hist(
    String orderId,
    String status,
    String notes,
    Duration ago,
  ) {
    return {
      'id': 'hist-$orderId-$status',
      'order_id': orderId,
      'status': status,
      'notes': notes,
      'created_at': DateTime.now().subtract(ago).toIso8601String(),
    };
  }

  static Map<String, dynamic> _svcCat(String id, String name, String icon) {
    return {
      'id': id,
      'name': name,
      'icon_name': icon,
      'created_at': DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _provider(
    String id,
    String userId,
    String categoryId,
    String bio,
    double rate,
    int years,
  ) {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'bio': bio,
      'hourly_rate': rate,
      'experience_years': years,
      'is_verified': true,
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    };
  }
}


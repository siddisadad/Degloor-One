import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:degloor_one/backend/supabase/supabase.dart';

/// Initializes a mock Supabase instance for unit tests to avoid
/// "You must initialize the supabase instance" errors and SharedPreferences
/// MissingPluginException.
Future<void> initializeMockSupabase() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences to avoid MissingPluginException
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{};
    }
    return null;
  });

  try {
    await Supabase.initialize(
      url: 'https://mock.supabase.co',
      anonKey: 'mock',
      httpClient: MockClient((request) async {
        // Return empty list for searches, and a list with one mock row for others
        final isSelect = request.method == 'GET' ||
            (request.url.query.contains('select=') &&
                !request.url.query.contains('limit=1'));

        if (isSelect) {
          return http.Response('[]', 200);
        }

        final mockRow = {
          'id': 'mock-id',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'name': 'Mock Name',
          'full_name': 'Mock User',
          'email': 'mock@example.com',
          'role': 'customer',
          'user_id': 'mock-user-id',
          'category_id': 'mock-cat-id',
          'business_id': 'mock-biz-id',
          'order_id': 'mock-order-id',
          'product_id': 'mock-prod-id',
          'status': 'pending',
          'payment_status': 'unpaid',
          'is_verified': false,
          'is_open': true,
          'is_available': true,
          'is_active': true,
          'is_default': false,
          'quantity': 1,
          'total_amount': 0.0,
          'price_at_purchase': 0.0,
          'rating': 0,
          'day_of_week': 1,
          'title': 'Mock Title',
          'subject': 'Mock Subject',
          'description': 'Mock Description',
          'message': 'Mock Message',
          'bio': 'Mock Bio',
          'job_type': 'Full-time',
          'salary_range': '₹10,000',
        };

        return http.Response('[${jsonEncode(mockRow)}]', 200);
      }),
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  } catch (e) {
    // Already initialized in another test process or similar
    if (!e.toString().contains('already been initialized')) {
      rethrow;
    }
  }
}

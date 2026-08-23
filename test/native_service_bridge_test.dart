import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/backend/native_service_bridge.dart';
import 'package:degloor_one/shared/marketplace_joins.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.deshmukh.degloorone/services');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getProviders maps native rows to ServiceProviderCard', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getNativeProviders');
      expect((call.arguments as Map)['categoryId'], 'scat-electric');
      return [
        {
          'id': 'sp-native-1',
          'user_id': 'user-electrician',
          'category_id': 'scat-electric',
          'hourly_rate': 450.0,
          'is_verified': true,
          'users': {'full_name': 'Ravi Native'},
          'service_categories': {'name': 'Electrician'},
        },
      ];
    });

    final providers =
        await NativeServiceBridge.getProviders('scat-electric');
    expect(providers, everyElement(isA<ServiceProviderCard>()));
    expect(providers.single.id, 'sp-native-1');
    expect(providers.single.displayName, 'Ravi Native');
    expect(providers.single.categoryName, 'Electrician');
    expect(providers.single.isVerified, isTrue);
    expect(providers.single.hourlyRateLabel, '₹450/hr');
  });

  test('getProviders skips rows that are not maps', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      return [
        'bad-row',
        {
          'id': 'sp-ok',
          'users': {'full_name': 'Asha'},
        },
      ];
    });

    final providers = await NativeServiceBridge.getProviders(null);
    expect(providers, hasLength(1));
    expect(providers.single.id, 'sp-ok');
    expect(providers.single.displayName, 'Asha');
  });

  test('getProviders returns empty when the channel fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    expect(await NativeServiceBridge.getProviders(null), isEmpty);
  });
}

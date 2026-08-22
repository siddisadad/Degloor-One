import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/features/services/service_provider_display.dart';

void main() {
  test('asJoinMap accepts maps and rejects null or lists', () {
    expect(ServiceProviderDisplay.asJoinMap(null), isNull);
    expect(ServiceProviderDisplay.asJoinMap(['x']), isNull);
    expect(
      ServiceProviderDisplay.asJoinMap({'full_name': 'Asha'}),
      {'full_name': 'Asha'},
    );
  });

  test('name and category fall back when the join is missing', () {
    expect(ServiceProviderDisplay.name(null), 'Unknown Provider');
    expect(ServiceProviderDisplay.name({'full_name': '  Asha  '}), 'Asha');
    expect(ServiceProviderDisplay.categoryName(null), 'General');
    expect(ServiceProviderDisplay.categoryName({'name': 'Plumber'}), 'Plumber');
  });

  test('hourlyRateLabel formats numbers and missing rates', () {
    expect(ServiceProviderDisplay.hourlyRateLabel(150), '₹150/hr');
    expect(ServiceProviderDisplay.hourlyRateLabel(99.5), '₹99.50/hr');
    expect(ServiceProviderDisplay.hourlyRateLabel(null), 'Rate on request');
  });

  test('avatarUrl uses the fallback when the join has no photo', () {
    expect(
      ServiceProviderDisplay.avatarUrl(null),
      ServiceProviderDisplay.fallbackAvatarUrl,
    );
    expect(
      ServiceProviderDisplay.avatarUrl({'avatar_url': 'https://cdn.example/a.png'}),
      'https://cdn.example/a.png',
    );
  });
}

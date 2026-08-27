import 'package:degloor_one/data/datasources/java_address_repository.dart';
import 'package:degloor_one/shared/saved_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java address JSON maps to SavedAddress', () {
    final row = JavaAddressRepository.fromJson(
      {
        'id': 'addr-home',
        'userId': 'user-1',
        'title': 'Home',
        'addressText': 'Near bus stand, Degloor',
        'latitude': 18.55,
        'longitude': 77.58,
        'isDefault': true,
        'createdAt': '2026-08-24T10:00:00Z',
      },
      'ignored',
    );
    expect(row, isA<SavedAddress>());
    expect(row.id, 'addr-home');
    expect(row.userId, 'user-1');
    expect(row.title, 'Home');
    expect(row.isDefault, isTrue);
    expect(row.createdAt?.toUtc().year, 2026);
  });

  test('Java address JSON falls back to the caller user id', () {
    final row = JavaAddressRepository.fromJson(
      {
        'id': 'addr-work',
        'title': 'Work',
        'addressText': 'Degloor',
        'latitude': 18.55,
        'longitude': 77.58,
      },
      'user-2',
    );
    expect(row.userId, 'user-2');
    expect(row.isDefault, isFalse);
  });
}

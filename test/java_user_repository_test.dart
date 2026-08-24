import 'package:degloor_one/data/datasources/java_user_repository.dart';
import 'package:degloor_one/shared/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Java profile JSON maps to UserProfile', () {
    final row = JavaUserRepository.fromJson({
      'id': 'user-1',
      'email': 'asha@degloor.local',
      'phoneNumber': '+919890000021',
      'fullName': 'Asha Patil',
      'avatarUrl': 'https://example.com/a.png',
      'role': 'customer',
      'createdAt': '2026-08-24T10:00:00Z',
    });
    expect(row, isA<UserProfile>());
    expect(row.id, 'user-1');
    expect(row.email, 'asha@degloor.local');
    expect(row.phoneNumber, '+919890000021');
    expect(row.fullName, 'Asha Patil');
    expect(row.avatarUrl, 'https://example.com/a.png');
    expect(row.role, 'customer');
    expect(row.createdAt?.toUtc().year, 2026);
  });

  test('Java profile JSON leaves createdAt null when omitted', () {
    final row = JavaUserRepository.fromJson({
      'id': 'user-2',
      'email': 'guest@local',
      'role': 'admin',
    });
    expect(row.id, 'user-2');
    expect(row.role, 'admin');
    expect(row.fullName, isNull);
    expect(row.createdAt, isNull);
  });
}

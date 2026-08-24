import 'package:flutter_test/flutter_test.dart';
import 'package:degloor_one/shared/user_profile_draft.dart';

void main() {
  test('sign-in drafts only serialize insert fields', () {
    final draft = UserProfileDraft.fromSignIn(
      email: 'asha@degloor.local',
      phone: '+919890000021',
      fullName: 'Asha Patil',
      avatarUrl: 'https://img',
    );
    expect(draft.toInsertJson(userId: 'user-1'), {
      'id': 'user-1',
      'email': 'asha@degloor.local',
      'phone_number': '+919890000021',
      'full_name': 'Asha Patil',
      'avatar_url': 'https://img',
      'role': UserProfileDraft.customer,
    });
    expect(
      draft.toInsertJson(userId: 'user-1').keys,
      ['id', 'email', 'phone_number', 'full_name', 'avatar_url', 'role'],
    );
    expect(
      draft.toInsertJson(userId: 'user-1').containsKey('created_at'),
      isFalse,
    );
  });

  test('profile update stays off id, role, and email', () {
    final draft = UserProfileDraft.fromProfile(
      fullName: '  Sadad Guest  ',
      phoneNumber: '+919890009999',
    );
    expect(draft.toUpdateJson(), {
      'full_name': 'Sadad Guest',
      'phone_number': '+919890009999',
    });
    expect(draft.toUpdateJson().containsKey('id'), isFalse);
    expect(draft.toUpdateJson().containsKey('role'), isFalse);
    expect(draft.toUpdateJson().containsKey('email'), isFalse);
    expect(draft.toUpdateJson().containsKey('created_at'), isFalse);
  });

  test('fromProfile rejects a missing name and phone', () {
    expect(
      () => UserProfileDraft.fromProfile(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('name or phone'),
        ),
      ),
    );
  });
}

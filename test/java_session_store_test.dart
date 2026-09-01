import 'package:degloor_one/auth/java_auth/java_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('JavaSessionStore round-trips tokens', () async {
    await JavaSessionStore.save(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    final loaded = await JavaSessionStore.load();
    expect(loaded, isNotNull);
    expect(loaded!.accessToken, 'access-token');
    expect(loaded.refreshToken, 'refresh-token');
  });

  test('JavaSessionStore clear removes persisted tokens', () async {
    await JavaSessionStore.save(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    await JavaSessionStore.clear();

    expect(await JavaSessionStore.load(), isNull);
  });

  test('JavaSessionStore save clears when tokens are empty', () async {
    await JavaSessionStore.save(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    await JavaSessionStore.save(accessToken: '', refreshToken: '');

    expect(await JavaSessionStore.load(), isNull);
  });
}

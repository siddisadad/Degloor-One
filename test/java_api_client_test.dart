import 'package:degloor_one/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('JavaApiClient probeHealth accepts UP status', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/actuator/health');
      return http.Response('{"status":"UP"}', 200);
    });

    await JavaApiClient.instance.probeHealth(client: client);
  });

  test('JavaApiClient probeHealth rejects non-UP status', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":"DOWN"}', 200);
    });

    expect(
      () => JavaApiClient.instance.probeHealth(client: client),
      throwsA(isA<JavaApiException>()),
    );
  });
}

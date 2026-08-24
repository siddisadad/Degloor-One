import 'package:degloor_one/backend/whatsapp_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat links use a 10-digit Indian number on wa.me', () {
    final url = WhatsAppService.chatUri(
      phoneNumber: '9876543210',
      message: 'Hello Patil Kirana',
    );
    expect(url, isNotNull);
    expect(url!.host, 'wa.me');
    expect(url.path, '/919876543210');
    expect(url.queryParameters['text'], 'Hello Patil Kirana');
  });

  test('chat links keep an existing country code and reject junk', () {
    expect(
      WhatsAppService.chatUri(phoneNumber: '+91 98765 43210')!.path,
      '/919876543210',
    );
    expect(WhatsAppService.chatUri(phoneNumber: '123'), isNull);
    expect(WhatsAppService.chatUri(phoneNumber: ''), isNull);
  });
}

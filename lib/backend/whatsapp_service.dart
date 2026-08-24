import 'package:degloor_one/auth/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static const unableToOpenMessage =
      'Unable to open WhatsApp. Please try again.';

  static Uri? chatUri({
    required String phoneNumber,
    String? message,
  }) {
    final normalized = PhoneNumber.normalize(phoneNumber);
    if (normalized == null) return null;
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    return Uri.parse(
      'https://wa.me/$digits?text=${Uri.encodeComponent(message ?? 'Hello!')}',
    );
  }

  static Future<bool> launchWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    final url = chatUri(phoneNumber: phoneNumber, message: message);
    if (url == null) return false;
    try {
      if (!await canLaunchUrl(url)) return false;
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

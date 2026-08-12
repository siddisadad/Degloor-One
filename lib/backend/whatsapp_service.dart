import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> launchWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    // Sanitize phone number (remove non-digits)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Add 91 if it's a 10-digit Indian number and doesn't have a country code
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }

    final url = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message ?? "Hello!")}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp for $cleanNumber';
    }
  }
}

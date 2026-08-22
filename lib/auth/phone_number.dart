/// Normalize and validate Indian / E.164 phone numbers for OTP.
class PhoneNumber {
  static String? normalize(String raw) {
    var phone = raw.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) return null;
    if (!phone.startsWith('+')) {
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        phone = '+$phone';
      }
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) return null;
    return phone;
  }
}

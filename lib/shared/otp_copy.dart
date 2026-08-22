/// Shared copy so login SMS OTP and delivery OTP are never confused.
class OtpCopy {
  static const smsDigits = 6;
  static const deliveryDigits = 4;

  static const smsHint =
      'This is the 6-digit SMS login code. Delivery uses a separate 4-digit OTP on Track Order.';

  static const deliveryHint =
      'Share this 4-digit delivery OTP with the rider only when the order arrives. It is not the 6-digit SMS login code.';

  static const checkoutHint =
      'Pay cash on delivery. The rider will ask for the 4-digit delivery OTP from Track Order — not your SMS login code.';

  static const phoneSubtitle =
      'Enter your 10-digit mobile. We will send a 6-digit SMS login code, not the 4-digit delivery OTP.';

  static String smsSentTo(String phone) =>
      'Enter the 6-digit SMS login code sent to $phone. Delivery partners use a separate 4-digit OTP.';
}

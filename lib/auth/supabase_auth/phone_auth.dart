import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/core/error_handler.dart';

Future phoneSignInFunc(String phoneNumber) async {
  try {
    await SupaFlow.client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  } catch (e) {
    AppLogger.log('Supabase OTP Error for $phoneNumber', error: e);
    rethrow;
  }
}

Future<User?> phoneVerifyCodeFunc({
  required String phoneNumber,
  required String smsCode,
}) async {
  try {
    final AuthResponse res = await SupaFlow.client.auth.verifyOTP(
      phone: phoneNumber,
      token: smsCode,
      type: OtpType.sms,
    );
    return res.user;
  } catch (e) {
    AppLogger.log('Supabase OTP Verification Error for $phoneNumber', error: e);
    rethrow;
  }
}

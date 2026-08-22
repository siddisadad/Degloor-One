import 'package:degloor_one/backend/supabase/supabase.dart';
import 'package:degloor_one/backend/supabase/supabase_connection.dart';

Future phoneSignInFunc(String phoneNumber) async {
  if (SupabaseConnection.shouldSkipAuthRequest) return;
  try {
    await SupaFlow.client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  } catch (e) {
    SupabaseConnection.log(e, context: 'Phone OTP send');
    rethrow;
  }
}

Future<User?> phoneVerifyCodeFunc({
  required String phoneNumber,
  required String smsCode,
}) async {
  if (SupabaseConnection.shouldSkipAuthRequest) return null;
  try {
    final AuthResponse res = await SupaFlow.client.auth.verifyOTP(
      phone: phoneNumber,
      token: smsCode,
      type: OtpType.sms,
    );
    return res.user;
  } catch (e) {
    SupabaseConnection.log(e, context: 'Phone OTP verify');
    rethrow;
  }
}

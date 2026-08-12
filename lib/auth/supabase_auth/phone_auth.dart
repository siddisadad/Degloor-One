import 'package:degloor_one/backend/supabase/supabase.dart';

Future phoneSignInFunc(String phoneNumber) async {
  await SupaFlow.client.auth.signInWithOtp(
    phone: phoneNumber,
  );
}

Future<User?> phoneVerifyCodeFunc({
  required String phoneNumber,
  required String smsCode,
}) async {
  final AuthResponse res = await SupaFlow.client.auth.verifyOTP(
    phone: phoneNumber,
    token: smsCode,
    type: OtpType.sms,
  );
  return res.user;
}

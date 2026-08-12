import 'package:degloor_one/backend/supabase/supabase.dart';

Future<User?> emailSignInFunc(
  String email,
  String password,
) async {
  final AuthResponse res = await SupaFlow.client.auth
      .signInWithPassword(email: email, password: password);
  return res.user;
}

Future<User?> emailCreateAccountFunc(
  String email,
  String password,
) async {
  final AuthResponse res =
      await SupaFlow.client.auth.signUp(email: email, password: password);

  // Return the user if the sign up was successful.
  return res.user;
}

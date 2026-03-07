import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String phone, String password) async {
    // Note: Supabase standard auth uses email.
    // If you use phone + password, you might need to format it as email for backend
    // Or use Supabase custom phone auth if configured.
    final email = '$phone@safeseat.com';

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}

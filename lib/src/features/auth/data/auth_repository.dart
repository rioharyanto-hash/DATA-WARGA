import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawis/core/database/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient = SupabaseClientHelper.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;
}

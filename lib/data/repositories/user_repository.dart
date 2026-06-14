import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Préfixe
import '../local/preferences.dart';
import '../remote/supabase_provider.dart';
import '../models/user.dart'; // Ton modèle local

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(supabaseProvider),
    ref.watch(preferencesProvider),
  );
});

class UserRepository {
  final supabase.SupabaseClient _supabase;
  final Preferences _prefs;

  UserRepository(this._supabase, this._prefs);

  // Traduction : Supabase User -> Ton modèle User local
  User? _mapSupabaseUserToLocale(supabase.User? supabaseUser) {
    if (supabaseUser == null) return null;
    return User()
      ..id = supabaseUser.id
      ..email = supabaseUser.email ?? ''
      ..username = supabaseUser.userMetadata?['full_name'] ?? supabaseUser.email?.split('@').first ?? 'Invité'
      ..createdAt = DateTime.parse(supabaseUser.createdAt)
      ..passwordHash = '';
  }

  // ─── AUTHENTIFICATION ──────────────────────────────────

  Future<User?> register({required String email, required String password, String? username}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: { 'full_name': username }, // Sauvegarde le nom d'utilisateur dans les métadonnées Supabase
    );
    return _mapSupabaseUserToLocale(response.user);
  }

  Future<User?> login({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _mapSupabaseUserToLocale(response.user);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _prefs.clearCurrentUser();
  }

  Future<User?> getCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    return _mapSupabaseUserToLocale(supabaseUser);
  }
}
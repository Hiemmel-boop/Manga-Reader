import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/preferences.dart';
import '../models/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(preferencesProvider));
});

class UserRepository {
  final Preferences _prefs;

  UserRepository(this._prefs);

  // Placeholder vide pour la démo
  Future<User?> getCurrentUser() async => null;
  Future<User?> register({required String username, required String email, required String password}) async => null;
  Future<User?> login({required String username, required String password}) async => null;
  Future<void> logout() async {}
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../local/database.dart';
import '../local/preferences.dart';
import '../models/user.dart';
import '../../core/logger.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.watch(isarProvider),
    ref.watch(preferencesProvider),
  );
});

class UserRepository {
  final Isar _isar;
  final Preferences _prefs;

  UserRepository(this._isar, this._prefs);

  Future<User?> getUserByUsername(String username) async {
    return _isar.users.filter().usernameEqualTo(username).findFirst();
  }

  Future<User?> getUserByEmail(String email) async {
    return _isar.users.filter().emailEqualTo(email).findFirst();
  }

  Future<User?> getCurrentUser() async {
    final userId = await _prefs.getCurrentUserId();
    if (userId == null) return null;
    return _isar.users.get(userId);
  }

  Future<User> saveUser(User user) async {
    await _isar.writeTxn(() => _isar.users.put(user));
    await _prefs.setCurrentUserId(user.id);
    return user;
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final existingUsername = await getUserByUsername(username);
    if (existingUsername != null) {
      throw Exception('Ce nom d\'utilisateur est déjà pris');
    }

    final existingEmail = await getUserByEmail(email);
    if (existingEmail != null) {
      throw Exception('Cet email est déjà utilisé');
    }

    final user = User()
      ..username = username
      ..email = email
      ..passwordHash = User.hashPassword(password)
      ..createdAt = DateTime.now()
      ..defaultLanguage = 'fr';

    return saveUser(user);
  }

  Future<User?> login({
    required String username,
    required String password,
  }) async {
    final user = await getUserByUsername(username);
    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    if (!User.verifyPassword(password, user.passwordHash)) {
      throw Exception('Mot de passe incorrect');
    }

    await _prefs.setCurrentUserId(user.id);
    return user;
  }

  Future<void> logout() async {
    await _prefs.clearCurrentUser();
  }

  Future<void> updatePreferences({
    String? theme,
    String? language,
    bool? notifications,
    int? readerDirection,
    String? readerTheme,
  }) async {
    final user = await getCurrentUser();
    if (user == null) return;

    await _isar.writeTxn(() async {
      if (theme != null) user.theme = theme;
      if (language != null) user.defaultLanguage = language;
      if (notifications != null) user.notificationsEnabled = notifications;
      if (readerDirection != null) user.defaultReaderDirection = readerDirection;
      if (readerTheme != null) user.readerTheme = readerTheme;
      await _isar.users.put(user);
    });
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';  // ← AJOUTE CETTE LIGNE
import '../datasources/local/database.dart';
import '../models/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(isarProvider.future));
});

class UserRepository {
  final Future<Isar> _dbFuture;

  UserRepository(this._dbFuture);

  Future<User?> getUserByUsername(String username) async {
    final db = await _dbFuture;
    return db.users.filter().usernameEqualTo(username).findFirst();
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _dbFuture;
    return db.users.filter().emailEqualTo(email).findFirst();
  }

  Future<User?> getCurrentUser() async {
    final db = await _dbFuture;
    return db.users.where().findFirst();
  }

  Future<void> saveUser(User user) async {
    final db = await _dbFuture;
    await db.writeTxn(() => db.users.put(user));
  }

  Future<void> updatePreferences({
    String? theme,
    String? language,
    bool? notifications,
    int? readerDirection,
  }) async {
    final db = await _dbFuture;
    final user = await db.users.where().findFirst();

    if (user != null) {
      if (theme != null) user.theme = theme;
      if (language != null) user.defaultLanguage = language;
      if (notifications != null) user.notificationsEnabled = notifications;
      if (readerDirection != null) user.defaultReaderDirection = readerDirection;

      await db.writeTxn(() => db.users.put(user));
    }
  }

  Future<void> clearUser() async {
    final db = await _dbFuture;
    await db.writeTxn(() => db.users.clear());
  }
}
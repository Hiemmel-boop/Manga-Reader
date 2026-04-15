import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String username;

  @Index(unique: true)
  late String email;

  late String passwordHash;
  late DateTime createdAt;

  String? theme;
  String? defaultLanguage;
  bool notificationsEnabled = true;
  int defaultReaderDirection = 0; // 0 = horizontal, 1 = vertical
  String readerTheme = 'dark';

  User();

  // Hash sécurisé avec SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash) {
    return hashPassword(password) == storedHash;
  }
}
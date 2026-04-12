import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
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
  int defaultReaderDirection = 0;

  User({
    this.id = Isar.autoIncrement,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.theme,
    this.defaultLanguage,
    this.notificationsEnabled = true,
    this.defaultReaderDirection = 0,
  });
}
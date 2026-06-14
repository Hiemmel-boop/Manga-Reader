import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider temporaire vide en attendant d'implémenter Sqflite
// On le met en dynamic pour que les repositories ne crashent pas à l'initialisation
final databaseProvider = Provider<dynamic>((ref) {
  return null;
});
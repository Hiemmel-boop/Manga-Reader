import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/user.dart';
import '../models/reading_progress.dart';
import '../models/reading_history.dart';
import '../../config/constants.dart';

// Provider synchrone — initialisé une fois dans main.dart via override
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider doit être initialisé dans main.dart');
});

// Fonction d'initialisation appelée dans main.dart
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();

  if (Isar.instanceNames.contains(AppConstants.dbName)) {
    return Isar.getInstance(AppConstants.dbName)!;
  }

  return await Isar.open(
    [
      MangaSchema,
      ChapterSchema,
      UserSchema,
      ReadingProgressSchema,
      ReadingHistorySchema,
    ],
    directory: dir.path,
    name: AppConstants.dbName,
  );
}
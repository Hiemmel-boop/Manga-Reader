import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/database.dart';
import '../data/models/manga.dart';
import '../data/models/chapter.dart';
import '../data/models/user.dart';
import '../data/models/reading_progress.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncLibrary() async {
    // TODO: Synchroniser avec MangaDex API si utilisateur connecté
  }

  Future<void> syncReadingProgress() async {
    // TODO: Synchroniser progression de lecture
  }

  Future<void> backupLocalData() async {
    // TODO: Export JSON des données pour backup manuel
  }

  Future<void> restoreFromBackup(String backupData) async {
    // TODO: Import JSON de backup
  }

  Future<void> clearAllData() async {
    final db = await ref.read(isarProvider.future);
    await db.writeTxn(() async {
      await db.collection<Manga>().clear();
      await db.collection<Chapter>().clear();
      await db.collection<ReadingProgress>().clear();
      await db.collection<User>().clear();
    });
  }
}
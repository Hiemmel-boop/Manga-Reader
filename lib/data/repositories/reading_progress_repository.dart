import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../datasources/local/database.dart';
import '../models/reading_progress.dart';

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return ReadingProgressRepository(ref.watch(isarProvider.future));
});

class ReadingProgressRepository {
  final Future<Isar> _dbFuture;

  ReadingProgressRepository(this._dbFuture);

  Future<void> saveProgress(ReadingProgress progress) async {
    final db = await _dbFuture;

    // Le nom est "readingProgress" (pas "readingProgresss")
    final existing = await db.readingProgress
        .filter()
        .mangaIdEqualTo(progress.mangaId)
        .findFirst();

    if (existing != null) {
      progress.id = existing.id;
    }

    await db.writeTxn(() => db.readingProgress.put(progress));
  }

  Future<ReadingProgress?> getProgress(String mangaId) async {
    final db = await _dbFuture;
    return db.readingProgress
        .filter()
        .mangaIdEqualTo(mangaId)
        .findFirst();
  }

  Future<List<ReadingProgress>> getRecentProgress({int limit = 10}) async {
    final db = await _dbFuture;
    return db.readingProgress
        .where()
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> deleteProgress(String mangaId) async {
    final db = await _dbFuture;
    final existing = await db.readingProgress
        .filter()
        .mangaIdEqualTo(mangaId)
        .findFirst();

    if (existing != null) {
      await db.writeTxn(() => db.readingProgress.delete(existing.id));
    }
  }
}
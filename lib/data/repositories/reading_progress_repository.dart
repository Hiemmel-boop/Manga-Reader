import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../local/database.dart';
import '../models/reading_progress.dart';
import '../models/reading_history.dart';
import '../../core/logger.dart';

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return ReadingProgressRepository(ref.watch(isarProvider));
});

class ReadingProgressRepository {
  final Isar _isar;

  ReadingProgressRepository(this._isar);

  // ─── PROGRESSION ──────────────────────────────────────

  Future<void> saveProgress({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    required int lastPage,
    required int totalPages,
  }) async {
    try {
      final progress = ReadingProgress.create(
        mangaId: mangaId,
        chapterId: chapterId,
        mangaTitle: mangaTitle,
        mangaCoverUrl: mangaCoverUrl,
        chapterTitle: chapterTitle,
        chapterNumber: chapterNumber,
        lastPage: lastPage,
        totalPages: totalPages,
      );

      final existing = await _isar.readingProgress
          .filter()
          .mangaIdEqualTo(mangaId)
          .findFirst();

      await _isar.writeTxn(() async {
        if (existing != null) progress.id = existing.id;
        await _isar.readingProgress.put(progress);
      });
    } catch (e) {
      appLogger.e('saveProgress', error: e);
    }
  }

  Future<ReadingProgress?> getProgress(String mangaId) async {
    return _isar.readingProgress
        .filter()
        .mangaIdEqualTo(mangaId)
        .findFirst();
  }

  // Récupère les N dernières progressions (pour "Continuer la lecture")
  Future<List<ReadingProgress>> getRecentProgress({int limit = 6}) async {
    return _isar.readingProgress
        .where()
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> deleteProgress(String mangaId) async {
    final existing = await _isar.readingProgress
        .filter()
        .mangaIdEqualTo(mangaId)
        .findFirst();

    if (existing != null) {
      await _isar.writeTxn(() => _isar.readingProgress.delete(existing.id));
    }
  }

  // ─── HISTORIQUE ────────────────────────────────────────

  Future<void> addToHistory({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    int? lastPage,
    bool isCompleted = false,
  }) async {
    try {
      final history = ReadingHistory.create(
        mangaId: mangaId,
        chapterId: chapterId,
        mangaTitle: mangaTitle,
        mangaCoverUrl: mangaCoverUrl,
        chapterTitle: chapterTitle,
        chapterNumber: chapterNumber,
        lastPage: lastPage,
        isCompleted: isCompleted,
      );

      await _isar.writeTxn(() => _isar.readingHistorys.put(history));
    } catch (e) {
      appLogger.e('addToHistory', error: e);
    }
  }

  Future<List<ReadingHistory>> getHistory({int limit = 50}) async {
    return _isar.readingHistorys
        .where()
        .sortByReadAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> clearHistory() async {
    await _isar.writeTxn(() => _isar.readingHistorys.clear());
  }
}
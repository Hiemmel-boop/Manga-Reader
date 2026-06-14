import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import '../models/reading_progress.dart';
import '../models/reading_history.dart';

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return ReadingProgressRepository(DatabaseHelper());
});

class ReadingProgressRepository {
  final DatabaseHelper _db;

  ReadingProgressRepository(this._db);

  // Placeholder pour la progression (on se concentre sur l'historique d'abord)
  Future<void> saveProgress({required String mangaId, required String chapterId, required String mangaTitle, String? mangaCoverUrl, String? chapterTitle, String? chapterNumber, required int lastPage, required int totalPages}) async {}
  Future<ReadingProgress?> getProgress(String mangaId) async => null;
  Future<List<ReadingProgress>> getRecentProgress({int limit = 6}) async => [];
  Future<void> deleteProgress(String mangaId) async {}

  // ─── HISTORIQUE (Sqflite) ──────────────────────────────

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
    await _db.insertHistory(history);
  }

  Future<List<ReadingHistory>> getHistory({int limit = 50}) async {
    return await _db.getRecentHistory(limit: limit);
  }

  Future<void> clearHistory() async {
    await _db.clearHistory();
  }
}
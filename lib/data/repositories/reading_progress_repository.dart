import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_progress.dart';
import '../models/reading_history.dart';

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return ReadingProgressRepository();
});

class ReadingProgressRepository {
  // Placeholder vide - Toute la logique Isar retirée
  Future<void> saveProgress({required String mangaId, required String chapterId, required String mangaTitle, String? mangaCoverUrl, String? chapterTitle, String? chapterNumber, required int lastPage, required int totalPages}) async {}
  Future<ReadingProgress?> getProgress(String mangaId) async => null;
  Future<List<ReadingProgress>> getRecentProgress({int limit = 6}) async => [];
  Future<void> deleteProgress(String mangaId) async {}
  Future<void> addToHistory({required String mangaId, required String chapterId, required String mangaTitle, String? mangaCoverUrl, String? chapterTitle, String? chapterNumber, int? lastPage, bool isCompleted = false}) async {}
  Future<List<ReadingHistory>> getHistory({int limit = 50}) async => [];
  Future<void> clearHistory() async {}
}
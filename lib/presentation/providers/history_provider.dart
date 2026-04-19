import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reading_history.dart';
import '../../data/models/reading_progress.dart';
import '../../data/repositories/reading_progress_repository.dart';

// Progressions récentes pour la section "Continuer la lecture"
final recentProgressProvider = FutureProvider<List<ReadingProgress>>((ref) async {
  return ref.watch(readingProgressRepositoryProvider).getRecentProgress(limit: 6);
});

// Progression d'un manga spécifique
final readingProgressProvider = FutureProvider.family<ReadingProgress?, String>((ref, mangaId) async {
  return ref.watch(readingProgressRepositoryProvider).getProgress(mangaId);
});

// Historique persisté dans Isar
final historyProvider = StateNotifierProvider<HistoryNotifier, List<ReadingHistory>>((ref) {
  return HistoryNotifier(ref.watch(readingProgressRepositoryProvider));
});

class HistoryNotifier extends StateNotifier<List<ReadingHistory>> {
  final ReadingProgressRepository _repo;

  HistoryNotifier(this._repo) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _repo.getHistory();
  }

  Future<void> add({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    int? lastPage,
  }) async {
    await _repo.addToHistory(
      mangaId: mangaId,
      chapterId: chapterId,
      mangaTitle: mangaTitle,
      mangaCoverUrl: mangaCoverUrl,
      chapterTitle: chapterTitle,
      chapterNumber: chapterNumber,
      lastPage: lastPage,
    );
    await load();
  }

  Future<void> clear() async {
    await _repo.clearHistory();
    state = [];
  }
}
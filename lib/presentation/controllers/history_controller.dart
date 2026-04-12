import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modèle simple sans Isar
class ReadingHistory {
  final String id;
  final String mangaId;
  final String chapterId;
  final String mangaTitle;
  final String? mangaCoverUrl;
  final String? chapterTitle;
  final int? lastPage;
  final DateTime readAt;
  final bool isCompleted;

  ReadingHistory({
    required this.id,
    required this.mangaId,
    required this.chapterId,
    required this.mangaTitle,
    this.mangaCoverUrl,
    this.chapterTitle,
    this.lastPage,
    required this.readAt,
    this.isCompleted = false,
  });
}

final historyControllerProvider = StateNotifierProvider<HistoryController, List<ReadingHistory>>((ref) {
  return HistoryController();
});

final recentHistoryProvider = Provider<List<ReadingHistory>>((ref) {
  return ref.watch(historyControllerProvider);
});

class HistoryController extends StateNotifier<List<ReadingHistory>> {
  HistoryController() : super([]);

  Future<void> addToHistory({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    int? lastPage,
    bool isCompleted = false,
  }) async {
    final history = ReadingHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mangaId: mangaId,
      chapterId: chapterId,
      mangaTitle: mangaTitle,
      mangaCoverUrl: mangaCoverUrl,
      chapterTitle: chapterTitle,
      lastPage: lastPage,
      readAt: DateTime.now(),
      isCompleted: isCompleted,
    );

    state = [history, ...state];
  }

  Future<void> clearHistory() async {
    state = [];
  }
}
// Pas besoin de Isar pour l'instant - stockage en mémoire
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
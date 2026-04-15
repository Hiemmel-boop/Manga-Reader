import 'package:isar/isar.dart';

part 'reading_progress.g.dart';

@collection
class ReadingProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String mangaId;

  late String chapterId;
  late String mangaTitle;
  String? mangaCoverUrl;
  String? chapterTitle;
  String? chapterNumber;
  late int lastPage;
  late int totalPages;
  late DateTime updatedAt;

  ReadingProgress();

  factory ReadingProgress.create({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    required int lastPage,
    required int totalPages,
  }) {
    return ReadingProgress()
      ..mangaId = mangaId
      ..chapterId = chapterId
      ..mangaTitle = mangaTitle
      ..mangaCoverUrl = mangaCoverUrl
      ..chapterTitle = chapterTitle
      ..chapterNumber = chapterNumber
      ..lastPage = lastPage
      ..totalPages = totalPages
      ..updatedAt = DateTime.now();
  }

  double get progressPercentage =>
      totalPages > 0 ? (lastPage / totalPages).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => lastPage >= totalPages && totalPages > 0;
}
import 'package:isar/isar.dart';

part 'reading_progress.g.dart';

@Collection()
class ReadingProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String mangaId;

  late String chapterId;
  late String mangaTitle;
  String? mangaCoverUrl;
  String? chapterTitle;
  late int lastPage;
  late int totalPages;
  late DateTime updatedAt;

  ReadingProgress({
    this.id = Isar.autoIncrement,
    required this.mangaId,
    required this.chapterId,
    required this.mangaTitle,
    this.mangaCoverUrl,
    this.chapterTitle,
    required this.lastPage,
    required this.totalPages,
    required this.updatedAt,
  });
}
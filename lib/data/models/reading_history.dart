import 'package:isar/isar.dart';

part 'reading_history.g.dart';

@collection
class ReadingHistory {
  Id id = Isar.autoIncrement;

  @Index()
  late String mangaId;

  late String chapterId;
  late String mangaTitle;
  String? mangaCoverUrl;
  String? chapterTitle;
  String? chapterNumber;
  int? lastPage;
  late DateTime readAt;
  bool isCompleted = false;

  ReadingHistory();

  factory ReadingHistory.create({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? mangaCoverUrl,
    String? chapterTitle,
    String? chapterNumber,
    int? lastPage,
    bool isCompleted = false,
  }) {
    return ReadingHistory()
      ..mangaId = mangaId
      ..chapterId = chapterId
      ..mangaTitle = mangaTitle
      ..mangaCoverUrl = mangaCoverUrl
      ..chapterTitle = chapterTitle
      ..chapterNumber = chapterNumber
      ..lastPage = lastPage
      ..readAt = DateTime.now()
      ..isCompleted = isCompleted;
  }
}
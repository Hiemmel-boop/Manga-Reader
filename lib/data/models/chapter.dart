import 'package:isar/isar.dart';

part 'chapter.g.dart';

@collection
class Chapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String mangadexId;

  @Index()
  late String mangaId;

  late String? title;
  late String? chapterNumber;
  late String? volumeNumber;
  late String? translatedLanguage;
  late int? pagesCount;
  late List<String> pageUrls;
  late DateTime? publishAt;
  late DateTime? readableAt;

  // Progression de lecture
  bool isRead = false;
  int? lastPageRead;
  DateTime? readAt;

  // Uploader info
  late String? uploaderId;
  late String? scanlationGroup;
}
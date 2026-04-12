class ChapterEntity {
  final String id;
  final String mangaId;
  final String? title;
  final String? chapterNumber;
  final String? volumeNumber;
  final String? translatedLanguage;
  final int? pagesCount;
  final List<String> pageUrls;
  final DateTime? publishAt;
  final bool isRead;
  final int? lastPageRead;
  final DateTime? readAt;

  ChapterEntity({
    required this.id,
    required this.mangaId,
    this.title,
    this.chapterNumber,
    this.volumeNumber,
    this.translatedLanguage,
    this.pagesCount,
    this.pageUrls = const [],
    this.publishAt,
    this.isRead = false,
    this.lastPageRead,
    this.readAt,
  });
}
class MangaEntity {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? author;
  final String? artist;
  final String? status;
  final String? contentRating;
  final List<String> tags;
  final int? year;
  final DateTime? lastChapterDate;
  final bool isInLibrary;
  final DateTime? addedToLibraryAt;

  MangaEntity({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.author,
    this.artist,
    this.status,
    this.contentRating,
    this.tags = const [],
    this.year,
    this.lastChapterDate,
    this.isInLibrary = false,
    this.addedToLibraryAt,
  });
}
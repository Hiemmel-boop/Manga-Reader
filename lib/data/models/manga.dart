import 'package:isar/isar.dart';

part 'manga.g.dart';

@collection
class Manga {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String mangadexId;

  late String title;
  late String? description;
  late String? coverUrl;
  late String? author;
  late String? artist;
  late String? status;
  late String? contentRating;
  late List<String> tags;
  late int? year;
  late DateTime? lastChapterDate;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Bibliothèque utilisateur
  bool isInLibrary = false;
  DateTime? addedToLibraryAt;

  // Statistiques de lecture
  int unreadChaptersCount = 0;
  bool hasUnreadChapters = false;
}
import 'package:isar/isar.dart';

part 'chapter.g.dart';

@collection
class Chapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String mangadexId;

  @Index()
  late String mangaId;

  String? title;
  String? chapterNumber;
  String? volumeNumber;
  String? translatedLanguage;
  int? pagesCount;
  List<String> pageUrls = [];
  DateTime? publishAt;
  DateTime? readableAt;

  // Progression
  bool isRead = false;
  int? lastPageRead;
  DateTime? readAt;

  // Métadonnées
  String? uploaderId;
  String? scanlationGroup;

  Chapter();

  // Factory depuis JSON MangaDex
  factory Chapter.fromMangaDexJson(Map<String, dynamic> json, String mangaId) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    String? scanGroup;
    for (final rel in relationships) {
      if (rel['type'] == 'scanlation_group') {
        scanGroup = rel['attributes']?['name']?.toString();
        break;
      }
    }

    final pagesValue = attributes['pages'];
    int? pagesInt;
    if (pagesValue != null) {
      pagesInt = pagesValue is int
          ? pagesValue
          : int.tryParse(pagesValue.toString());
    }

    return Chapter()
      ..mangadexId = json['id'].toString()
      ..mangaId = mangaId
      ..title = attributes['title']?.toString()
      ..chapterNumber = attributes['chapter']?.toString()
      ..volumeNumber = attributes['volume']?.toString()
      ..translatedLanguage = attributes['translatedLanguage']?.toString()
      ..pagesCount = pagesInt
      ..scanlationGroup = scanGroup
      ..uploaderId = attributes['uploader']?.toString()
      ..publishAt = attributes['publishAt'] != null
          ? DateTime.tryParse(attributes['publishAt'].toString())
          : null
      ..readableAt = attributes['readableAt'] != null
          ? DateTime.tryParse(attributes['readableAt'].toString())
          : null;
  }

  // Label d'affichage
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (chapterNumber != null) return 'Chapitre $chapterNumber';
    return 'Chapitre inconnu';
  }
}
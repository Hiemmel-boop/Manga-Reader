import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/mangadex_api.dart';
import '../../data/datasources/local/preferences.dart';

// EXPORT DU PROVIDER
final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository(
    ref.watch(mangaDexApiProvider),
    ref.watch(preferencesProvider),
  );
});

class ChapterRepository {
  final MangaDexApi _api;
  final Preferences _prefs;

  ChapterRepository(this._api, this._prefs);

  Future<List<Chapter>> getMangaChapters(String mangaId) async {
    try {
      await _prefs.init();
      final preferredLang = await _prefs.getDefaultLanguage() ?? 'fr';

      final response = await _api.getMangaChapters(mangaId, language: preferredLang);
      final List<dynamic> data = response.data['data'] ?? [];

      List<Chapter> chapters = data.map((json) => Chapter.fromJson(json)).toList();

      chapters.removeWhere((c) => c.chapterNumber == null || c.chapterNumber!.isEmpty);

      final Map<String, Chapter> uniqueChapters = {};

      for (final chapter in chapters) {
        final key = chapter.chapterNumber!;

        if (uniqueChapters.containsKey(key)) {
          final existing = uniqueChapters[key]!;
          if (chapter.publishAt != null && existing.publishAt != null) {
            if (chapter.publishAt!.isAfter(existing.publishAt!)) {
              uniqueChapters[key] = chapter;
            }
          }
        } else {
          uniqueChapters[key] = chapter;
        }
      }

      final result = uniqueChapters.values.toList();
      result.sort((a, b) {
        final numA = double.tryParse(a.chapterNumber ?? '0') ?? 0;
        final numB = double.tryParse(b.chapterNumber ?? '0') ?? 0;
        return numA.compareTo(numB);
      });

      return result;
    } catch (e) {
      throw Exception('Erreur chargement chapitres: $e');
    }
  }

  Future<List<String>> getChapterPages(String chapterId) async {
    try {
      final response = await _api.getChapterPages(chapterId);
      final baseUrl = response.data['baseUrl'];
      final hash = response.data['chapter']['hash'];
      final List<dynamic> data = response.data['chapter']['data'];

      return data.map<String>((page) => '$baseUrl/data/$hash/$page').toList();
    } catch (e) {
      throw Exception('Erreur chargement pages: $e');
    }
  }
}

class Chapter {
  final String id;
  final String? title;
  final String? chapterNumber;
  final String? translatedLanguage;
  final DateTime? publishAt;
  final int? pages;
  final String? scanlationGroup;

  Chapter({
    required this.id,
    this.title,
    this.chapterNumber,
    this.translatedLanguage,
    this.publishAt,
    this.pages,
    this.scanlationGroup,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};

    String? scanGroup;
    final relationships = json['relationships'] as List<dynamic>? ?? [];
    for (final rel in relationships) {
      if (rel['type'] == 'scanlation_group') {
        scanGroup = rel['attributes']?['name'];
        break;
      }
    }

    // CORRECTION: Convertir pages en int si c'est une String
    final pagesValue = attributes['pages'];
    int? pagesInt;
    if (pagesValue != null) {
      pagesInt = pagesValue is int ? pagesValue : int.tryParse(pagesValue.toString());
    }

    return Chapter(
      id: json['id'],
      title: attributes['title'],
      chapterNumber: attributes['chapter']?.toString(), // Convertir en String
      translatedLanguage: attributes['translatedLanguage'],
      publishAt: attributes['publishAt'] != null
          ? DateTime.parse(attributes['publishAt'])
          : null,
      pages: pagesInt,
      scanlationGroup: scanGroup,
    );
  }
}
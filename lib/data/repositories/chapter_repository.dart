import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../local/database.dart';
import '../local/preferences.dart';
import '../remote/mangadex_api.dart';
import '../models/chapter.dart';
import '../../core/logger.dart';

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository(
    ref.watch(mangaDexApiProvider),
    ref.watch(isarProvider),
    ref.watch(preferencesProvider),
  );
});

class ChapterRepository {
  final MangaDexApi _api;
  final Isar _isar;
  final Preferences _prefs;

  ChapterRepository(this._api, this._isar, this._prefs);

  Future<List<Chapter>> getMangaChapters(String mangaId) async {
    try {
      final language = await _prefs.getDefaultLanguage();
      final response = await _api.getMangaChapters(mangaId, language: language);
      final List<dynamic> data = response.data['data'] ?? [];

      List<Chapter> chapters = data
          .map((json) => Chapter.fromMangaDexJson(json, mangaId))
          .toList();

      // Supprimer chapitres sans numéro
      chapters.removeWhere((c) =>
      c.chapterNumber == null || c.chapterNumber!.isEmpty);

      // Dédoublonner — garder le plus récent par numéro
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

      // Trier par numéro croissant
      final result = uniqueChapters.values.toList()
        ..sort((a, b) {
          final numA = double.tryParse(a.chapterNumber ?? '0') ?? 0;
          final numB = double.tryParse(b.chapterNumber ?? '0') ?? 0;
          return numA.compareTo(numB);
        });

      return result;
    } catch (e) {
      appLogger.e('getMangaChapters', error: e);
      throw Exception('Impossible de charger les chapitres');
    }
  }

  Future<List<String>> getChapterPages(String chapterId) async {
    try {
      // Vérifier d'abord en local (pages téléchargées)
      final local = await _isar.chapters
          .filter()
          .mangadexIdEqualTo(chapterId)
          .findFirst();

      if (local != null && local.pageUrls.isNotEmpty) {
        return local.pageUrls;
      }

      // Sinon charger depuis l'API
      final response = await _api.getChapterPages(chapterId);
      final baseUrl = response.data['baseUrl'];
      final hash = response.data['chapter']['hash'];
      final List<dynamic> data = response.data['chapter']['data'];

      return data
          .map<String>((page) => '$baseUrl/data/$hash/$page')
          .toList();
    } catch (e) {
      appLogger.e('getChapterPages', error: e);
      throw Exception('Impossible de charger les pages');
    }
  }

  Future<void> markAsRead(String chapterId) async {
    try {
      final chapter = await _isar.chapters
          .filter()
          .mangadexIdEqualTo(chapterId)
          .findFirst();

      if (chapter != null) {
        await _isar.writeTxn(() async {
          chapter
            ..isRead = true
            ..readAt = DateTime.now();
          await _isar.chapters.put(chapter);
        });
      }
    } catch (e) {
      appLogger.e('markAsRead', error: e);
    }
  }
}
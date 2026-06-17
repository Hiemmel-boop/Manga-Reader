import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/preferences.dart';
import '../remote/mangadex_api.dart';
import '../models/chapter.dart';
import '../../core/logger.dart';

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

  Future<List<Chapter>> getMangaChapters(
      String mangaId, {
        int limit = 100,
        int offset = 0,
      }) async {
    try {
      String? language = await _prefs.getDefaultLanguage();
      appLogger.i('Langue demandée par l\'app : $language');

      // Si la langue est nulle ou vide, on force à null pour que l'API renvoie FR et EN
      if (language == null || language.isEmpty) {
        language = null;
      }

      final response = await _api.getMangaChapters(
        mangaId,
        limit: limit,
        offset: offset,
        language: language,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      appLogger.i('MangaDex a renvoyé ${data.length} chapitres bruts pour le manga $mangaId');

      // --- SYSTÈME DE SECOURS ---
      // Si on a 0 chapitre dans la langue demandée (ex: Solo Leveling en FR), on réessaie en Anglais !
      if (data.isEmpty && language != null) {
        appLogger.i('Pas de chapitre en $language, réessai en anglais...');
        final responseEn = await _api.getMangaChapters(
          mangaId,
          limit: limit,
          offset: offset,
          language: 'en',
        );
        final List<dynamic> dataEn = responseEn.data['data'] ?? [];
        appLogger.i('MangaDex a renvoyé ${dataEn.length} chapitres en anglais');
        return dataEn.map((json) => Chapter.fromMangaDexJson(json, mangaId)).toList();
      }

      return data.map((json) => Chapter.fromMangaDexJson(json, mangaId)).toList();

    } catch (e) {
      appLogger.e('Erreur getMangaChapters', error: e);
      throw Exception('Impossible de charger les chapitres');
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
      appLogger.e('getChapterPages', error: e);
      throw Exception('Impossible de charger les pages');
    }
  }

  Future<void> markAsRead(String chapterId) async {
    // Placeholder vide
  }
}
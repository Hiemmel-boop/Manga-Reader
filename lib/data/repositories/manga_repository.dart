import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../remote/mangadex_api.dart';
import '../models/manga.dart';
import '../../core/logger.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return MangaRepository(ref.watch(mangaDexApiProvider));
});

class MangaRepository {
  final MangaDexApi _api;

  MangaRepository(this._api);

  // ─── API ───────────────────────────────────────────────

  Future<List<Manga>> getPopularManga({int limit = 20}) async {
    try {
      final response = await _api.getMangaList(limit: limit);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Manga.fromMangaDexJson(json)).toList();
    } catch (e) {
      appLogger.e('getPopularManga', error: e);
      throw Exception('Impossible de charger les mangas populaires');
    }
  }

  Future<List<Manga>> searchManga(String query, {int limit = 20, String? status, String? contentRating, int? year}) async {
    try {
      final response = await _api.searchManga(query, limit: limit, status: status, contentRating: contentRating, year: year);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Manga.fromMangaDexJson(json)).toList();
    } catch (e) {
      appLogger.e('searchManga', error: e);
      throw Exception('Erreur lors de la recherche');
    }
  }

  Future<Manga?> getMangaDetails(String mangaId) async {
    try {
      final response = await _api.getMangaDetails(mangaId);
      final json = response.data['data'];
      return Manga.fromMangaDexJson(json);
    } catch (e) {
      appLogger.e('getMangaDetails', error: e);
      throw Exception('Impossible de charger les détails du manga');
    }
  }

  // ─── BIBLIOTHÈQUE (Placeholder vide) ────────────────────

  Future<List<Manga>> getLibrary() async => [];
  Future<void> addToLibrary(Manga manga) async {}
  Future<void> removeFromLibrary(String mangadexId) async {}
  Future<bool> isInLibrary(String mangadexId) async => false;
}
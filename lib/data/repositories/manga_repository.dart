import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import '../remote/mangadex_api.dart';
import '../models/manga.dart';
import '../../core/logger.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return MangaRepository(ref.watch(mangaDexApiProvider), DatabaseHelper());
});

class MangaRepository {
  final MangaDexApi _api;
  final DatabaseHelper _db;

  MangaRepository(this._api, this._db);

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

  // ─── BIBLIOTHÈQUE (Sqflite) ────────────────────────────

  Future<List<Manga>> getLibrary() async {
    return await _db.getFavoriteMangas();
  }

  Future<void> addToLibrary(Manga manga) async {
    try {
      var localManga = await _db.getMangaByMangadexId(manga.mangadexId);

      if (localManga != null) {
        localManga
          ..isInLibrary = true
          ..addedToLibraryAt = DateTime.now()
          ..title = manga.title
          ..coverUrl = manga.coverUrl
          ..author = manga.author;
        await _db.updateManga(localManga);
      } else {
        final newManga = Manga()
          ..mangadexId = manga.mangadexId
          ..title = manga.title
          ..coverUrl = manga.coverUrl
          ..author = manga.author
          ..description = manga.description
          ..status = manga.status
          ..isInLibrary = true
          ..addedToLibraryAt = DateTime.now()
          ..tags = manga.tags;
        await _db.insertManga(newManga);
      }
    } catch (e) {
      appLogger.e('addToLibrary', error: e);
    }
  }

  Future<void> removeFromLibrary(String mangadexId) async {
    try {
      var localManga = await _db.getMangaByMangadexId(mangadexId);
      if (localManga != null) {
        localManga
          ..isInLibrary = false
          ..addedToLibraryAt = null;
        await _db.updateManga(localManga);
      }
    } catch (e) {
      appLogger.e('removeFromLibrary', error: e);
    }
  }

  Future<bool> isInLibrary(String mangadexId) async {
    var localManga = await _db.getMangaByMangadexId(mangadexId);
    return localManga?.isInLibrary ?? false;
  }
}
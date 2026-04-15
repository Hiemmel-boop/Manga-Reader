import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../local/database.dart';
import '../remote/mangadex_api.dart';
import '../models/manga.dart';
import '../../core/logger.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return MangaRepository(
    ref.watch(mangaDexApiProvider),
    ref.watch(isarProvider),
  );
});

class MangaRepository {
  final MangaDexApi _api;
  final Isar _isar;

  MangaRepository(this._api, this._isar);

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

  Future<List<Manga>> searchManga(
      String query, {
        int limit = 20,
        String? status,
        String? contentRating,
        int? year,
      }) async {
    try {
      final response = await _api.searchManga(
        query,
        limit: limit,
        status: status,
        contentRating: contentRating,
        year: year,
      );
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

  // ─── BIBLIOTHÈQUE ──────────────────────────────────────

  Future<List<Manga>> getLibrary() async {
    return _isar.mangas
        .filter()
        .isInLibraryEqualTo(true)
        .sortByAddedToLibraryAtDesc()
        .findAll();
  }

  Future<void> addToLibrary(Manga manga) async {
    try {
      final existing = await _isar.mangas
          .filter()
          .mangadexIdEqualTo(manga.mangadexId)
          .findFirst();

      await _isar.writeTxn(() async {
        if (existing != null) {
          existing
            ..isInLibrary = true
            ..addedToLibraryAt = DateTime.now()
            ..title = manga.title
            ..coverUrl = manga.coverUrl
            ..author = manga.author;
          await _isar.mangas.put(existing);
        } else {
          manga
            ..isInLibrary = true
            ..addedToLibraryAt = DateTime.now();
          await _isar.mangas.put(manga);
        }
      });
    } catch (e) {
      appLogger.e('addToLibrary', error: e);
      throw Exception('Impossible d\'ajouter à la bibliothèque');
    }
  }

  Future<void> removeFromLibrary(String mangadexId) async {
    try {
      final existing = await _isar.mangas
          .filter()
          .mangadexIdEqualTo(mangadexId)
          .findFirst();

      if (existing != null) {
        await _isar.writeTxn(() async {
          existing
            ..isInLibrary = false
            ..addedToLibraryAt = null;
          await _isar.mangas.put(existing);
        });
      }
    } catch (e) {
      appLogger.e('removeFromLibrary', error: e);
    }
  }

  Future<bool> isInLibrary(String mangadexId) async {
    final manga = await _isar.mangas
        .filter()
        .mangadexIdEqualTo(mangadexId)
        .findFirst();
    return manga?.isInLibrary ?? false;
  }
}
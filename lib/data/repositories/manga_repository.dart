import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/mangadex_api.dart';
import '../../data/models/manga.dart';

final mangaRepositoryProvider = Provider<MangaRepository>((ref) {
  return MangaRepository(ref.watch(mangaDexApiProvider));
});

class MangaRepository {
  final MangaDexApi _api;

  MangaRepository(this._api);

  Future<List<Manga>> getPopularManga({int limit = 20}) async {
    try {
      final response = await _api.getMangaList(limit: limit);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => _parseManga(json)).toList();
    } catch (e) {
      throw Exception('Erreur chargement mangas: $e');
    }
  }

  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    try {
      // CORRIGÉ : passe query comme argument positionnel
      final response = await _api.searchManga(query, limit: limit);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => _parseManga(json)).toList();
    } catch (e) {
      throw Exception('Erreur recherche: $e');
    }
  }

  Future<Manga?> getMangaDetails(String mangaId) async {
    try {
      final response = await _api.getMangaDetails(mangaId);
      final json = response.data['data'];
      return _parseManga(json);
    } catch (e) {
      throw Exception('Erreur détails manga: $e');
    }
  }

  Manga _parseManga(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    String? coverFileName;
    String? authorName;

    for (final rel in relationships) {
      if (rel['type'] == 'cover_art') {
        coverFileName = rel['attributes']?['fileName'];
      }
      if (rel['type'] == 'author') {
        authorName = rel['attributes']?['name'];
      }
    }

    final manga = Manga()
      ..mangadexId = json['id']
      ..title = attributes['title']?['en'] ??
          attributes['title']?['ja'] ??
          'Sans titre'
      ..description = attributes['description']?['en']
      ..status = attributes['status']
      ..contentRating = attributes['contentRating']
      ..year = attributes['year']
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    if (coverFileName != null) {
      manga.coverUrl =
      'https://uploads.mangadex.org/covers/${json['id']}/$coverFileName';
    }

    if (authorName != null) {
      manga.author = authorName;
    }

    final tags = attributes['tags'] as List<dynamic>? ?? [];
    manga.tags = tags
        .map((t) => t['attributes']?['name']?['en'] ?? '')
        .where((s) => s.isNotEmpty)
        .toList()
        .cast<String>();

    return manga;
  }
}
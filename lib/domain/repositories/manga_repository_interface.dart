import '../entities/manga_entity.dart';

abstract class MangaRepositoryInterface {
  Future<List<MangaEntity>> getPopularManga({int limit = 20});
  Future<List<MangaEntity>> searchManga(String query, {int limit = 20});
  Future<MangaEntity?> getMangaDetails(String mangaId);
  Future<void> addToLibrary(String mangaId);
  Future<void> removeFromLibrary(String mangaId);
  Future<List<MangaEntity>> getLibraryManga();
  Future<bool> isInLibrary(String mangaId);
}
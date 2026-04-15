import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/manga.dart';
import '../../data/repositories/manga_repository.dart';

// Mangas populaires
final popularMangaProvider = FutureProvider<List<Manga>>((ref) async {
  return ref.watch(mangaRepositoryProvider).getPopularManga(limit: 20);
});

// Détails d'un manga
final mangaDetailProvider = FutureProvider.family<Manga?, String>((ref, mangaId) async {
  return ref.watch(mangaRepositoryProvider).getMangaDetails(mangaId);
});

// Bibliothèque
final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Manga>>((ref) {
  return LibraryNotifier(ref.watch(mangaRepositoryProvider));
});

final isMangaInLibraryProvider = Provider.family<bool, String>((ref, mangaId) {
  return ref.watch(libraryProvider).any((m) => m.mangadexId == mangaId);
});

class LibraryNotifier extends StateNotifier<List<Manga>> {
  final MangaRepository _repo;

  LibraryNotifier(this._repo) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _repo.getLibrary();
  }

  Future<void> add(Manga manga) async {
    await _repo.addToLibrary(manga);
    await load();
  }

  Future<void> remove(String mangadexId) async {
    await _repo.removeFromLibrary(mangadexId);
    await load();
  }
}
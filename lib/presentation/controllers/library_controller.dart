import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database.dart';
import '../../data/models/manga.dart';
import 'package:isar/isar.dart';

final libraryControllerProvider = StateNotifierProvider<LibraryController, List<Manga>>((ref) {
  return LibraryController(ref);
});

final isMangaInLibraryProvider = Provider.family<bool, String>((ref, mangaId) {
  final library = ref.watch(libraryControllerProvider);
  return library.any((m) => m.mangadexId == mangaId);
});

class LibraryController extends StateNotifier<List<Manga>> {
  final Ref ref;
  Isar? _db;
  bool _initialized = false;

  LibraryController(this.ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    try {
      _db = await ref.read(isarProvider.future);
      _initialized = true;
      await loadLibrary();
    } catch (e) {
      print('Erreur init bibliothèque: $e');
    }
  }

  Future<void> loadLibrary() async {
    if (_db == null) {
      await _init();
      return;
    }

    try {
      final mangas = await _db!.mangas
          .filter()
          .isInLibraryEqualTo(true)
          .sortByAddedToLibraryAtDesc()
          .findAll();

      state = mangas;
    } catch (e) {
      print('Erreur chargement bibliothèque: $e');
    }
  }

  Future<void> addToLibrary(Manga manga) async {
    if (_db == null) await _init();
    if (_db == null) return;

    try {
      final existing = await _db!.mangas
          .filter()
          .mangadexIdEqualTo(manga.mangadexId)
          .findFirst();

      if (existing != null) {
        existing.isInLibrary = true;
        existing.addedToLibraryAt = DateTime.now();
        existing.title = manga.title;
        existing.coverUrl = manga.coverUrl;
        existing.author = manga.author;
        await _db!.writeTxn(() => _db!.mangas.put(existing));
      } else {
        manga.isInLibrary = true;
        manga.addedToLibraryAt = DateTime.now();
        await _db!.writeTxn(() => _db!.mangas.put(manga));
      }

      await loadLibrary();
    } catch (e) {
      print('Erreur ajout bibliothèque: $e');
      throw Exception('Impossible d\'ajouter à la bibliothèque');
    }
  }

  Future<void> removeFromLibrary(Manga manga) async {
    if (_db == null) return;

    try {
      final existing = await _db!.mangas
          .filter()
          .mangadexIdEqualTo(manga.mangadexId)
          .findFirst();

      if (existing != null) {
        existing.isInLibrary = false;
        existing.addedToLibraryAt = null;
        await _db!.writeTxn(() => _db!.mangas.put(existing));
      }

      await loadLibrary();
    } catch (e) {
      print('Erreur suppression: $e');
    }
  }
}
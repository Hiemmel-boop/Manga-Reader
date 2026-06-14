import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/logger.dart';
import '../data/repositories/manga_repository.dart';
import '../data/repositories/chapter_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
    appLogger.i('NotificationService initialisé (Mode fantôme - pas de notifications physiques)');
  }

  // Vérifier les nouveaux chapitres (la logique tourne en fond, mais n'affiche rien)
  Future<void> checkNewChapters(ProviderContainer container) async {
    if (!_initialized) return;

    try {
      final mangaRepo = container.read(mangaRepositoryProvider);
      final chapterRepo = container.read(chapterRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();

      final library = await mangaRepo.getLibrary();
      if (library.isEmpty) return;

      appLogger.i('Vérification nouveaux chapitres — ${library.length} mangas');

      for (final manga in library) {
        try {
          final chapters = await chapterRepo.getMangaChapters(manga.mangadexId);
          if (chapters.isEmpty) continue;

          final lastChapter = chapters.last;
          final key = 'last_chapter_${manga.mangadexId}';
          final lastKnown = prefs.getString(key);
          final current = lastChapter.chapterNumber;

          if (current != null) {
            if (lastKnown != null && lastKnown != current) {
              // Normalement on affiche la notification ici, mais on se contente de logger
              appLogger.i('NOUVEAU CHAPITRE TROUVÉ : ${manga.title} — Ch.$current');
            }
            await prefs.setString(key, current);
          }
        } catch (e) {
          appLogger.w('Erreur vérification ${manga.title}: $e');
        }
      }

      await prefs.setString('last_check_date', DateTime.now().toIso8601String());
    } catch (e) {
      appLogger.e('checkNewChapters', error: e);
    }
  }

  Future<void> cancelAll() async {
    // Rien à faire
  }
}
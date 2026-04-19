import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/logger.dart';
import '../data/repositories/manga_repository.dart';
import '../data/repositories/chapter_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Vérifier si les notifications sont supportées sur la plateforme
  bool get _isSupported =>
      !kIsWeb &&
          defaultTargetPlatform != TargetPlatform.linux &&
          defaultTargetPlatform != TargetPlatform.windows;

  Future<void> initialize() async {
    if (!_isSupported) {
      appLogger.i('Notifications non supportées sur cette plateforme');
      return;
    }
    if (_initialized) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _initialized = true;
      appLogger.i('NotificationService initialisé');
    } catch (e) {
      appLogger.e('NotificationService init', error: e);
    }
  }

  // ── Afficher une notification ──────────────────────────────────────────────

  Future<void> showNewChapter({
    required String mangaTitle,
    required String chapterTitle,
    required String mangaId,
  }) async {
    if (!_initialized) return;
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'new_chapters',
          'Nouveaux chapitres',
          channelDescription: 'Notification quand un nouveau chapitre est disponible',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            'Nouveau chapitre disponible : $chapterTitle',
            contentTitle: mangaTitle,
          ),
        ),
      );
      await _plugin.show(
        mangaId.hashCode.abs(),
        mangaTitle,
        'Nouveau : $chapterTitle',
        details,
      );
    } catch (e) {
      appLogger.e('showNewChapter', error: e);
    }
  }

  // ── Vérifier les nouveaux chapitres (appelé une fois par jour) ─────────────

  Future<void> checkNewChapters(ProviderContainer container) async {
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
            // Si on avait un chapitre enregistré et qu'il a changé → notifier
            if (lastKnown != null && lastKnown != current) {
              await showNewChapter(
                mangaTitle: manga.title,
                chapterTitle: 'Chapitre $current',
                mangaId: manga.mangadexId,
              );
              appLogger.i('Nouveau chapitre : ${manga.title} — Ch.$current');
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
    if (_initialized) await _plugin.cancelAll();
  }
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/logger.dart';
import '../data/repositories/manga_repository.dart';
import '../data/repositories/chapter_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'downloads_channel',
      'Téléchargements',
      description: 'Notifications pour les téléchargements de mangas',
      importance: Importance.low,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    appLogger.i('NotificationService initialisé');
  }

  Future<void> showDownloadProgress({
    required int id,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'downloads_channel',
      'Téléchargements',
      channelDescription: 'Notifications pour les téléchargements de mangas',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      onlyAlertOnce: true,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const LinuxNotificationDetails linuxPlatformChannelSpecifics = LinuxNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      'Téléchargement en cours... $progress/$maxProgress',
      platformChannelSpecifics,
    );
  }

  Future<void> showDownloadComplete({
    required int id,
    required String title,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'downloads_channel',
      'Téléchargements',
      channelDescription: 'Notifications pour les téléchargements de mangas',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const LinuxNotificationDetails linuxPlatformChannelSpecifics = LinuxNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      'Téléchargement terminé !',
      platformChannelSpecifics,
    );
  }

  Future<void> showDownloadError({
    required int id,
    required String title,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'downloads_channel',
      'Téléchargements',
      channelDescription: 'Notifications pour les téléchargements de mangas',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const LinuxNotificationDetails linuxPlatformChannelSpecifics = LinuxNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      'Erreur lors du téléchargement.',
      platformChannelSpecifics,
    );
  }

  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

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
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
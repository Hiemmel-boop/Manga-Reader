import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/logger.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    // Les notifications ne sont supportées que sur Android, iOS et macOS
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      appLogger.i('Notifications non supportées sur cette plateforme');
      return;
    }

    if (_initialized) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(settings);
      _initialized = true;
      appLogger.i('NotificationService initialisé');
    } catch (e) {
      appLogger.e('NotificationService init error', error: e);
    }
  }

  Future<void> showNewChapter(String mangaTitle, String chapterTitle) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'new_chapters', 'Nouveaux chapitres',
        channelDescription: 'Notification pour les nouveaux chapitres',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Nouveau chapitre — $mangaTitle',
        chapterTitle,
        details,
      );
    } catch (e) {
      appLogger.e('showNewChapter', error: e);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
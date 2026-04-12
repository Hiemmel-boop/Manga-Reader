import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  Future<void> showNewChapterNotification(String mangaTitle, String chapterTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'new_chapters',
      'Nouveaux chapitres',
      channelDescription: 'Notifications quand un nouveau chapitre est disponible',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Nouveau chapitre !',
      '$mangaTitle - $chapterTitle',
      details,
    );
  }

  Future<void> showDownloadComplete(String mangaTitle, String chapterTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Téléchargements',
      channelDescription: 'Notifications de fin de téléchargement',
      importance: Importance.low,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'Téléchargement terminé',
      '$mangaTitle - $chapterTitle',
      details,
    );
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // TODO: Programmer rappel quotidien de lecture
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
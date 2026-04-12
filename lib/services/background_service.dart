import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/database.dart';
import '../data/repositories/chapter_repository.dart';
import '../data/repositories/manga_repository.dart';
import 'notification_service.dart';

final backgroundServiceProvider = Provider<BackgroundService>((ref) {
  return BackgroundService(ref);
});

class BackgroundService {
  final Ref ref;

  BackgroundService(this.ref);

  Future<void> initialize() async {
    // TODO: Initialiser WorkManager pour tâches périodiques
  }

  Future<void> checkForNewChapters() async {
    // TODO: Vérifier nouveaux chapitres pour les mangas en bibliothèque
    // - Récupérer liste mangas favoris
    // - Comparer avec derniers chapitres connus
    // - Si nouveau → notification
  }

  Future<void> downloadChapter(String chapterId) async {
    // TODO: Télécharger toutes les pages d'un chapitre pour lecture hors-ligne
    // - Récupérer URLs des pages
    // - Télécharger images dans dossier app
    // - Marquer comme disponible hors-ligne
  }

  Future<void> downloadManga(String mangaId) async {
    // TODO: Télécharger tous les chapitres d'un manga
  }

  Future<void> cleanupOldDownloads({int maxAgeDays = 30}) async {
    // TODO: Supprimer téléchargements anciens pour libérer espace
  }

  Future<void> syncDataIfNeeded() async {
    // TODO: Synchroniser si WiFi disponible et dernière sync > 24h
  }
}
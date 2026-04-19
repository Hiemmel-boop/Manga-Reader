import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import '../core/logger.dart';
import '../data/local/database.dart';
import '../data/models/chapter.dart';
import '../data/repositories/chapter_repository.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref);
});

// État d'un téléchargement
class DownloadState {
  final String chapterId;
  final String mangaTitle;
  final String chapterTitle;
  final double progress; // 0.0 à 1.0
  final bool isComplete;
  final bool hasError;

  const DownloadState({
    required this.chapterId,
    required this.mangaTitle,
    required this.chapterTitle,
    this.progress = 0.0,
    this.isComplete = false,
    this.hasError = false,
  });

  DownloadState copyWith({
    double? progress,
    bool? isComplete,
    bool? hasError,
  }) {
    return DownloadState(
      chapterId: chapterId,
      mangaTitle: mangaTitle,
      chapterTitle: chapterTitle,
      progress: progress ?? this.progress,
      isComplete: isComplete ?? this.isComplete,
      hasError: hasError ?? this.hasError,
    );
  }
}

// Provider pour suivre l'état des téléchargements en cours
final downloadStatesProvider =
StateNotifierProvider<DownloadStatesNotifier, Map<String, DownloadState>>(
      (ref) => DownloadStatesNotifier(),
);

class DownloadStatesNotifier
    extends StateNotifier<Map<String, DownloadState>> {
  DownloadStatesNotifier() : super({});

  void start(DownloadState downloadState) {
    this.state = {...this.state, downloadState.chapterId: downloadState};
  }

  void update(String chapterId, double progress) {
    if (state.containsKey(chapterId)) {
      state = {
        ...state,
        chapterId: state[chapterId]!.copyWith(progress: progress),
      };
    }
  }

  void complete(String chapterId) {
    if (state.containsKey(chapterId)) {
      state = {
        ...state,
        chapterId: state[chapterId]!.copyWith(isComplete: true, progress: 1.0),
      };
    }
  }

  void error(String chapterId) {
    if (state.containsKey(chapterId)) {
      state = {
        ...state,
        chapterId: state[chapterId]!.copyWith(hasError: true),
      };
    }
  }

  void remove(String chapterId) {
    final newState = Map<String, DownloadState>.from(state);
    newState.remove(chapterId);
    state = newState;
  }
}

class DownloadService {
  final Ref _ref;
  final _dio = Dio();

  DownloadService(this._ref);

  // Dossier de téléchargement
  Future<Directory> get _downloadDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // Vérifier si un chapitre est téléchargé
  Future<bool> isDownloaded(String chapterId) async {
    final dir = await _downloadDir;
    final chapterDir = Directory('${dir.path}/$chapterId');
    return chapterDir.exists();
  }

  // Récupérer les IDs de tous les chapitres téléchargés
  Future<List<String>> getDownloadedChapterIds() async {
    try {
      final dir = await _downloadDir;
      if (!await dir.exists()) return [];
      final entities = await dir.list().toList();
      return entities
          .whereType<Directory>()
          .map((d) => d.path.split('/').last)
          .toList();
    } catch (e) {
      appLogger.e('getDownloadedChapterIds', error: e);
      return [];
    }
  }

  // Télécharger un chapitre
  Future<void> downloadChapter({
    required String chapterId,
    required String mangaId,
    required String mangaTitle,
    required String chapterTitle,
  }) async {
    // Non supporté sur Web
    if (kIsWeb) return;

    final notifier = _ref.read(downloadStatesProvider.notifier);

    notifier.start(DownloadState(
      chapterId: chapterId,
      mangaTitle: mangaTitle,
      chapterTitle: chapterTitle,
    ));

    try {
      // Récupérer les URLs des pages
      final chapterRepo = _ref.read(chapterRepositoryProvider);
      final pages = await chapterRepo.getChapterPages(chapterId);

      if (pages.isEmpty) {
        notifier.error(chapterId);
        return;
      }

      // Créer le dossier du chapitre
      final dir = await _downloadDir;
      final chapterDir = Directory('${dir.path}/$chapterId');
      await chapterDir.create(recursive: true);

      // Télécharger chaque page
      for (int i = 0; i < pages.length; i++) {
        final pageUrl = pages[i];
        final fileName = 'page_${i.toString().padLeft(3, '0')}.jpg';
        final filePath = '${chapterDir.path}/$fileName';

        await _dio.download(pageUrl, filePath);
        notifier.update(chapterId, (i + 1) / pages.length);
      }

      // Sauvegarder les chemins locaux dans Isar
      final isar = _ref.read(isarProvider);
      final chapter = await isar.chapters
          .filter()
          .mangadexIdEqualTo(chapterId)
          .findFirst();

      if (chapter != null) {
        final localPaths = List.generate(
          pages.length,
              (i) =>
          '${chapterDir.path}/page_${i.toString().padLeft(3, '0')}.jpg',
        );
        await isar.writeTxn(() async {
          chapter.pageUrls = localPaths;
          await isar.chapters.put(chapter);
        });
      }

      notifier.complete(chapterId);
      appLogger.i('Téléchargement terminé : $chapterTitle');
    } catch (e) {
      appLogger.e('downloadChapter', error: e);
      notifier.error(chapterId);
    }
  }

  // Supprimer un chapitre téléchargé
  Future<void> deleteDownload(String chapterId) async {
    try {
      final dir = await _downloadDir;
      final chapterDir = Directory('${dir.path}/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }

      // Remettre les URLs en ligne dans Isar
      final isar = _ref.read(isarProvider);
      final chapter = await isar.chapters
          .filter()
          .mangadexIdEqualTo(chapterId)
          .findFirst();

      if (chapter != null) {
        await isar.writeTxn(() async {
          chapter.pageUrls = [];
          await isar.chapters.put(chapter);
        });
      }

      appLogger.i('Téléchargement supprimé : $chapterId');
    } catch (e) {
      appLogger.e('deleteDownload', error: e);
    }
  }

  // Taille totale des téléchargements
  Future<String> getTotalDownloadSize() async {
    try {
      final dir = await _downloadDir;
      if (!await dir.exists()) return '0 Mo';

      int totalBytes = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      if (totalBytes < 1024 * 1024) {
        return '${(totalBytes / 1024).toStringAsFixed(1)} Ko';
      }
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    } catch (e) {
      return '0 Mo';
    }
  }
}
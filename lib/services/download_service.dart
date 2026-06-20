import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../core/logger.dart';
import '../data/repositories/chapter_repository.dart';
import 'notification_service.dart'; // <-- L'IMPORT EST LÀ

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref);
});

class DownloadState {
  final String chapterId;
  final String mangaTitle;
  final String chapterTitle;
  final double progress;
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

final downloadStatesProvider =
StateNotifierProvider<DownloadStatesNotifier, Map<String, DownloadState>>(
      (ref) => DownloadStatesNotifier(),
);

class DownloadStatesNotifier extends StateNotifier<Map<String, DownloadState>> {
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

  Future<Directory> get _downloadDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<bool> isDownloaded(String chapterId) async {
    final dir = await _downloadDir;
    final chapterDir = Directory('${dir.path}/$chapterId');
    return chapterDir.exists();
  }

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

  Future<void> downloadChapter({
    required String chapterId,
    required String mangaId,
    required String mangaTitle,
    required String chapterTitle,
  }) async {
    if (kIsWeb) return;

    final notifier = _ref.read(downloadStatesProvider.notifier);
    final notifService = _ref.read(notificationServiceProvider);
    final notifId = chapterId.hashCode;

    notifier.start(DownloadState(
      chapterId: chapterId,
      mangaTitle: mangaTitle,
      chapterTitle: chapterTitle,
    ));

    try {
      final chapterRepo = _ref.read(chapterRepositoryProvider);
      final pages = await chapterRepo.getChapterPages(chapterId);

      if (pages.isEmpty) {
        notifier.error(chapterId);
        await notifService.showDownloadError(id: notifId, title: chapterTitle);
        return;
      }

      final dir = await _downloadDir;
      final chapterDir = Directory('${dir.path}/$chapterId');
      await chapterDir.create(recursive: true);

      await notifService.showDownloadProgress(
        id: notifId,
        title: chapterTitle,
        progress: 0,
        maxProgress: pages.length,
      );

      for (int i = 0; i < pages.length; i++) {
        final pageUrl = pages[i];
        final fileName = 'page_${i.toString().padLeft(3, '0')}.jpg';
        final filePath = '${chapterDir.path}/$fileName';

        await _dio.download(pageUrl, filePath);
        notifier.update(chapterId, (i + 1) / pages.length);

        await notifService.showDownloadProgress(
          id: notifId,
          title: chapterTitle,
          progress: i + 1,
          maxProgress: pages.length,
        );
      }

      notifier.complete(chapterId);
      await notifService.showDownloadComplete(id: notifId, title: chapterTitle);

      appLogger.i('Téléchargement terminé : $chapterTitle');
    } catch (e) {
      appLogger.e('downloadChapter', error: e);
      notifier.error(chapterId);
      await notifService.showDownloadError(id: notifId, title: chapterTitle);
    }
  }

  Future<void> deleteDownload(String chapterId) async {
    try {
      final dir = await _downloadDir;
      final chapterDir = Directory('${dir.path}/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }

      final notifService = _ref.read(notificationServiceProvider);
      await notifService.cancel(chapterId.hashCode);

      appLogger.i('Téléchargement supprimé : $chapterId');
    } catch (e) {
      appLogger.e('deleteDownload', error: e);
    }
  }

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
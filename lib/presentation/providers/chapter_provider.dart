import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chapter.dart';
import '../../data/repositories/chapter_repository.dart';

// Chapitres d'un manga
final mangaChaptersProvider = FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  return ref.watch(chapterRepositoryProvider).getMangaChapters(mangaId);
});

// Pages d'un chapitre
final chapterPagesProvider = FutureProvider.family<List<String>, String>((ref, chapterId) async {
  return ref.watch(chapterRepositoryProvider).getChapterPages(chapterId);
});
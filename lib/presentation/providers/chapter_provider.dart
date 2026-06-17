import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chapter.dart';
import '../../data/repositories/chapter_repository.dart';

class ChapterListState {
  final List<Chapter> chapters;
  final bool isLoading;
  final bool hasMore;
  final int offset;
  final String? error;

  ChapterListState({
    this.chapters = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
  });

  ChapterListState copyWith({
    List<Chapter>? chapters,
    bool? isLoading,
    bool? hasMore,
    int? offset,
    String? error,
  }) {
    return ChapterListState(
      chapters: chapters ?? this.chapters,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error,
    );
  }
}

class ChapterListNotifier extends StateNotifier<ChapterListState> {
  final String mangaId;
  final ChapterRepository _repository;
  final int _limit = 100;

  ChapterListNotifier(this.mangaId, this._repository) : super(ChapterListState()) {
    fetchInitialChapters();
  }

  Future<void> fetchInitialChapters() async {
    state = ChapterListState(isLoading: true);
    try {
      final chapters = await _repository.getMangaChapters(mangaId, limit: _limit, offset: 0);
      final deduplicated = _deduplicateAndSort(chapters);

      state = ChapterListState(
        chapters: deduplicated,
        hasMore: chapters.length == _limit,
        offset: _limit,
      );
    } catch (e) {
      state = ChapterListState(error: e.toString());
    }
  }

  Future<void> fetchMoreChapters() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    try {
      final newChapters = await _repository.getMangaChapters(mangaId, limit: _limit, offset: state.offset);
      final allChapters = [...state.chapters, ...newChapters];
      final deduplicated = _deduplicateAndSort(allChapters);

      state = state.copyWith(
        chapters: deduplicated,
        isLoading: false,
        offset: state.offset + _limit,
        hasMore: newChapters.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  List<Chapter> _deduplicateAndSort(List<Chapter> chapters) {
    final Map<String, Chapter> uniqueChapters = {};
    for (final chapter in chapters) {
      final key = chapter.chapterNumber ?? 'unique_${chapter.mangadexId}';

      if (uniqueChapters.containsKey(key)) {
        final existing = uniqueChapters[key]!;
        if (chapter.publishAt != null && existing.publishAt != null) {
          if (chapter.publishAt!.isAfter(existing.publishAt!)) {
            uniqueChapters[key] = chapter;
          }
        }
      } else {
        uniqueChapters[key] = chapter;
      }
    }

    final result = uniqueChapters.values.toList()
      ..sort((a, b) {
        final numA = double.tryParse(a.chapterNumber ?? '-1') ?? -1;
        final numB = double.tryParse(b.chapterNumber ?? '-1') ?? -1;
        return numB.compareTo(numA);
      });

    return result;
  }
}

final mangaChaptersProvider = StateNotifierProvider.family<ChapterListNotifier, ChapterListState, String>(
      (ref, mangaId) {
    return ChapterListNotifier(mangaId, ref.watch(chapterRepositoryProvider));
  },
);

final chapterPagesProvider = FutureProvider.family<List<String>, String>((ref, chapterId) async {
  return ref.watch(chapterRepositoryProvider).getChapterPages(chapterId);
});
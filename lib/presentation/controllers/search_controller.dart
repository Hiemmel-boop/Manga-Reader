import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/manga.dart';
import '../../data/repositories/manga_repository.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Manga>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(mangaRepositoryProvider);
  return await repo.searchManga(query);
});

final searchControllerProvider = StateNotifierProvider<SearchController, AsyncValue<List<Manga>>>((ref) {
  return SearchController(ref.watch(mangaRepositoryProvider));
});

class SearchController extends StateNotifier<AsyncValue<List<Manga>>> {
  final MangaRepository _repo;

  SearchController(this._repo) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final results = await _repo.searchManga(query);
      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
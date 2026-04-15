import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/manga.dart';
import '../../data/repositories/manga_repository.dart';

// Paramètres de recherche
class SearchParams {
  final String query;
  final String? status;
  final String? contentRating;
  final int? year;

  const SearchParams({
    this.query = '',
    this.status,
    this.contentRating,
    this.year,
  });

  bool get isEmpty => query.isEmpty;

  SearchParams copyWith({
    String? query,
    String? status,
    String? contentRating,
    int? year,
    bool clearStatus = false,
    bool clearRating = false,
    bool clearYear = false,
  }) {
    return SearchParams(
      query: query ?? this.query,
      status: clearStatus ? null : status ?? this.status,
      contentRating: clearRating ? null : contentRating ?? this.contentRating,
      year: clearYear ? null : year ?? this.year,
    );
  }
}

final searchParamsProvider = StateProvider<SearchParams>((ref) => const SearchParams());

final searchResultsProvider = FutureProvider<List<Manga>>((ref) async {
  final params = ref.watch(searchParamsProvider);
  if (params.isEmpty) return [];

  return ref.watch(mangaRepositoryProvider).searchManga(
    params.query,
    status: params.status,
    contentRating: params.contentRating,
    year: params.year,
  );
});
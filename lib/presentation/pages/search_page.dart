import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/search_provider.dart';
import '../widgets/app_widgets.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final params = ref.watch(searchParamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Recherche avancée',
            onPressed: () => context.go('/advanced-search'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher un manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ctrl.clear();
                    ref.read(searchParamsProvider.notifier).state = const SearchParams();
                  },
                )
                    : null,
              ),
              onChanged: (v) {
                ref.read(searchParamsProvider.notifier).state =
                    params.copyWith(query: v);
              },
            ),
          ),

          // Filtres actifs
          if (params.status != null || params.contentRating != null || params.year != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  if (params.status != null)
                    _FilterChip(label: AppTheme.statusLabel(params.status), onRemove: () {
                      ref.read(searchParamsProvider.notifier).state = params.copyWith(clearStatus: true);
                    }),
                  if (params.contentRating != null)
                    _FilterChip(label: params.contentRating!, onRemove: () {
                      ref.read(searchParamsProvider.notifier).state = params.copyWith(clearRating: true);
                    }),
                  if (params.year != null)
                    _FilterChip(label: '${params.year}', onRemove: () {
                      ref.read(searchParamsProvider.notifier).state = params.copyWith(clearYear: true);
                    }),
                ],
              ),
            ),

          Expanded(
            child: results.when(
              data: (mangas) {
                if (params.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: AppSpacing.md),
                        Text('Recherchez un manga pour commencer', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                if (mangas.isEmpty) {
                  return AppErrorWidget(message: 'Aucun résultat pour "${params.query}"', icon: Icons.search_off);
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: mangas.length,
                  itemBuilder: (_, i) {
                    final manga = mangas[i];
                    return GestureDetector(
                      onTap: () => context.go('/manga/${manga.mangadexId}'),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: manga.coverUrl != null
                                  ? CachedNetworkImage(
                                imageUrl: manga.coverUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey[800]!,
                                  highlightColor: Colors.grey[600]!,
                                  child: Container(color: Colors.grey[800]),
                                ),
                                errorWidget: (_, __, ___) => Container(color: Colors.grey[850], child: const Icon(Icons.broken_image)),
                              )
                                  : Container(color: Colors.grey[850], child: const Icon(Icons.book)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(manga.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  if (manga.author != null)
                                    Text(manga.author!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(
                message: 'Erreur: $e',
                onRetry: () => ref.refresh(searchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
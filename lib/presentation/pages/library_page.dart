import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/manga_provider.dart';
import '../widgets/manga_card.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bibliothèque (${library.length})'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        actions: [
          if (library.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _showClearDialog(context, ref, library.length),
            ),
        ],
      ),
      body: library.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 72, color: Colors.grey[600]),
            const SizedBox(height: AppSpacing.md),
            Text('Votre bibliothèque est vide', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: AppSpacing.sm),
            Text('Ajoutez vos mangas favoris', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Découvrir des mangas'),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: library.length,
        itemBuilder: (_, i) {
          final manga = library[i];
          return MangaGridCard(
            manga: manga,
            onTap: () => context.go('/manga/${manga.mangadexId}'),
            onDelete: () {
              ref.read(libraryProvider.notifier).remove(manga.mangadexId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${manga.title} retiré'),
                  action: SnackBarAction(
                    label: 'Annuler',
                    onPressed: () => ref.read(libraryProvider.notifier).add(manga),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider la bibliothèque ?'),
        content: Text('$count manga(s) seront retirés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final library = ref.read(libraryProvider);
              for (final m in library) {
                await ref.read(libraryProvider.notifier).remove(m.mangadexId);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Vider', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
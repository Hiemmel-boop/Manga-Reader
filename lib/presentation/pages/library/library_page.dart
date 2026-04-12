import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/manga.dart';
import '../../controllers/library_controller.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Bibliothèque'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (library.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearLibraryDialog(context, ref, library),
            ),
        ],
      ),
      body: library.isEmpty
          ? _buildEmptyState(context)
          : _buildLibraryGrid(context, ref, library),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Votre bibliothèque est vide',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos mangas préférés pour les retrouver ici',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
            label: const Text('Découvrir des mangas'),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryGrid(BuildContext context, WidgetRef ref, List<Manga> library) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: library.length,
      itemBuilder: (context, index) {
        final manga = library[index];
        return _LibraryCard(
          manga: manga,
          onTap: () => context.go('/manga/${manga.mangadexId}'),
          onDelete: () => _removeFromLibrary(context, ref, manga),
        );
      },
    );
  }

  void _showClearLibraryDialog(BuildContext context, WidgetRef ref, List<Manga> library) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider la bibliothèque ?'),
        content: Text('${library.length} manga(s) seront retirés de votre bibliothèque.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              for (final manga in library) {
                await ref.read(libraryControllerProvider.notifier).removeFromLibrary(manga);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bibliothèque vidée')),
              );
            },
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _removeFromLibrary(BuildContext context, WidgetRef ref, Manga manga) {
    ref.read(libraryControllerProvider.notifier).removeFromLibrary(manga);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${manga.title} retiré de la bibliothèque'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            ref.read(libraryControllerProvider.notifier).addToLibrary(manga);
          },
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LibraryCard({
    required this.manga,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'manga-${manga.mangadexId}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onTap,
              child: manga.coverUrl != null
                  ? CachedNetworkImage(
                imageUrl: manga.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                ),
              )
                  : Container(
                color: Colors.grey[800],
                child: const Icon(Icons.book, color: Colors.white54),
              ),
            ),
            if (manga.status != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    manga.status!,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
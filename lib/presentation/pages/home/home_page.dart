import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/manga.dart';
import '../../../data/repositories/manga_repository.dart';
import '../../controllers/library_controller.dart';

final popularMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final repo = ref.watch(mangaRepositoryProvider);
  return await repo.getPopularManga(limit: 20);
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularMangaProvider);
    final library = ref.watch(libraryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (library.isNotEmpty) ...[
              _buildSectionTitle('Ma Bibliothèque'),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: library.take(10).length,
                  itemBuilder: (context, index) {
                    final manga = library[index];
                    return _MangaCard(
                      manga: manga,
                      onTap: () => context.go('/manga/${manga.mangadexId}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle('Populaires'),
            popularAsync.when(
              data: (mangas) => SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final manga = mangas[index];
                    return _MangaCard(
                      manga: manga,
                      onTap: () => context.go('/manga/${manga.mangadexId}'),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SizedBox(
                height: 280,
                child: Center(child: Text('Erreur: $error')),
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(
                    context,
                    icon: Icons.library_books,
                    label: 'Bibliothèque',
                    onTap: () => context.go('/library'),
                  ),
                  _buildNavButton(
                    context,
                    icon: Icons.history,
                    label: 'Historique',
                    onTap: () => context.go('/history'),
                  ),
                  _buildNavButton(
                    context,
                    icon: Icons.settings,
                    label: 'Paramètres',
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF6C63FF)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;

  const _MangaCard({required this.manga, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: manga.coverUrl != null
                  ? Image.network(
                manga.coverUrl!,
                height: 200,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  width: 140,
                  color: Colors.grey[800],
                  child: const Icon(Icons.book, size: 40),
                ),
              )
                  : Container(
                height: 200,
                width: 140,
                color: Colors.grey[800],
                child: const Icon(Icons.book, size: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              manga.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (manga.author != null)
              Text(
                manga.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
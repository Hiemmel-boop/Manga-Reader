import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/manga_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/manga_card.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularMangaProvider);
    final library = ref.watch(libraryProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => context.go('/search')),
          IconButton(icon: const Icon(Icons.person_rounded), onPressed: () => context.go('/profile')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(popularMangaProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière de bienvenue
              _buildWelcomeBanner(auth.displayName),

              // Bibliothèque (si non vide)
              if (library.isNotEmpty) ...[
                _sectionTitle('Ma Bibliothèque', onSeeAll: () => context.go('/library')),
                SizedBox(
                  // cover 160 + spacing 8 + titre 2 lignes ~36 + auteur ~18 = 222
                  height: 222,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: library.take(10).length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: MangaCard(
                        manga: library[i],
                        height: 160,
                        onTap: () => context.go('/manga/${library[i].mangadexId}'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Populaires
              _sectionTitle('Populaires'),
              popularAsync.when(
                data: (mangas) => SizedBox(
                  // cover 190 + spacing 8 + titre 2 lignes ~36 + auteur ~18 = 252
                  height: 252,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: mangas.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: MangaCard(
                        manga: mangas[i],
                        height: 190,
                        onTap: () => context.go('/manga/${mangas[i].mangadexId}'),
                      ),
                    ),
                  ),
                ),
                loading: () => _shimmerList(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Navigation rapide
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavButton(icon: Icons.library_books_rounded, label: 'Bibliothèque', onTap: () => context.go('/library')),
                    _NavButton(icon: Icons.history_rounded, label: 'Historique', onTap: () => context.go('/history')),
                    _NavButton(icon: Icons.settings_rounded, label: 'Paramètres', onTap: () => context.go('/settings')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(String name) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? 'Bonjour, $name 👋' : 'Bienvenue !',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Que lisez-vous aujourd\'hui ?',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Voir tout')),
        ],
      ),
    );
  }

  Widget _shimmerList() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: 140,
              height: 210,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
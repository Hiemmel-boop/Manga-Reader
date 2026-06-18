import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/manga_card.dart';
import '../../data/models/reading_progress.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularMangaProvider);
    final library = ref.watch(libraryProvider);
    final auth = ref.watch(authProvider);
    final recentProgressAsync = ref.watch(recentProgressProvider);

    // Calcul de la largeur pour les cartes (2 colonnes avec espacement)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 16 padding gauche + 16 droite + 16 entre les cartes

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manga Reader'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => context.push('/search'),
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded),
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(popularMangaProvider);
            ref.invalidate(recentProgressProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Bannière de bienvenue ────────────────────────────
                _WelcomeBanner(name: auth.displayName),

                // ── Continuer la lecture ─────────────────────────────
                recentProgressAsync.when(
                  data: (progressList) {
                    if (progressList.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: 'Continuer la lecture',
                          icon: Icons.play_circle_outline_rounded,
                          onMore: () => context.push('/history'),
                        ),
                        // Affichage vertical en pleine largeur
                        Column(
                          children: progressList.map((p) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md
                              ),
                              child: _ContinueReadingCard(
                                progress: p,
                                onTap: () {
                                  final params = {
                                    'mangaId': p.mangaId,
                                    'mangaTitle': p.mangaTitle,
                                    if (p.mangaCoverUrl != null) 'mangaCoverUrl': p.mangaCoverUrl!,
                                    if (p.chapterTitle != null) 'chapterTitle': p.chapterTitle!,
                                  };
                                  final query = params.entries
                                      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
                                      .join('&');
                                  context.push('/reader/${p.chapterId}?$query');
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ── Ma Bibliothèque ──────────────────────────────────
                if (library.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Ma Bibliothèque',
                    onMore: () => context.push('/library'),
                  ),
                  // Grille verticale (Wrap s'adapte tout seul)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: library.take(6).map((manga) {
                        return MangaCard(
                          manga: manga,
                          width: cardWidth,
                          height: cardWidth * 1.4,
                          onTap: () => context.push('/manga/${manga.mangadexId}'),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Populaires ───────────────────────────────────────
                const _SectionTitle(title: 'Populaires'),
                popularAsync.when(
                  data: (mangas) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: mangas.map((manga) {
                        return MangaCard(
                          manga: manga,
                          width: cardWidth,
                          height: cardWidth * 1.5,
                          onTap: () => context.push('/manga/${manga.mangadexId}'),
                        );
                      }).toList(),
                    ),
                  ),
                  loading: () => _ShimmerGrid(cardWidth: cardWidth),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey[500])),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Navigation rapide ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavButton(icon: Icons.library_books_rounded, label: 'Bibliothèque', onTap: () => context.push('/library')),
                      _NavButton(icon: Icons.history_rounded, label: 'Historique', onTap: () => context.push('/history')),
                      _NavButton(icon: Icons.settings_rounded, label: 'Paramètres', onTap: () => context.push('/settings')),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bannière de bienvenue ─────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String name;
  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? 'Bonjour, $name 👋' : 'Bienvenue !',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Que lisez-vous aujourd\'hui ?',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte "Continuer la lecture" ──────────────────────────────────────────────
class _ContinueReadingCard extends StatelessWidget {
  final ReadingProgress progress;
  final VoidCallback onTap;
  const _ContinueReadingCard({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = progress.progressPercentage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // En pleine largeur
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
              ),
              child: progress.mangaCoverUrl != null
                  ? CachedNetworkImage(
                imageUrl: progress.mangaCoverUrl!,
                width: 70,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 70, color: Colors.grey[800]),
                errorWidget: (_, __, ___) => Container(width: 70, color: Colors.grey[800], child: const Icon(Icons.book, color: Colors.grey)),
              )
                  : Container(width: 70, color: Colors.grey[800], child: const Icon(Icons.book, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(progress.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      progress.chapterTitle != null ? 'Ch. ${progress.chapterNumber ?? ''} — ${progress.chapterTitle}' : 'Chapitre ${progress.chapterNumber ?? '?'}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page ${progress.lastPage}/${progress.totalPages}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                        Text('${(percent * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(Icons.play_circle_filled_rounded, color: AppColors.primary, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Titre de section ──────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onMore;
  const _SectionTitle({required this.title, this.icon, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          if (onMore != null) TextButton(onPressed: onMore, child: const Text('Voir tout')),
        ],
      ),
    );
  }
}

// ── Shimmer chargement (Grille) ───────────────────────────────────────────────
class _ShimmerGrid extends StatelessWidget {
  final double cardWidth;
  const _ShimmerGrid({required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: List.generate(4, (_) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: cardWidth,
              height: cardWidth * 1.5,
              decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(AppRadius.card)),
            ),
          );
        }),
      ),
    );
  }
}

// ── Bouton navigation rapide ──────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
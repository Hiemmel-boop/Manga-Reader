import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../providers/chapter_provider.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart'; // <-- AJOUT : Pour vérifier le mode invité
import '../widgets/app_widgets.dart';
import '../../data/models/manga.dart';
import '../../data/models/chapter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/download_service.dart';

class MangaDetailPage extends ConsumerStatefulWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  ConsumerState<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends ConsumerState<MangaDetailPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        ref.read(mangaChaptersProvider(widget.mangaId).notifier).fetchMoreChapters();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mangaAsync = ref.watch(mangaDetailProvider(widget.mangaId));
    final chaptersState = ref.watch(mangaChaptersProvider(widget.mangaId));
    final isInLibrary = ref.watch(isMangaInLibraryProvider(widget.mangaId));
    final progressAsync = ref.watch(readingProgressProvider(widget.mangaId));
    final auth = ref.watch(authProvider); // <-- AJOUT : On regarde si c'est un invité

    return Scaffold(
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null) return const AppErrorWidget(message: 'Manga introuvable');
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, ref, manga, isInLibrary, auth.isGuest), // <-- AJOUT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(manga.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      if (manga.author != null)
                        Text('Auteur: ${manga.author}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          if (manga.status != null)
                            _StatusChip(status: manga.status!),
                          const SizedBox(width: AppSpacing.sm),
                          if (manga.year != null)
                            Chip(label: Text('${manga.year}'), visualDensity: VisualDensity.compact),
                        ],
                      ),
                      if (manga.tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: manga.tags.map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                      ],
                      if (manga.description != null && manga.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Text('Synopsis', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(manga.description!, style: TextStyle(color: Colors.grey[300], height: 1.6)),
                      ],
                      const SizedBox(height: AppSpacing.lg),

                      if (chaptersState.chapters.isNotEmpty)
                        _buildReadButtons(context, ref, manga, chaptersState.chapters, progressAsync),

                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chapitres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          if (chaptersState.chapters.isNotEmpty)
                            Text('${chaptersState.chapters.length} chapitres', style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),

              if (chaptersState.isLoading && chaptersState.chapters.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                )
              else if (chaptersState.error != null && chaptersState.chapters.isEmpty)
                SliverToBoxAdapter(
                  child: AppErrorWidget(
                    message: 'Erreur chapitres: ${chaptersState.error}',
                    onRetry: () => ref.read(mangaChaptersProvider(widget.mangaId).notifier).fetchInitialChapters(),
                  ),
                )
              else if (chaptersState.chapters.isEmpty && !chaptersState.isLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(padding: EdgeInsets.all(32), child: Text('Aucun chapitre disponible')),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        if (i == chaptersState.chapters.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _ChapterTile(
                          chapter: chaptersState.chapters[i],
                          mangaId: manga.mangadexId,
                          mangaTitle: manga.title,
                          mangaCoverUrl: manga.coverUrl,
                          isGuest: auth.isGuest, // <-- AJOUT
                          onTap: () => _openReader(context, chaptersState.chapters[i], manga),
                        );
                      },
                      childCount: chaptersState.chapters.length + (chaptersState.hasMore ? 1 : 0),
                    ),
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: 'Erreur: $e',
          onRetry: () => ref.refresh(mangaDetailProvider(widget.mangaId)),
        ),
      ),
    );
  }

  // <-- AJOUT : On ajoute le paramètre isGuest
  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref, Manga manga, bool isInLibrary, bool isGuest) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      ),
      actions: [
        IconButton(
          icon: Container(
            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            padding: const EdgeInsets.all(6),
            child: Icon(
              isInLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isInLibrary ? Colors.red : Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            // <-- MODIFICATION : Blocage pour les invités
            if (isGuest) {
              _showGuestDialog(context);
              return;
            }

            if (isInLibrary) {
              ref.read(libraryProvider.notifier).remove(manga.mangadexId);
              _showSnack(context, 'Retiré de la bibliothèque');
            } else {
              ref.read(libraryProvider.notifier).add(manga);
              _showSnack(context, 'Ajouté à la bibliothèque !');
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: manga.coverUrl != null
            ? CachedNetworkImage(
          imageUrl: manga.coverUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[900]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 50)
            ),
          ),
        )
            : Container(color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildReadButtons(BuildContext context, WidgetRef ref, Manga manga, List<Chapter> chapters, AsyncValue progressAsync) {
    return Column(
      children: [
        if (chapters.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openReader(context, chapters.first, manga),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('LIRE LE PREMIER CHAPITRE'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        progressAsync.when(
          data: (progress) {
            if (progress == null) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openReaderById(context, progress.chapterId, progress.chapterTitle, progress.chapterNumber, manga);
                    },
                    icon: const Icon(Icons.bookmark_rounded),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REPRENDRE LA LECTURE'),
                        Text(
                          'Ch.${progress.chapterNumber ?? '?'} — Page ${progress.lastPage}/${progress.totalPages}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _openReader(BuildContext context, Chapter chapter, Manga manga) {
    _openReaderById(context, chapter.mangadexId, chapter.title, chapter.chapterNumber, manga);
  }

  void _openReaderById(BuildContext context, String chapterId, String? title, String? number, Manga manga) {
    final q = <String, String>{
      'mangaId': manga.mangadexId,
      'mangaTitle': manga.title,
      if (manga.coverUrl != null) 'mangaCoverUrl': manga.coverUrl!,
      if (title != null) 'chapterTitle': title,
      if (number != null) 'chapterNumber': number,
    };
    final qs = q.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    context.go('/reader/$chapterId?$qs');
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // <-- AJOUT : La boîte de dialogue pour les invités
  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compte requis'),
        content: const Text('Vous êtes en mode invité. Créez un compte ou connectez-vous pour utiliser cette fonctionnalité et sauvegarder vos données.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/auth'); // Envoie vers la page de connexion
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(AppTheme.statusLabel(status)),
      backgroundColor: AppTheme.statusColor(status).withOpacity(0.2),
      side: BorderSide(color: AppTheme.statusColor(status)),
      labelStyle: TextStyle(color: AppTheme.statusColor(status), fontSize: 12),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ChapterTile extends ConsumerWidget {
  final Chapter chapter;
  final String mangaId;
  final String mangaTitle;
  final String? mangaCoverUrl;
  final bool isGuest; // <-- AJOUT
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.mangaId,
    required this.mangaTitle,
    required this.mangaCoverUrl,
    required this.isGuest, // <-- AJOUT
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadStates = ref.watch(downloadStatesProvider);
    final dlState = downloadStates[chapter.mangadexId];
    final isDownloading = dlState != null && !dlState.isComplete && !dlState.hasError;
    final isDownloaded = chapter.pageUrls.isNotEmpty &&
        chapter.pageUrls.first.startsWith('/');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: chapter.isRead ? Colors.grey[700] : AppColors.primary,
        child: Text(
          chapter.chapterNumber ?? '?',
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
      title: Text(chapter.displayTitle),
      subtitle: chapter.translatedLanguage != null
          ? Text('Langue: ${chapter.translatedLanguage}',
          style: const TextStyle(fontSize: 12))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.isRead)
            Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
          const SizedBox(width: 4),
          if (isDownloading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: dlState.progress,
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          else if (isDownloaded)
            Icon(Icons.download_done_rounded, size: 18, color: Colors.green[400])
          else
            IconButton(
              icon: const Icon(Icons.download_outlined, size: 18),
              color: Colors.grey[500],
              onPressed: () => _download(context, ref),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  void _download(BuildContext context, WidgetRef ref) {
    // <-- MODIFICATION : Blocage pour les invités
    if (isGuest) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Compte requis'),
          content: const Text('Vous êtes en mode invité. Créez un compte pour télécharger des chapitres hors-ligne.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/auth');
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
      return;
    }

    ref.read(downloadServiceProvider).downloadChapter(
      chapterId: chapter.mangadexId,
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      chapterTitle: chapter.displayTitle,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de ${chapter.displayTitle} démarré'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

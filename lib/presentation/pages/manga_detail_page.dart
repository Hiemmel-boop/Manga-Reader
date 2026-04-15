import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../providers/chapter_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/app_widgets.dart';
import '../../data/models/manga.dart';
import '../../data/models/chapter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class MangaDetailPage extends ConsumerWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(mangaDetailProvider(mangaId));
    final chaptersAsync = ref.watch(mangaChaptersProvider(mangaId));
    final isInLibrary = ref.watch(isMangaInLibraryProvider(mangaId));
    final progressAsync = ref.watch(readingProgressProvider(mangaId));

    return Scaffold(
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null) return const AppErrorWidget(message: 'Manga introuvable');
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, ref, manga, isInLibrary),
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

                      // Bouton lire
                      chaptersAsync.when(
                        data: (chapters) => _buildReadButtons(context, ref, manga, chapters, progressAsync),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chapitres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          chaptersAsync.when(
                            data: (c) => Text('${c.length} chapitres', style: TextStyle(color: Colors.grey[400])),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              chaptersAsync.when(
                data: (chapters) => chapters.isEmpty
                    ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucun chapitre disponible'),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _ChapterTile(
                      chapter: chapters[i],
                      onTap: () => _openReader(context, chapters[i], manga),
                    ),
                    childCount: chapters.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: AppErrorWidget(
                    message: 'Erreur chapitres: $e',
                    onRetry: () => ref.refresh(mangaChaptersProvider(mangaId)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: 'Erreur: $e',
          onRetry: () => ref.refresh(mangaDetailProvider(mangaId)),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref, Manga manga, bool isInLibrary) {
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
            ? CachedNetworkImage(imageUrl: manga.coverUrl!, fit: BoxFit.cover)
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

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  const _ChapterTile({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          ? Text('Langue: ${chapter.translatedLanguage}', style: const TextStyle(fontSize: 12))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.isRead)
            Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }
}
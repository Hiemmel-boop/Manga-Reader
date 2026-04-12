import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/datasources/remote/mangadex_api.dart';
import '../../../data/models/manga.dart';
import '../../../data/repositories/chapter_repository.dart';
import '../../../data/repositories/reading_progress_repository.dart';
import '../../../data/models/reading_progress.dart';
import '../../controllers/library_controller.dart';
import '../../../data/repositories/chapter_repository.dart';

final mangaDetailProvider = FutureProvider.family<Manga?, String>((ref, mangaId) async {
  final api = ref.watch(mangaDexApiProvider);
  final response = await api.getMangaDetails(mangaId);

  final json = response.data['data'];
  final attributes = json['attributes'];
  final relationships = json['relationships'] as List<dynamic>;

  String? coverFileName;
  String? authorName;

  for (final rel in relationships) {
    if (rel['type'] == 'cover_art') {
      coverFileName = rel['attributes']?['fileName'];
    }
    if (rel['type'] == 'author') {
      authorName = rel['attributes']?['name'];
    }
  }

  final manga = Manga()
    ..mangadexId = json['id']
    ..title = attributes['title']?['en'] ??
        attributes['title']?['ja'] ??
        'Sans titre'
    ..description = attributes['description']?['en']
    ..status = attributes['status']
    ..contentRating = attributes['contentRating']
    ..year = attributes['year']
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();

  if (coverFileName != null) {
    manga.coverUrl = 'https://uploads.mangadex.org/covers/${json['id']}/$coverFileName';
  }

  if (authorName != null) {
    manga.author = authorName;
  }

  final tags = attributes['tags'] as List<dynamic>? ?? [];
  manga.tags = tags.map((t) => t['attributes']?['name']?['en'] ?? '').where((s) => s.isNotEmpty).toList().cast<String>();

  return manga;
});

final mangaChaptersProvider = FutureProvider.family<List<dynamic>, String>((ref, mangaId) async {
  final repo = ref.watch(chapterRepositoryProvider);
  return await repo.getMangaChapters(mangaId);
});

final readingProgressProvider = FutureProvider.family<ReadingProgress?, String>((ref, mangaId) async {
  final repo = ref.watch(readingProgressRepositoryProvider);
  return await repo.getProgress(mangaId);
});

class MangaDetailPage extends ConsumerWidget {
  final String mangaId;

  const MangaDetailPage({
    super.key,
    required this.mangaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(mangaDetailProvider(mangaId));
    final chaptersAsync = ref.watch(mangaChaptersProvider(mangaId));
    final isInLibrary = ref.watch(isMangaInLibraryProvider(mangaId));
    final progressAsync = ref.watch(readingProgressProvider(mangaId));

    return Scaffold(
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null) {
            return const Center(child: Text('Manga non trouvé'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => context.go('/'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: manga.coverUrl != null
                      ? CachedNetworkImage(
                    imageUrl: manga.coverUrl!,
                    fit: BoxFit.cover,
                  )
                      : Container(color: Colors.grey[800]),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isInLibrary ? Icons.favorite : Icons.favorite_border,
                        color: isInLibrary ? Colors.red : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (isInLibrary) {
                        ref.read(libraryControllerProvider.notifier).removeFromLibrary(manga);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Retiré de la bibliothèque')),
                        );
                      } else {
                        ref.read(libraryControllerProvider.notifier).addToLibrary(manga);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajouté à la bibliothèque !')),
                        );
                      }
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (manga.author != null)
                        Text(
                          'Auteur: ${manga.author}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          if (manga.status != null)
                            Chip(
                              label: Text(manga.status!),
                              backgroundColor: _getStatusColor(manga.status),
                            ),
                          const SizedBox(width: 8),
                          if (manga.year != null)
                            Chip(label: Text('${manga.year}')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (manga.tags.isNotEmpty) ...[
                        const Text(
                          'Tags:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: manga.tags.map((tag) {
                            return Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (manga.description != null && manga.description!.isNotEmpty) ...[
                        const Text(
                          'Synopsis:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(manga.description!),
                        const SizedBox(height: 24),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            chaptersAsync.whenData((chapters) {
                              if (chapters.isNotEmpty) {
                                final firstChapter = chapters.first;
                                _openReader(context, firstChapter.id, firstChapter.title, manga);
                              }
                            });
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('LIRE LE PREMIER CHAPITRE'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      progressAsync.when(
                        data: (progress) {
                          if (progress != null) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final queryParams = {
                                        'mangaId': manga.mangadexId,
                                        'mangaTitle': manga.title,
                                        if (manga.coverUrl != null) 'mangaCoverUrl': manga.coverUrl!,
                                        if (progress.chapterTitle != null) 'chapterTitle': progress.chapterTitle!,
                                      };

                                      final queryString = queryParams.entries
                                          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
                                          .join('&');

                                      context.go('/reader/${progress.chapterId}?$queryString');
                                    },
                                    icon: const Icon(Icons.bookmark),
                                    label: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('REPRENDRE LA LECTURE'),
                                        Text(
                                          'Ch. ${progress.chapterTitle ?? '?'} - Page ${progress.lastPage}/${progress.totalPages}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: Colors.orange[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chapitres:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chaptersAsync.when(
                            data: (chapters) => Text(
                              '${chapters.length} chapitres',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              chaptersAsync.when(
                data: (chapters) {
                  if (chapters.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Aucun chapitre disponible'),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final chapter = chapters[index];
                        return _ChapterTile(
                          chapter: chapter,
                          manga: manga,
                          onTap: () => _openReader(context, chapter.id, chapter.title, manga),
                        );
                      },
                      childCount: chapters.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Erreur chapitres: $error'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(mangaDetailProvider(mangaId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReader(BuildContext context, String chapterId, String? chapterTitle, Manga manga) {
    final queryParams = {
      'mangaId': manga.mangadexId,
      'mangaTitle': manga.title,
      if (manga.coverUrl != null) 'mangaCoverUrl': manga.coverUrl!,
      if (chapterTitle != null) 'chapterTitle': chapterTitle,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    context.go('/reader/$chapterId?$queryString');
  }

  Color? _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green[800];
      case 'ongoing':
        return Colors.blue[800];
      case 'hiatus':
        return Colors.orange[800];
      case 'cancelled':
        return Colors.red[800];
      default:
        return Colors.grey[800];
    }
  }
}

class _ChapterTile extends StatelessWidget {
  final dynamic chapter;
  final Manga manga;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.manga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chapterNum = chapter.chapterNumber ?? '?';
    final title = chapter.title ?? 'Chapitre $chapterNum';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF6C63FF),
        child: Text(
          '$chapterNum',
          style: const TextStyle(fontSize: 12),
        ),
      ),
      title: Text(title),
      subtitle: chapter.translatedLanguage != null
          ? Text('Langue: ${chapter.translatedLanguage}')
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
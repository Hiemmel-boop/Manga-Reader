import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../data/repositories/chapter_repository.dart';
import '../../../data/repositories/reading_progress_repository.dart';
import '../../../data/models/reading_progress.dart';
import '../../controllers/history_controller.dart';
import '../../../data/repositories/chapter_repository.dart';

final chapterPagesProvider = FutureProvider.family<List<String>, String>((ref, chapterId) async {
  final repo = ref.watch(chapterRepositoryProvider);
  return await repo.getChapterPages(chapterId);
});

class ReaderPage extends ConsumerStatefulWidget {
  final String chapterId;
  final String? mangaId;
  final String? mangaTitle;
  final String? mangaCoverUrl;
  final String? chapterTitle;

  const ReaderPage({
    super.key,
    required this.chapterId,
    this.mangaId,
    this.mangaTitle,
    this.mangaCoverUrl,
    this.chapterTitle,
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  int currentPage = 0;
  bool showControls = true;
  bool isVertical = false;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    if (widget.mangaId != null && widget.mangaTitle != null) {
      _saveProgress(1);
    }
  }

  @override
  void didUpdateWidget(ReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId) {
      setState(() {
        currentPage = 0;
      });
      _pageController?.dispose();
      _pageController = null;
      if (widget.mangaId != null && widget.mangaTitle != null) {
        _saveProgress(1);
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _saveProgress(int totalPages) {
    if (widget.mangaId == null || widget.mangaTitle == null) return;

    ref.read(historyControllerProvider.notifier).addToHistory(
      mangaId: widget.mangaId!,
      chapterId: widget.chapterId,
      mangaTitle: widget.mangaTitle!,
      mangaCoverUrl: widget.mangaCoverUrl,
      chapterTitle: widget.chapterTitle,
      lastPage: currentPage + 1,
    );

    final progress = ReadingProgress(
      mangaId: widget.mangaId!,
      chapterId: widget.chapterId,
      mangaTitle: widget.mangaTitle!,
      mangaCoverUrl: widget.mangaCoverUrl,
      chapterTitle: widget.chapterTitle,
      lastPage: currentPage + 1,
      totalPages: totalPages,
      updatedAt: DateTime.now(),
    );

    ref.read(readingProgressRepositoryProvider).saveProgress(progress);
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(chapterPagesProvider(widget.chapterId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: pagesAsync.when(
        data: (pages) {
          if (pages.isEmpty) {
            return const Center(
              child: Text('Aucune page trouvée', style: TextStyle(color: Colors.white)),
            );
          }

          final validPage = currentPage.clamp(0, pages.length - 1);
          if (validPage != currentPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => currentPage = validPage);
            });
          }

          return Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() => showControls = !showControls),
                child: isVertical
                    ? _buildVerticalReader(pages)
                    : _buildHorizontalReader(pages),
              ),

              if (showControls) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black54,
                    leading: IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    title: Text('Page ${currentPage + 1} / ${pages.length}'),
                    actions: [
                      IconButton(
                        icon: Icon(isVertical ? Icons.horizontal_split : Icons.vertical_split),
                        onPressed: () => setState(() => isVertical = !isVertical),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => _showReaderSettings(context),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Slider(
                          value: currentPage.toDouble().clamp(0, pages.length - 1),
                          min: 0,
                          max: (pages.length - 1).toDouble(),
                          onChanged: (value) {
                            final newPage = value.toInt().clamp(0, pages.length - 1);
                            setState(() => currentPage = newPage);
                            _pageController?.jumpToPage(newPage);
                            _saveProgress(pages.length);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: currentPage > 0
                                  ? () {
                                final newPage = (currentPage - 1).clamp(0, pages.length - 1);
                                setState(() => currentPage = newPage);
                                _pageController?.jumpToPage(newPage);
                                _saveProgress(pages.length);
                              }
                                  : null,
                            ),
                            Text(
                              '${currentPage + 1} / ${pages.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next, color: Colors.white),
                              onPressed: currentPage < pages.length - 1
                                  ? () {
                                final newPage = (currentPage + 1).clamp(0, pages.length - 1);
                                setState(() => currentPage = newPage);
                                _pageController?.jumpToPage(newPage);
                                _saveProgress(pages.length);
                              }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              Text('Erreur: $error', style: const TextStyle(color: Colors.white)),
              ElevatedButton(
                onPressed: () => ref.refresh(chapterPagesProvider(widget.chapterId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalReader(List<String> pages) {
    _pageController ??= PageController(initialPage: currentPage.clamp(0, pages.length - 1));

    if (_pageController!.hasClients && _pageController!.page?.round() != currentPage) {
      _pageController!.jumpToPage(currentPage.clamp(0, pages.length - 1));
    }

    return PhotoViewGallery.builder(
      itemCount: pages.length,
      pageController: _pageController,
      onPageChanged: (index) {
        final validIndex = index.clamp(0, pages.length - 1);
        setState(() => currentPage = validIndex);
        _saveProgress(pages.length);
      },
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(pages[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildVerticalReader(List<String> pages) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          final page = (metrics.pixels / metrics.viewportDimension).round().clamp(0, pages.length - 1);
          if (page != currentPage) {
            setState(() => currentPage = page);
            _saveProgress(pages.length);
          }
        }
        return false;
      },
      child: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return Image.network(
            pages[index],
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 400,
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              height: 400,
              color: Colors.grey[900],
              child: const Icon(Icons.broken_image, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paramètres du lecteur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.screen_rotation),
                title: const Text('Direction de lecture'),
                subtitle: Text(isVertical ? 'Verticale' : 'Horizontale'),
                onTap: () {
                  setState(() => isVertical = !isVertical);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Luminosité'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Télécharger ce chapitre'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
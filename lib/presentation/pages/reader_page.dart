import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../providers/chapter_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../../data/repositories/reading_progress_repository.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String chapterId;
  final String? mangaId;
  final String? mangaTitle;
  final String? mangaCoverUrl;
  final String? chapterTitle;
  final String? chapterNumber;

  const ReaderPage({
    super.key,
    required this.chapterId,
    this.mangaId,
    this.mangaTitle,
    this.mangaCoverUrl,
    this.chapterTitle,
    this.chapterNumber,
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  int _currentPage = 0;
  bool _showControls = true;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveProgress(1));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _saveProgress(int totalPages) {
    if (widget.mangaId == null || widget.mangaTitle == null) return;

    ref.read(historyProvider.notifier).add(
      mangaId: widget.mangaId!,
      chapterId: widget.chapterId,
      mangaTitle: widget.mangaTitle!,
      mangaCoverUrl: widget.mangaCoverUrl,
      chapterTitle: widget.chapterTitle,
      chapterNumber: widget.chapterNumber,
      lastPage: _currentPage + 1,
    );

    ref.read(readingProgressRepositoryProvider).saveProgress(
      mangaId: widget.mangaId!,
      chapterId: widget.chapterId,
      mangaTitle: widget.mangaTitle!,
      mangaCoverUrl: widget.mangaCoverUrl,
      chapterTitle: widget.chapterTitle,
      chapterNumber: widget.chapterNumber,
      lastPage: _currentPage + 1,
      totalPages: totalPages,
    );
  }

  Color _bgColor(String theme) {
    return switch (theme) {
      AppConstants.readerThemeLight => Colors.white,
      AppConstants.readerThemeSepia => AppColors.sepiaBg,
      _ => Colors.black,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(chapterPagesProvider(widget.chapterId));
    final readerPrefs = ref.watch(readerPreferencesProvider);
    final readerTheme = ref.watch(readerThemeProvider);
    final bg = _bgColor(readerTheme);

    return Scaffold(
      backgroundColor: bg,
      body: pagesAsync.when(
        data: (pages) {
          if (pages.isEmpty) {
            return const Center(child: Text('Aucune page trouvée', style: TextStyle(color: Colors.white)));
          }

          _pageController ??= PageController(initialPage: _currentPage.clamp(0, pages.length - 1));

          return Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                child: readerPrefs.isVertical
                    ? _buildVertical(pages, bg)
                    : _buildHorizontal(pages, bg),
              ),
              if (_showControls) ...[
                _buildTopBar(context, pages, readerPrefs),
                _buildBottomBar(context, pages),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
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

  Widget _buildHorizontal(List<String> pages, Color bg) {
    return PhotoViewGallery.builder(
      itemCount: pages.length,
      pageController: _pageController,
      onPageChanged: (i) {
        setState(() => _currentPage = i);
        _saveProgress(pages.length);
      },
      builder: (_, i) => PhotoViewGalleryPageOptions(
        imageProvider: NetworkImage(pages[i]),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.5,
      ),
      backgroundDecoration: BoxDecoration(color: bg),
    );
  }

  Widget _buildVertical(List<String> pages, Color bg) {
    return Container(
      color: bg,
      child: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (_, i) => Image.network(
          pages[i],
          fit: BoxFit.fitWidth,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 400,
              color: Colors.grey[900],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 400,
            color: Colors.grey[900],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, List<String> pages, ReaderPreferences prefs) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : context.go('/'),
            ),
            title: Text(
              widget.chapterTitle ?? 'Chapitre ${widget.chapterNumber ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            actions: [
              IconButton(
                icon: Icon(prefs.isVertical ? Icons.swap_horiz : Icons.swap_vert, color: Colors.white),
                onPressed: () => ref.read(readerPreferencesProvider.notifier).toggleDirection(),
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined, color: Colors.white),
                onPressed: () => _showThemeSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<String> pages) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('${_currentPage + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _currentPage.toDouble().clamp(0, pages.length - 1),
                    min: 0,
                    max: (pages.length - 1).toDouble(),
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      final p = v.toInt().clamp(0, pages.length - 1);
                      setState(() => _currentPage = p);
                      _pageController?.jumpToPage(p);
                      _saveProgress(pages.length);
                    },
                  ),
                ),
                Text('${pages.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                  onPressed: _currentPage > 0 ? () {
                    final p = _currentPage - 1;
                    setState(() => _currentPage = p);
                    _pageController?.jumpToPage(p);
                    _saveProgress(pages.length);
                  } : null,
                ),
                Text('${_currentPage + 1} / ${pages.length}', style: const TextStyle(color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: _currentPage < pages.length - 1 ? () {
                    final p = _currentPage + 1;
                    setState(() => _currentPage = p);
                    _pageController?.jumpToPage(p);
                    _saveProgress(pages.length);
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thème du lecteur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ThemeButton(label: 'Sombre', color: Colors.black, textColor: Colors.white, theme: AppConstants.readerThemeDark),
                  _ThemeButton(label: 'Sépia', color: AppColors.sepiaBg, textColor: AppColors.sepiaText, theme: AppConstants.readerThemeSepia),
                  _ThemeButton(label: 'Clair', color: Colors.white, textColor: Colors.black87, theme: AppConstants.readerThemeLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends ConsumerWidget {
  final String label;
  final Color color;
  final Color textColor;
  final String theme;

  const _ThemeButton({required this.label, required this.color, required this.textColor, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(readerThemeProvider);
    final isSelected = current == theme;

    return GestureDetector(
      onTap: () {
        ref.read(readerThemeProvider.notifier).setTheme(theme);
        Navigator.pop(context);
      },
      child: Container(
        width: 90,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[700]!,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}
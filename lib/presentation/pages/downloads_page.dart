import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../services/download_service.dart'; // <-- L'IMPORT MANQUANT EST LÀ
import '../../config/theme.dart';
import '../../config/constants.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadStatesProvider);

    final activeDownloads = downloads.values.where((d) => !d.isComplete && !d.hasError).toList();
    final completedDownloads = downloads.values.where((d) => d.isComplete).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: downloads.isEmpty
          ? const Center(child: Text('Aucun téléchargement en cours ou terminé.'))
          : ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (activeDownloads.isNotEmpty) ...[
            const Text('En cours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            ...activeDownloads.map((d) => _DownloadTile(state: d)),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (completedDownloads.isNotEmpty) ...[
            const Text('Terminés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            ...completedDownloads.map((d) => _DownloadTile(
              state: d,
              onDelete: () async {
                await ref.read(downloadServiceProvider).deleteDownload(d.chapterId);
                ref.read(downloadStatesProvider.notifier).remove(d.chapterId);
              },
            )),
          ]
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final DownloadState state;
  final VoidCallback? onDelete;

  const _DownloadTile({required this.state, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(state.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.chapterTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: AppSpacing.xs),
            if (state.hasError)
              const Text('Erreur lors du téléchargement', style: TextStyle(color: Colors.red, fontSize: 12))
            else if (state.isComplete)
              const Text('Téléchargé', style: TextStyle(color: Colors.green, fontSize: 12))
            else
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.grey[800],
                color: AppColors.primary,
              ),
          ],
        ),
        trailing: state.isComplete
            ? IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        )
            : state.hasError
            ? const Icon(Icons.error_outline, color: Colors.red)
            : Text('${(state.progress * 100).round()}%'),
      ),
    );
  }
}
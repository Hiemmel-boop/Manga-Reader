import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/history_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de lecture'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _showClearDialog(context, ref),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 72, color: Colors.grey[600]),
            const SizedBox(height: AppSpacing.md),
            Text('Aucun historique', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: AppSpacing.sm),
            Text('Lisez un manga pour commencer', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (_, i) {
          final item = history[i];
          return Dismissible(
            key: Key('history-${item.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.md),
              color: AppColors.error,
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            onDismissed: (_) => ref.read(historyProvider.notifier).load(),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: item.mangaCoverUrl != null
                    ? CachedNetworkImage(
                  imageUrl: item.mangaCoverUrl!,
                  width: 46,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(width: 46, height: 64, color: Colors.grey[800], child: const Icon(Icons.book, size: 20)),
                )
                    : Container(width: 46, height: 64, color: Colors.grey[800], child: const Icon(Icons.book, size: 20)),
              ),
              title: Text(item.mangaTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.chapterTitle ?? (item.chapterNumber != null ? 'Chapitre ${item.chapterNumber}' : 'Chapitre'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  if (item.lastPage != null)
                    Text('Page ${item.lastPage}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
              trailing: Text(
                _formatDate(item.readAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              onTap: () => context.go('/reader/${item.chapterId}'),
            ),
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: const Text('Effacer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }
}
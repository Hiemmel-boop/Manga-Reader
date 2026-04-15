import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/manga_provider.dart';
import '../providers/history_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final library = ref.watch(libraryProvider);
    final history = ref.watch(historyProvider);

    final totalChapters = history.length;
    final estimatedHours = (totalChapters * 0.5).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () => context.go('/settings')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),

            // Avatar
            CircleAvatar(
              radius: 56,
              backgroundColor: AppColors.primary,
              child: Text(
                auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              auth.displayName.isNotEmpty ? auth.displayName : 'Invité',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            if (auth.isGuest)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Chip(
                  label: const Text('Mode Invité'),
                  backgroundColor: Colors.grey[800],
                  visualDensity: VisualDensity.compact,
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Text('Statistiques', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(value: '${library.length}', label: 'Mangas', icon: Icons.book_rounded),
                        _StatItem(value: '$totalChapters', label: 'Chapitres', icon: Icons.menu_book_rounded),
                        _StatItem(value: '${estimatedHours}h', label: 'Temps', icon: Icons.access_time_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Menu
            _MenuCard(icon: Icons.history_rounded, title: 'Historique de lecture',
                subtitle: '$totalChapters chapitre(s) lu(s)', onTap: () => context.go('/history')),
            _MenuCard(icon: Icons.favorite_rounded, title: 'Ma Bibliothèque',
                subtitle: '${library.length} manga(s) sauvegardé(s)', onTap: () => context.go('/library')),
            _MenuCard(icon: Icons.settings_rounded, title: 'Paramètres',
                subtitle: 'Thème, compte, préférences', onTap: () => context.go('/settings')),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 26),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
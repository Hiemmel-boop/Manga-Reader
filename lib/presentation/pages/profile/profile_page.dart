import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/auth_controller.dart';

// Provider local pour les stats (pas besoin du repository)
final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final library = ref.watch(libraryControllerProvider);
  final history = ref.watch(historyControllerProvider);

  final totalManga = library.length;
  final totalChaptersRead = history.length;
  final estimatedHours = (totalChaptersRead * 0.5).round(); // Estimation: 30min par chapitre

  return {
    'totalManga': totalManga,
    'totalChapters': totalChaptersRead,
    'estimatedHours': estimatedHours,
  };
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final authState = ref.watch(authControllerProvider);
    final libraryCount = ref.watch(libraryControllerProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                (authState.username ?? 'Invité')[0].toUpperCase(),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authState.username ?? 'Invité',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (authState.isGuest)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: const Text('Mode Invité'),
                  backgroundColor: Colors.grey[800],
                ),
              ),

            const SizedBox(height: 32),

            statsAsync.when(
              data: (stats) => _buildStatsGrid(stats),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Erreur chargement stats'),
            ),

            const SizedBox(height: 32),

            _buildMenuCard(
              icon: Icons.history,
              title: 'Historique de lecture',
              subtitle: 'Voir les chapitres récents',
              onTap: () => context.go('/history'),
            ),
            _buildMenuCard(
              icon: Icons.favorite,
              title: 'Ma Bibliothèque',
              subtitle: '$libraryCount manga(s) sauvegardé(s)',
              onTap: () => context.go('/library'),
            ),
            _buildMenuCard(
              icon: Icons.settings,
              title: 'Paramètres',
              subtitle: 'Thème, compte, confidentialité',
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Statistiques de lecture',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: stats['totalManga'].toString(),
                  label: 'Mangas',
                  icon: Icons.book,
                ),
                _StatItem(
                  value: stats['totalChapters'].toString(),
                  label: 'Chapitres',
                  icon: Icons.menu_book,
                ),
                _StatItem(
                  value: '${stats['estimatedHours']}h',
                  label: 'Temps',
                  icon: Icons.access_time,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _quitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter ?'),
        content: const Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Fonctionne sur toutes les plateformes desktop
              exit(0);
            },
            child: const Text('Quitter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Apparence',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF6C63FF)),
            title: const Text('Mode sombre'),
            subtitle: Text(isDark ? 'Activé' : 'Désactivé'),
            value: isDark,
            onChanged: (_) => ref.read(themeControllerProvider.notifier).toggleTheme(),
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'Compte',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Déconnexion'),
            subtitle: const Text('Se déconnecter de l\'application'),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/auth');
            },
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'Application',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Quitter l\'application', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Fermer complètement l\'app'),
            onTap: () => _quitApp(context),
          ),
          const Divider(),

          const ListTile(
            title: Text(
              'À propos',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
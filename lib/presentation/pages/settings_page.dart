import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chapter_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../data/local/preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider.notifier).currentThemeName;
    final readerTheme = ref.watch(readerThemeProvider);
    final readerPrefs = ref.watch(readerPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
      ),
      body: ListView(
        children: [
          _Section(label: 'Apparence'),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
            title: const Text('Thème de l\'application'),
            subtitle: Text(_appThemeLabel(currentTheme)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showAppThemeDialog(context, ref, currentTheme),
          ),
          const Divider(),

          _Section(label: 'Lecteur'),
          SwitchListTile(
            secondary: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
            title: const Text('Lecture verticale'),
            subtitle: const Text('Défilement de haut en bas'),
            value: readerPrefs.isVertical,
            onChanged: (_) => ref.read(readerPreferencesProvider.notifier).toggleDirection(),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined, color: AppColors.primary),
            title: const Text('Thème du lecteur'),
            subtitle: Text(_readerThemeLabel(readerTheme)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showReaderThemeDialog(context, ref, readerTheme),
          ),
          const Divider(),

          _Section(label: 'Langue'),
          _LanguageTile(ref: ref),
          const Divider(),

          _Section(label: 'Compte'),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.orange),
            title: const Text('Déconnexion'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth');
            },
          ),
          const Divider(),

          _Section(label: 'Application'),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded, color: AppColors.error),
            title: const Text('Quitter', style: TextStyle(color: AppColors.error)),
            onTap: () => _showQuitDialog(context),
          ),
          const Divider(),

          _Section(label: 'À propos'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _appThemeLabel(String theme) {
    return switch (theme) {
      AppConstants.themeLight => 'Clair',
      AppConstants.themeDracula => 'Dracula',
      AppConstants.themeAyuDark => 'Ayu Dark',
      _ => 'Sombre',
    };
  }

  String _readerThemeLabel(String theme) {
    return switch (theme) {
      AppConstants.readerThemeLight => 'Clair',
      AppConstants.readerThemeSepia => 'Sépia',
      _ => 'Sombre',
    };
  }

  void _showAppThemeDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Thème de l\'application'),
        children: [
          _ThemeOption(label: 'Sombre', color: AppColors.primary, value: AppConstants.themeDark, current: current, ref: ref, ctx: ctx),
          _ThemeOption(label: 'Clair', color: Colors.blueGrey, value: AppConstants.themeLight, current: current, ref: ref, ctx: ctx),
          _ThemeOption(label: 'Dracula', color: const Color(0xFFBD93F9), value: AppConstants.themeDracula, current: current, ref: ref, ctx: ctx),
          _ThemeOption(label: 'Ayu Dark', color: const Color(0xFFFFB454), value: AppConstants.themeAyuDark, current: current, ref: ref, ctx: ctx),
        ],
      ),
    );
  }

  void _showReaderThemeDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Thème du lecteur'),
        children: [
          _ThemeOption(label: 'Sombre', color: Colors.black, value: AppConstants.readerThemeDark, current: current, ref: ref, ctx: ctx),
          _ThemeOption(label: 'Sépia', color: AppColors.sepiaBg, value: AppConstants.readerThemeSepia, current: current, ref: ref, ctx: ctx),
          _ThemeOption(label: 'Clair', color: Colors.white, value: AppConstants.readerThemeLight, current: current, ref: ref, ctx: ctx),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter ?'),
        content: const Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(onPressed: () => exit(0), child: const Text('Quitter', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[500], fontSize: 12)),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final Color color;
  final String value;
  final String current;
  final WidgetRef ref;
  final BuildContext ctx;

  const _ThemeOption({required this.label, required this.color, required this.value, required this.current, required this.ref, required this.ctx});

  @override
  Widget build(BuildContext context) {
    // On vérifie si c'est le thème de l'app ou du lecteur pour appeler la bonne fonction
    final isAppTheme = [AppConstants.themeDark, AppConstants.themeLight, AppConstants.themeDracula, AppConstants.themeAyuDark].contains(value);

    return SimpleDialogOption(
      onPressed: () {
        if (isAppTheme) {
          ref.read(themeProvider.notifier).setTheme(value);
        } else {
          ref.read(readerThemeProvider.notifier).setTheme(value);
        }
        Navigator.pop(ctx);
      },
      child: Row(
        children: [
          Icon(current == value ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: current == value ? AppColors.primary : Colors.grey),
          const SizedBox(width: AppSpacing.md),
          CircleAvatar(backgroundColor: color, radius: 8),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final WidgetRef ref;
  const _LanguageTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(preferencesProvider).getDefaultLanguage(),
      builder: (_, snap) {
        final lang = snap.data ?? 'fr';
        final label = AppConstants.availableLanguages.firstWhere((l) => l['code'] == lang, orElse: () => {'label': lang})['label']!;

        return ListTile(
          leading: const Icon(Icons.language_rounded, color: AppColors.primary),
          title: const Text('Langue de lecture'),
          subtitle: Text(label),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          onTap: () => _showLanguageDialog(context, ref, lang),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Langue de lecture'),
        children: AppConstants.availableLanguages.map((lang) => SimpleDialogOption(
          onPressed: () async {
            await ref.read(preferencesProvider).setDefaultLanguage(lang['code']!);
            // TRÈS IMPORTANT : On invalide les chapitres pour qu'ils rechargent dans la nouvelle langue !
            ref.invalidate(mangaChaptersProvider);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Row(
            children: [
              Icon(current == lang['code'] ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: current == lang['code'] ? AppColors.primary : Colors.grey),
              const SizedBox(width: AppSpacing.md),
              Text(lang['label']!),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/database.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Isar avant tout
  final isar = await initIsar();

  // Initialiser les notifications
  await NotificationService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Isar injecté une seule fois — accessible partout via isarProvider
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'data/local/database.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Isar une seule fois — injecté partout via override
  final isar = await initIsar();

  // Initialiser les notifications (no-op sur Linux/Web)
  await NotificationService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Vérification au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-vérifier quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      _checkIfNeeded();
    }
  }

  Future<void> _checkIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckStr = prefs.getString('last_check_date');
      bool shouldCheck = true;

      if (lastCheckStr != null) {
        final lastCheck = DateTime.tryParse(lastCheckStr);
        if (lastCheck != null) {
          shouldCheck = DateTime.now().difference(lastCheck).inHours >= 24;
        }
      }

      if (shouldCheck) {
        // On récupère le container via le context du widget
        final container = ProviderScope.containerOf(context);
        await ref.read(notificationServiceProvider).checkNewChapters(container);
      }
    } catch (_) {
      // Non critique — silencieux
    }
  }

  @override
  Widget build(BuildContext context) {
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
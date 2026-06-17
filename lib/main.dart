import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NOUVEL IMPORT
import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation de Sqflite pour Linux/Windows
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Initialisation de Supabase (C'EST ICI QU'ON MET LES CLES)
  await Supabase.initialize(
    url: 'https://shhggnwktpymghxtklcq.supabase.co', // Ex: https://xyzabc.supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNoaGdnbndrdHB5bWdoeHRrbGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NDI1NjAsImV4cCI6MjA5NzAxODU2MH0._vCA2e5W13XD9ruyPTykfZK0U7vZFMCJeeWrX8lGWhM', // La très longue clé qui commence par eyJ...
  );

  // 3. Initialiser les notifications (Mode fantôme)
  await NotificationService().initialize();

  // 4. Lancement de l'application
  runApp(const ProviderScope(child: MyApp()));
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
        final container = ProviderScope.containerOf(context);
        await ref.read(notificationServiceProvider).checkNewChapters(container);
      }
    } catch (_) {
      // Non critique — silencieux
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeProvider); // On récupère le ThemeData directement

    return MaterialApp.router(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: theme, // On applique le thème choisi (Sombre, Dracula, etc.)
      routerConfig: router,
    );
  }
}
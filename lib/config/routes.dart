import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/auth_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/manga_detail_page.dart';
import '../presentation/pages/reader_page.dart';
import '../presentation/pages/library_page.dart';
import '../presentation/pages/search_page.dart';
import '../presentation/pages/advanced_search_page.dart';
import '../presentation/pages/history_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isGuest = authState.isGuest;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;

      if (!isAuthenticated && !isGuest && loc != '/auth') {
        return '/auth';
      }

      if ((isAuthenticated || isGuest) && loc == '/auth') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(
        path: '/manga/:id',
        builder: (_, state) => MangaDetailPage(
          mangaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/reader/:chapterId',
        builder: (_, state) {
          final q = state.uri.queryParameters;
          return ReaderPage(
            chapterId: state.pathParameters['chapterId']!,
            mangaId: q['mangaId'],
            mangaTitle: q['mangaTitle'],
            mangaCoverUrl: q['mangaCoverUrl'],
            chapterTitle: q['chapterTitle'],
            chapterNumber: q['chapterNumber'],
          );
        },
      ),
      GoRoute(path: '/library', builder: (_, __) => const LibraryPage()),
      GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
      GoRoute(path: '/advanced-search', builder: (_, __) => const AdvancedSearchPage()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page non trouvée: ${state.matchedLocation}')),
    ),
  );
});
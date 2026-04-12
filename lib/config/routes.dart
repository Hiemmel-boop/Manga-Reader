import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/manga_detail/manga_detail_page.dart';
import '../presentation/pages/reader/reader_page.dart';
import '../presentation/pages/library/library_page.dart';
import '../presentation/pages/search/search_page.dart';
import '../presentation/pages/search/advanced_search_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/auth/auth_page.dart';
import '../presentation/pages/history/history_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/controllers/auth_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isGuest = authState.isGuest;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isSplashRoute = state.matchedLocation == '/splash';

      if (isSplashRoute) return null;

      if (!isAuthenticated && !isGuest && !isAuthRoute) {
        return '/auth';
      }

      if ((isAuthenticated || isGuest) && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/manga/:id',
        builder: (context, state) => MangaDetailPage(
          mangaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/reader/:chapterId',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return ReaderPage(
            chapterId: state.pathParameters['chapterId']!,
            mangaId: queryParams['mangaId'],
            mangaTitle: queryParams['mangaTitle'],
            mangaCoverUrl: queryParams['mangaCoverUrl'],
            chapterTitle: queryParams['chapterTitle'],
          );
        },
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/advanced-search',
        builder: (context, state) => const AdvancedSearchPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée: ${state.matchedLocation}'),
      ),
    ),
  );
});
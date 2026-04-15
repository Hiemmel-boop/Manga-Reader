class AppConstants {
  // API MangaDex
  static const String mangadexBaseUrl = 'https://api.mangadex.org';
  static const String mangadexCoverUrl = 'https://uploads.mangadex.org/covers';

  // Pagination
  static const int defaultPageLimit = 20;
  static const int chapterPageLimit = 100;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Reader
  static const double defaultReaderPadding = 8.0;
  static const Duration pageTurnAnimation = Duration(milliseconds: 300);

  // Base de données
  static const String dbName = 'manga_reader_db';

  // Préférences
  static const String prefDarkMode = 'dark_mode';
  static const String prefVerticalReader = 'vertical_reader';
  static const String prefReaderZoom = 'reader_zoom';
  static const String prefDefaultLanguage = 'default_language';
  static const String prefReaderTheme = 'reader_theme';
  static const String prefCurrentUserId = 'current_user_id';

  // Langues disponibles
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'fr', 'label': 'Français'},
    {'code': 'en', 'label': 'English'},
    {'code': 'ja', 'label': '日本語'},
    {'code': 'es', 'label': 'Español'},
    {'code': 'pt-br', 'label': 'Português'},
    {'code': 'ko', 'label': '한국어'},
    {'code': 'zh', 'label': '中文'},
  ];

  // Thèmes lecteur
  static const String readerThemeDark = 'dark';
  static const String readerThemeLight = 'light';
  static const String readerThemeSepia = 'sepia';
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double card = 16.0;
  static const double button = 12.0;
  static const double chip = 20.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
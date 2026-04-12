class AppConstants {
  // API MangaDex
  static const String mangadexBaseUrl = 'https://api.mangadex.org';
  static const String mangadexCoverUrl = 'https://uploads.mangadex.org/covers';

  // Pagination
  static const int defaultPageLimit = 20;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);

  // Reader
  static const double defaultReaderPadding = 8.0;
  static const Duration pageTurnAnimation = Duration(milliseconds: 300);
}
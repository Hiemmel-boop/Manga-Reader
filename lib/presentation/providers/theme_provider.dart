import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/preferences.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

// On retourne maintenant un ThemeData directement utilisable par MaterialApp
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier(ref.watch(preferencesProvider));
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  final Preferences _prefs;
  String _currentThemeName = AppConstants.themeDark;

  ThemeNotifier(this._prefs) : super(AppTheme.darkTheme) {
    _load();
  }

  String get currentThemeName => _currentThemeName;

  Future<void> _load() async {
    _currentThemeName = await _prefs.getThemeName();
    state = _getThemeData(_currentThemeName);
  }

  Future<void> setTheme(String themeName) async {
    await _prefs.setThemeName(themeName);
    _currentThemeName = themeName;
    state = _getThemeData(themeName);
  }

  ThemeData _getThemeData(String themeName) {
    switch (themeName) {
      case AppConstants.themeLight: return AppTheme.lightTheme;
      case AppConstants.themeDracula: return AppTheme.draculaTheme;
      case AppConstants.themeAyuDark: return AppTheme.ayuDarkTheme;
      default: return AppTheme.darkTheme;
    }
  }
}


final readerThemeProvider = StateNotifierProvider<ReaderThemeNotifier, String>((ref) {
  return ReaderThemeNotifier(ref.watch(preferencesProvider));
});

class ReaderThemeNotifier extends StateNotifier<String> {
  final Preferences _prefs;
  ReaderThemeNotifier(this._prefs) : super(AppConstants.readerThemeDark) {
    _load();
  }
  Future<void> _load() async {
    state = await _prefs.getReaderTheme();
  }
  Future<void> setTheme(String theme) async {
    await _prefs.setReaderTheme(theme);
    state = theme;
  }
}

class ReaderPreferences {
  final bool isVertical;
  final double zoom;
  const ReaderPreferences({this.isVertical = false, this.zoom = 1.0});
  ReaderPreferences copyWith({bool? isVertical, double? zoom}) {
    return ReaderPreferences(isVertical: isVertical ?? this.isVertical, zoom: zoom ?? this.zoom);
  }
}

final readerPreferencesProvider = StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>((ref) {
  return ReaderPreferencesNotifier(ref.watch(preferencesProvider));
});

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferences> {
  final Preferences _prefs;
  ReaderPreferencesNotifier(this._prefs) : super(const ReaderPreferences()) {
    _load();
  }
  Future<void> _load() async {
    final isVertical = await _prefs.getUseVerticalReader();
    final zoom = await _prefs.getReaderZoom();
    state = ReaderPreferences(isVertical: isVertical, zoom: zoom);
  }
  Future<void> toggleDirection() async {
    await _prefs.setUseVerticalReader(!state.isVertical);
    state = state.copyWith(isVertical: !state.isVertical);
  }
  Future<void> setZoom(double zoom) async {
    await _prefs.setReaderZoom(zoom);
    state = state.copyWith(zoom: zoom);
  }
}
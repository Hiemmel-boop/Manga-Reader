import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/preferences.dart';

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(preferencesProvider));
});

class ThemeController extends StateNotifier<ThemeMode> {
  final Preferences _prefs;

  ThemeController(this._prefs) : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await _prefs.init();
    final isDark = await _prefs.getDarkMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    await _prefs.setDarkMode(!isDark);
    state = !isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setDarkMode(value);
    state = value ? ThemeMode.dark : ThemeMode.light;
  }
}
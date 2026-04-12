import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesProvider = Provider<Preferences>((ref) {
  return Preferences();
});

class Preferences {
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Thème
  Future<bool> getDarkMode() async {
    await init();
    return _prefs?.getBool('dark_mode') ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    await init();
    await _prefs?.setBool('dark_mode', value);
  }

  // Lecture
  Future<bool> getUseVerticalReader() async {
    await init();
    return _prefs?.getBool('vertical_reader') ?? false;
  }

  Future<void> setUseVerticalReader(bool value) async {
    await init();
    await _prefs?.setBool('vertical_reader', value);
  }

  Future<double> getReaderZoom() async {
    await init();
    return _prefs?.getDouble('reader_zoom') ?? 1.0;
  }

  Future<void> setReaderZoom(double value) async {
    await init();
    await _prefs?.setDouble('reader_zoom', value);
  }

  // Langue
  Future<String?> getDefaultLanguage() async {
    await init();
    return _prefs?.getString('default_language') ?? 'fr';
  }

  Future<void> setDefaultLanguage(String value) async {
    await init();
    await _prefs?.setString('default_language', value);
  }

  // Réinitialiser
  Future<void> clear() async {
    await init();
    await _prefs?.clear();
  }
}
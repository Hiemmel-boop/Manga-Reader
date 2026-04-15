import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';

final preferencesProvider = Provider<Preferences>((ref) => Preferences._instance);

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
    return _prefs?.getBool(AppConstants.prefDarkMode) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    await init();
    await _prefs?.setBool(AppConstants.prefDarkMode, value);
  }

  // Lecteur
  Future<bool> getUseVerticalReader() async {
    await init();
    return _prefs?.getBool(AppConstants.prefVerticalReader) ?? false;
  }

  Future<void> setUseVerticalReader(bool value) async {
    await init();
    await _prefs?.setBool(AppConstants.prefVerticalReader, value);
  }

  Future<double> getReaderZoom() async {
    await init();
    return _prefs?.getDouble(AppConstants.prefReaderZoom) ?? 1.0;
  }

  Future<void> setReaderZoom(double value) async {
    await init();
    await _prefs?.setDouble(AppConstants.prefReaderZoom, value);
  }

  Future<String> getReaderTheme() async {
    await init();
    return _prefs?.getString(AppConstants.prefReaderTheme) ?? AppConstants.readerThemeDark;
  }

  Future<void> setReaderTheme(String value) async {
    await init();
    await _prefs?.setString(AppConstants.prefReaderTheme, value);
  }

  // Langue
  Future<String> getDefaultLanguage() async {
    await init();
    return _prefs?.getString(AppConstants.prefDefaultLanguage) ?? 'fr';
  }

  Future<void> setDefaultLanguage(String value) async {
    await init();
    await _prefs?.setString(AppConstants.prefDefaultLanguage, value);
  }

  // Utilisateur courant
  Future<int?> getCurrentUserId() async {
    await init();
    final id = _prefs?.getInt(AppConstants.prefCurrentUserId);
    return id;
  }

  Future<void> setCurrentUserId(int id) async {
    await init();
    await _prefs?.setInt(AppConstants.prefCurrentUserId, id);
  }

  Future<void> clearCurrentUser() async {
    await init();
    await _prefs?.remove(AppConstants.prefCurrentUserId);
  }

  Future<void> clear() async {
    await init();
    await _prefs?.clear();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primaires
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color success = Color(0xFF4CAF50);

  // Fond sombre (REMIS)
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF252542);
  static const Color darkDivider = Color(0xFF2E2E4A);

  // Fond clair (REMIS)
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Sépia (lecteur)
  static const Color sepiaBg = Color(0xFFF5E6C8);
  static const Color sepiaText = Color(0xFF3D2B1F);

  // Statuts manga
  static const Color statusOngoing = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusHiatus = Color(0xFFFF9800);
  static const Color statusCancelled = Color(0xFFF44336);
}


class AppTheme {
  // Fonction générique pour construire un thème sans répéter 100 lignes de code
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surface,
    required Color card,
    required Color divider,
    required Color primary,
    required Color secondary,
    required Color text,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? ColorScheme.dark(primary: primary, secondary: secondary, surface: surface, error: AppColors.error, onPrimary: Colors.white, onSecondary: Colors.white, onSurface: text, onError: Colors.white)
        : ColorScheme.light(primary: primary, secondary: secondary, surface: surface, error: AppColors.error, onPrimary: Colors.white, onSecondary: Colors.white, onSurface: Colors.black87, onError: Colors.white);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(fontFamily: 'Poppins', color: text, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 4 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        labelStyle: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.grey : Colors.black54),
      ),
      dividerTheme: DividerThemeData(color: divider, space: 1),
      listTileTheme: ListTileThemeData(iconColor: primary, textColor: text),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(fontFamily: 'Poppins', color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: text),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: text),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: text),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: text),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: text),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: text),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: text.withOpacity(0.8)),
      ),
    );
  }

  // Vos 4 thèmes
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark, scaffoldBg: const Color(0xFF0F0F1A), surface: const Color(0xFF1A1A2E),
    card: const Color(0xFF252542), divider: const Color(0xFF2E2E4A), primary: AppColors.primary, secondary: AppColors.secondary, text: Colors.white,
  );

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light, scaffoldBg: const Color(0xFFF5F5F5), surface: Colors.white,
    card: Colors.white, divider: Colors.grey[300]!, primary: AppColors.primary, secondary: AppColors.secondary, text: Colors.black87,
  );

  static ThemeData get draculaTheme => _buildTheme(
    brightness: Brightness.dark, scaffoldBg: const Color(0xFF282A36), surface: const Color(0xFF44475A),
    card: const Color(0xFF44475A), divider: const Color(0xFF6272A4), primary: const Color(0xFFBD93F9), secondary: const Color(0xFF50FA7B), text: const Color(0xFFF8F8F2),
  );

  static ThemeData get ayuDarkTheme => _buildTheme(
    brightness: Brightness.dark, scaffoldBg: const Color(0xFF0A0E14), surface: const Color(0xFF11151C),
    card: const Color(0xFF11151C), divider: const Color(0xFF1D2433), primary: const Color(0xFFFFB454), secondary: const Color(0xFF39BAE6), text: const Color(0xFFB3B1AD),
  );

  static Color statusColor(String? status) {
    switch (status) {
      case 'ongoing': return AppColors.statusOngoing;
      case 'completed': return AppColors.statusCompleted;
      case 'hiatus': return AppColors.statusHiatus;
      case 'cancelled': return AppColors.statusCancelled;
      default: return Colors.grey;
    }
  }

  static String statusLabel(String? status) {
    switch (status) {
      case 'ongoing': return 'En cours';
      case 'completed': return 'Terminé';
      case 'hiatus': return 'En pause';
      case 'cancelled': return 'Annulé';
      default: return 'Inconnu';
    }
  }
}
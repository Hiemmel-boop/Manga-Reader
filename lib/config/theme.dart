import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primaires
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFF9D96FF);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color accent = Color(0xFFFF6584);

  // Fond sombre
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF252542);
  static const Color darkDivider = Color(0xFF2E2E4A);

  // Fond clair
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

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey[600],
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primary.withOpacity(0.3),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[900],
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Couleur selon le statut manga
  static Color statusColor(String? status) {
    switch (status) {
      case 'ongoing': return AppColors.statusOngoing;
      case 'completed': return AppColors.statusCompleted;
      case 'hiatus': return AppColors.statusHiatus;
      case 'cancelled': return AppColors.statusCancelled;
      default: return Colors.grey;
    }
  }

  // Label français du statut
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
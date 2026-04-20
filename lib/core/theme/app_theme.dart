// lib/core/theme/app_theme.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C6FCD);
  static const Color primaryLight = Color(0xFFB8AEED);
  static const Color primaryDark = Color(0xFF5A4FAA);
  static const Color secondary = Color(0xFF6ECFB3);
  static const Color secondaryLight = Color(0xFFA8E6D8);
  static const Color accent = Color(0xFFFFB085);
  static const Color accentLight = Color(0xFFFFD4B8);

  static const Color background = Color(0xFFF7F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFEDF9);

  static const Color darkBackground = Color(0xFF1A1730);
  static const Color darkSurface = Color(0xFF252240);
  static const Color darkCard = Color(0xFF2E2B50);

  static const Color success = Color(0xFF6ECFB3);
  static const Color warning = Color(0xFFFFB085);
  static const Color error = Color(0xFFFF6B8A);
  static const Color info = Color(0xFF74B9E8);
  static const Color crisis = Color(0xFFFF4D6D);

  static const Color textPrimary = Color(0xFF2D2A4A);
  static const Color textSecondary = Color(0xFF6B6882);
  static const Color textHint = Color(0xFFADABBF);

  static const Map<String, Color> tierColors = {
    'Newcomer': Color(0xFF9DB8D0),
    'Explorer': Color(0xFF6ECFB3),
    'Warrior': Color(0xFF7C6FCD),
    'Mind Master': Color(0xFFFFB085),
    'Legend': Color(0xFFFFD700),
  };

  static const Map<int, Color> moodColors = {
    1: Color(0xFFFF6B8A),
    2: Color(0xFFFFB085),
    3: Color(0xFFFFD166),
    4: Color(0xFF6ECFB3),
    5: Color(0xFF7C6FCD),
  };
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: const TextStyle(
              fontFamily: 'Nunito', color: AppColors.textHint, fontSize: 15),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
          displayMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
          headlineLarge: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
          headlineMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
          headlineSmall: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          titleLarge: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
          titleMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          bodyLarge: TextStyle(
              fontFamily: 'Nunito', fontSize: 16, color: AppColors.textPrimary),
          bodyMedium: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.textSecondary),
          bodySmall: TextStyle(
              fontFamily: 'Nunito', fontSize: 12, color: AppColors.textHint),
        ),
      );

  static ThemeData get dark => light.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
        ),
      );
}

import 'package:flutter/material.dart';

/// DaisyUI Wireframe Color Scheme
/// Converted from OKLCH to Flutter Color objects
class AppColors {
  // Base colors
  static const Color base100 =
      Color(0xFFFFFFFF); // oklch(100% 0 0) - Pure white
  static const Color base200 =
      Color(0xFFF7F7F7); // oklch(97% 0 0) - Very light gray
  static const Color base300 = Color(0xFFF0F0F0); // oklch(94% 0 0) - Light gray
  static const Color baseContent =
      Color(0xFF333333); // oklch(20% 0 0) - Dark gray/black

  // Primary colors (all grayscale in wireframe)
  static const Color primary = Color(0xFFDEDEDE); // oklch(87% 0 0) - Light gray
  static const Color primaryContent =
      Color(0xFF424242); // oklch(26% 0 0) - Dark gray

  // Secondary colors
  static const Color secondary =
      Color(0xFFDEDEDE); // oklch(87% 0 0) - Light gray
  static const Color secondaryContent =
      Color(0xFF424242); // oklch(26% 0 0) - Dark gray

  // Accent colors
  static const Color accent = Color(0xFFDEDEDE); // oklch(87% 0 0) - Light gray
  static const Color accentContent =
      Color(0xFF424242); // oklch(26% 0 0) - Dark gray

  // Neutral colors
  static const Color neutral = Color(0xFFDEDEDE); // oklch(87% 0 0) - Light gray
  static const Color neutralContent =
      Color(0xFF424242); // oklch(26% 0 0) - Dark gray

  // Info colors (only colored elements in wireframe)
  static const Color info = Color(0xFF4A90E2); // oklch(44% 0.11 240.79) - Blue
  static const Color infoContent =
      Color(0xFFE6F2FF); // oklch(90% 0.058 230.902) - Light blue

  // Success colors
  static const Color success =
      Color(0xFF4CAF50); // oklch(43% 0.095 166.913) - Green
  static const Color successContent =
      Color(0xFFE8F5E8); // oklch(90% 0.093 164.15) - Light green

  // Warning colors
  static const Color warning =
      Color(0xFFFF9800); // oklch(47% 0.137 46.201) - Orange
  static const Color warningContent =
      Color(0xFFFFF3E0); // oklch(92% 0.12 95.746) - Light orange

  // Error colors
  static const Color error = Color(0xFFE53E3E); // oklch(44% 0.177 26.899) - Red
  static const Color errorContent =
      Color(0xFFFFEBEE); // oklch(88% 0.062 18.334) - Light red

  // Additional utility colors
  static const Color surface = base100;
  static const Color background = base200;
  static const Color onSurface = baseContent;
  static const Color onBackground = baseContent;
}

/// App Theme Data
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryContent,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryContent,
        tertiary: AppColors.accent,
        onTertiary: AppColors.accentContent,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
        onError: AppColors.errorContent,
        outline: AppColors.neutral,
        outlineVariant: AppColors.base300,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.baseContent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryContent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 0.25rem for wireframe
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.baseContent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.baseContent,
          side: const BorderSide(
              color: AppColors.baseContent, width: 1), // 1px border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // 0.25rem
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), // 0.25rem for fields
          borderSide: const BorderSide(color: AppColors.baseContent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.baseContent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.baseContent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: const TextStyle(color: AppColors.baseContent),
        hintStyle: const TextStyle(color: AppColors.neutral),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 0.25rem for boxes
          side: const BorderSide(color: AppColors.baseContent, width: 1),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.neutral,
        contentTextStyle: TextStyle(color: AppColors.neutralContent),
        actionTextColor: AppColors.neutralContent,
      ),
    );
  }

  static ThemeData get darkTheme {
    // For now, return the same as light theme since the DaisyUI theme is light
    // You can implement dark theme later if needed
    return lightTheme;
  }
}

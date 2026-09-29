import 'package:flutter/material.dart';

/// Central font families and type scale for Arabic and English interfaces.
abstract final class AppTypography {
  static const arabicFontFamily = 'NotoSansArabic';
  static const latinFontFamily = 'Manrope';

  static String fontFamilyFor(Locale? locale) =>
      locale?.languageCode == 'ar' ? arabicFontFamily : latinFontFamily;

  static List<String> fallbackFor(Locale? locale) =>
      locale?.languageCode == 'ar'
      ? const [latinFontFamily]
      : const [arabicFontFamily];

  static TextTheme get textTheme => const TextTheme(
    displaySmall: TextStyle(
      fontSize: 36,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.55),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.45),
    labelLarge: TextStyle(
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.25,
      fontWeight: FontWeight.w600,
    ),
  );
}

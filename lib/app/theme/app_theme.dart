import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF176B68);
  static const background = Color(0xFFFAF8F2);
  static const surface = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
  }
}

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF176B68);
  static const primaryDark = Color(0xFF0E4F4D);
  static const primaryLight = Color(0xFFCFE8E2);
  static const background = Color(0xFFFAF8F2);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF203332);
  static const textSecondary = Color(0xFF526260);
  static const outline = Color(0xFF687875);
  static const error = Color(0xFFB94A48);
}

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        error: AppColors.error,
        onError: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: Typography.material2021().black.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      useMaterial3: true,
    );
  }
}

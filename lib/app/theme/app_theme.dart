import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'appearance_controller.dart';

abstract final class AppTheme {
  static const _scheme = ColorScheme.dark(
    primary: AppColors.mint,
    onPrimary: AppColors.navy,
    primaryContainer: AppColors.mintDeep,
    onPrimaryContainer: AppColors.mintBright,
    surface: AppColors.navySurface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLow: AppColors.navy,
    surfaceContainer: AppColors.navySurface,
    surfaceContainerHigh: AppColors.navyRaised,
    surfaceContainerHighest: AppColors.navyArtwork,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineSubtle,
    error: AppColors.error,
    onError: AppColors.navy,
  );

  /// Builds the selected dark palette with locale-aware typography.
  static ThemeData forLocale(
    Locale? locale, {
    AppAppearance appearance = AppAppearance.dark,
  }) {
    final night = appearance == AppAppearance.night;
    final background = night ? const Color(0xFF030711) : AppColors.navy;
    final surface = night ? const Color(0xFF0B1220) : AppColors.navySurface;
    final raised = night ? const Color(0xFF141E2D) : AppColors.navyRaised;
    final scheme = _scheme.copyWith(
      surface: surface,
      surfaceContainerLow: background,
      surfaceContainer: surface,
      surfaceContainerHigh: raised,
    );
    final fontFamily = AppTypography.fontFamilyFor(locale);
    final fallback = AppTypography.fallbackFor(locale);
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    final rounded16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      fontFamilyFallback: fallback,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.outlineSubtle,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: const Size(48, 56),
          shape: rounded16,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.navy,
          minimumSize: const Size(48, 56),
          shape: rounded16,
          elevation: 0,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mintBright,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.outline),
          shape: rounded16,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mintBright,
          minimumSize: const Size(48, 48),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mint, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.mintDeep,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.mint
                : AppColors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.mint
                : AppColors.textSecondary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.navyRaised,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mint,
        linearTrackColor: AppColors.outlineSubtle,
        circularTrackColor: AppColors.outlineSubtle,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outlineSubtle),
      useMaterial3: true,
    );
  }

  /// Kept for existing tests and consumers; the app uses a dark visual scheme.
  static ThemeData light({Locale? locale}) => forLocale(locale);
}

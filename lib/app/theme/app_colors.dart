import 'package:flutter/material.dart';

/// The single source of truth for Raha Move appearance palettes.
///
/// Feature widgets should consume semantic roles from [ColorScheme] instead of
/// importing these values directly.
abstract final class AppColors {
  static const mint = Color(0xFF28BD91);
  static const mintBright = Color(0xFF86E5C7);
  static const mintDeep = Color(0xFF123D3B);

  static const navy = Color(0xFF080F20);
  static const navySurface = Color(0xFF11192C);
  static const navyRaised = Color(0xFF1A263A);
  static const navyArtwork = Color(0xFF24374A);

  static const textPrimary = Color(0xFFF5F7FC);
  static const textSecondary = Color(0xFFA5B2C8);
  static const outline = Color(0xFF4E607A);
  static const outlineSubtle = Color(0xFF2D3B50);
  static const error = Color(0xFFFFB4AB);

  static const darkScheme = ColorScheme.dark(
    primary: mint,
    onPrimary: navy,
    primaryContainer: mintDeep,
    onPrimaryContainer: mintBright,
    surface: navySurface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    surfaceContainerLow: navy,
    surfaceContainer: navySurface,
    surfaceContainerHigh: navyRaised,
    surfaceContainerHighest: navyArtwork,
    outline: outline,
    outlineVariant: outlineSubtle,
    error: error,
    onError: navy,
  );

  static const nightScheme = ColorScheme.dark(
    primary: mint,
    onPrimary: navy,
    primaryContainer: mintDeep,
    onPrimaryContainer: mintBright,
    surface: Color(0xFF0B1220),
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    surfaceContainerLow: Color(0xFF030711),
    surfaceContainer: Color(0xFF0B1220),
    surfaceContainerHigh: Color(0xFF141E2D),
    surfaceContainerHighest: navyArtwork,
    outline: outline,
    outlineVariant: outlineSubtle,
    error: error,
    onError: navy,
  );

  static const lightScheme = ColorScheme.light(
    primary: Color(0xFF146B51),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6F2E5),
    onPrimaryContainer: Color(0xFF124434),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF172B29),
    onSurfaceVariant: Color(0xFF4E625D),
    surfaceContainerLow: Color(0xFFF6F7F2),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHigh: Color(0xFFE8EFEA),
    surfaceContainerHighest: Color(0xFFDDE8E1),
    outline: Color(0xFF657D75),
    outlineVariant: Color(0xFFCAD8D1),
    error: Color(0xFFB3261E),
    onError: Colors.white,
  );
}

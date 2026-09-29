import 'package:flutter/material.dart';

/// The single source of truth for the Raha Move dark navy and mint palette.
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
}

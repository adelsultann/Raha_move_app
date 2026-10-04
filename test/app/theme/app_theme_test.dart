import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/theme/app_theme.dart';
import 'package:raha_move/app/theme/app_typography.dart';
import 'package:raha_move/app/theme/appearance_controller.dart';

void main() {
  test(
    'primary text and controls meet WCAG AA contrast in each appearance',
    () {
      for (final appearance in AppAppearance.values) {
        final scheme = AppTheme.forLocale(
          const Locale('en'),
          appearance: appearance,
        ).colorScheme;
        expect(
          _contrastRatio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(scheme.onSurfaceVariant, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(scheme.onError, scheme.error),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  test('uses the approved navy and mint palette for semantic roles', () {
    final scheme = AppTheme.forLocale(const Locale('en')).colorScheme;

    expect(scheme.primary, const Color(0xFF28BD91));
    expect(scheme.surface, const Color(0xFF11192C));
    expect(scheme.surfaceContainerLow, const Color(0xFF080F20));
    expect(scheme.onSurface, const Color(0xFFF5F7FC));
  });

  test('night appearance keeps readable contrast and darkens surfaces', () {
    final dark = AppTheme.forLocale(const Locale('en'));
    final night = AppTheme.forLocale(
      const Locale('en'),
      appearance: AppAppearance.night,
    );
    expect(night.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
    expect(night.colorScheme.surface, isNot(dark.colorScheme.surface));
    expect(
      _contrastRatio(night.colorScheme.onSurface, night.colorScheme.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  test(
    'light appearance uses light surfaces and centralized control colors',
    () {
      final theme = AppTheme.light(locale: const Locale('ar'));
      final scheme = theme.colorScheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, scheme.surfaceContainerLow);
      expect(theme.cardTheme.color, scheme.surface);
      expect(theme.appBarTheme.foregroundColor, scheme.onSurface);
      expect(theme.navigationBarTheme.backgroundColor, scheme.surface);
      expect(theme.textTheme.bodyMedium?.color, scheme.onSurface);
    },
  );

  test('selects the centralized font family for each locale', () {
    final english = AppTheme.forLocale(const Locale('en'));
    final arabic = AppTheme.forLocale(const Locale('ar'));

    expect(
      english.textTheme.bodyMedium?.fontFamily,
      AppTypography.latinFontFamily,
    );
    expect(
      arabic.textTheme.bodyMedium?.fontFamily,
      AppTypography.arabicFontFamily,
    );
    expect(
      english.textTheme.bodyMedium?.fontFamilyFallback,
      contains(AppTypography.arabicFontFamily),
    );
    expect(
      arabic.textTheme.bodyMedium?.fontFamilyFallback,
      contains(AppTypography.latinFontFamily),
    );
  });
}

double _contrastRatio(Color first, Color second) {
  final lighter = math.max(
    _relativeLuminance(first),
    _relativeLuminance(second),
  );
  final darker = math.min(
    _relativeLuminance(first),
    _relativeLuminance(second),
  );
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double linearize(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

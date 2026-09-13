import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/theme/app_theme.dart';

void main() {
  test('primary text and controls meet WCAG AA contrast targets', () {
    final scheme = AppTheme.light().colorScheme;

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

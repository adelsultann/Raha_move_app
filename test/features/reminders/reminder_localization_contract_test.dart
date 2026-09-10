import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scheduled notification ARB copy is static and lock-screen safe', () {
    for (final locale in ['en', 'ar']) {
      final map = jsonDecode(
        File('lib/app/localization/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final key in [
        'reminderNotificationTitle',
        'reminderNotificationBody',
      ]) {
        final value = map[key] as String;
        expect(value, isNot(contains('{')));
        expect(value, isNot(contains('http')));
        expect(
          value.toLowerCase(),
          isNot(
            anyOf(
              contains('routine'),
              contains('token'),
              contains('payload'),
              contains('id'),
            ),
          ),
        );
      }
    }
  });
}

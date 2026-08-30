import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/exercise_library/data/canonical_json.dart';

void main() {
  group('CanonicalJson', () {
    test('sorts object keys by UTF-8 length first, then bytewise', () {
      // "b" is shorter than "aa"; "aa" sorts before "ab" by byte value.
      final encoded = CanonicalJson.encode({'ab': 1, 'b': 2, 'aa': 3});
      expect(encoded, '{"b": 2, "aa": 3, "ab": 1}');
    });

    test('renders objects with Postgres jsonb spacing', () {
      final encoded = CanonicalJson.encode({'key': 'value', 'n': 1});
      expect(encoded, '{"n": 1, "key": "value"}');
    });

    test('renders arrays without surrounding whitespace', () {
      final encoded = CanonicalJson.encode([1, 'two', true, null, 3.0]);
      expect(encoded, '[1, "two", true, null, 3.0]');
    });

    test('escapes strings like Postgres escape_json', () {
      final encoded = CanonicalJson.encode('a"b\\c\nd\te');
      expect(encoded, r'"a\"b\\c\nd\te"');
    });

    test('escapes control characters as lower-case hex', () {
      final encoded = CanonicalJson.encode('\x01');
      expect(encoded, r'"\u0001"');
    });

    test('keeps non-ASCII characters as raw UTF-8 text', () {
      final encoded = CanonicalJson.encode('مرحبا');
      expect(encoded, '"مرحبا"');
      expect(utf8.encode(encoded), utf8.encode('"مرحبا"'));
    });

    test('distinguishes integers from integral doubles', () {
      expect(CanonicalJson.encode(1), '1');
      expect(CanonicalJson.encode(1.0), '1.0');
      expect(CanonicalJson.encode(1.5), '1.5');
    });

    test('rejects non-finite doubles', () {
      expect(() => CanonicalJson.encode(double.nan), throwsArgumentError);
      expect(() => CanonicalJson.encode(double.infinity), throwsArgumentError);
    });

    test('encoding an already-canonical structure is idempotent', () {
      final value = {
        'release': {'id': '1', 'version': 'v1'},
        'exercises': <Object>[
          {'id': 'e1', 'public_id': 'raha_ex_000001'},
        ],
        'tombstones': <Object>[],
      };
      final first = CanonicalJson.encode(value);
      final second = CanonicalJson.encode(jsonDecode(first));
      expect(second, first);
    });
  });
}

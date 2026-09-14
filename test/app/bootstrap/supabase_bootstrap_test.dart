import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/supabase_bootstrap.dart';

void main() {
  group('isPermittedSupabaseUrl', () {
    test('allows HTTPS URLs in every environment', () {
      expect(
        isPermittedSupabaseUrl(
          Uri.parse('https://project.supabase.co'),
          allowLocalHttp: false,
        ),
        isTrue,
      );
    });

    test('allows Android Emulator access to the local API in development', () {
      expect(
        isPermittedSupabaseUrl(
          Uri.parse('http://10.0.2.2:54321'),
          allowLocalHttp: true,
        ),
        isTrue,
      );
    });

    test('rejects local HTTP outside development', () {
      expect(
        isPermittedSupabaseUrl(
          Uri.parse('http://10.0.2.2:54321'),
          allowLocalHttp: false,
        ),
        isFalse,
      );
    });
  });
}

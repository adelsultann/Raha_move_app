import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/media/data/supabase_trusted_media_resolver.dart';
import 'package:raha_move/features/media/domain/media_delivery.dart';

void main() {
  final now = DateTime.utc(2026, 8, 30, 12);

  test('resolves only for the currently authenticated cache owner', () async {
    final gateway = _FakeGateway(
      currentUserId: 'owner-a',
      response: {
        'signed_url': 'https://cdn.example.test/private/video.mp4?token=secret',
        'expires_at': now.add(const Duration(minutes: 5)).toIso8601String(),
      },
    );
    final resolver = SupabaseTrustedMediaResolver(
      gateway: gateway,
      clock: () => now,
    );

    final result = await resolver.resolve(
      MediaAuthorizationRequest(
        deliveryReference: '00000000-0000-4000-8000-000000000001',
        accessScope: MediaAccessScope(ownerId: 'owner-a'),
      ),
    );

    expect(result.value.host, 'cdn.example.test');
    expect(gateway.references, ['00000000-0000-4000-8000-000000000001']);
  });

  test('rejects account switching before calling the backend', () async {
    final gateway = _FakeGateway(currentUserId: 'owner-b', response: const {});
    final resolver = SupabaseTrustedMediaResolver(
      gateway: gateway,
      clock: () => now,
    );

    await expectLater(
      resolver.resolve(
        MediaAuthorizationRequest(
          deliveryReference: '00000000-0000-4000-8000-000000000001',
          accessScope: MediaAccessScope(ownerId: 'owner-a'),
        ),
      ),
      throwsA(
        isA<MediaAuthorizationException>().having(
          (error) => error.code,
          'code',
          'account_changed',
        ),
      ),
    );
    expect(gateway.references, isEmpty);
  });

  test('rejects expired capabilities without exposing their URL', () async {
    final gateway = _FakeGateway(
      currentUserId: 'owner-a',
      response: {
        'signed_url': 'https://cdn.example.test/private/video.mp4?token=secret',
        'expires_at': now
            .subtract(const Duration(seconds: 1))
            .toIso8601String(),
      },
    );
    final resolver = SupabaseTrustedMediaResolver(
      gateway: gateway,
      clock: () => now,
    );

    Object? caught;
    try {
      await resolver.resolve(
        MediaAuthorizationRequest(
          deliveryReference: '00000000-0000-4000-8000-000000000001',
          accessScope: MediaAccessScope(ownerId: 'owner-a'),
        ),
      );
    } catch (error) {
      caught = error;
    }
    expect(caught, isA<MediaAuthorizationException>());
    expect(caught.toString(), isNot(contains('token=secret')));
    expect(caught.toString(), isNot(contains('cdn.example.test')));
  });
}

final class _FakeGateway implements MediaAuthorizationGateway {
  _FakeGateway({required this.currentUserId, required this.response});

  @override
  final String? currentUserId;
  final Map<String, Object?> response;
  final references = <String>[];

  @override
  Future<Map<String, Object?>> authorize(String deliveryReference) async {
    references.add(deliveryReference);
    return response;
  }
}

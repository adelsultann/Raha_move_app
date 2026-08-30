import 'package:raha_move/features/media/domain/media_delivery.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Privacy-safe resolver failure. It deliberately contains no URL, storage
/// key, provider payload, token, or raw backend response.
final class MediaAuthorizationException implements Exception {
  const MediaAuthorizationException(this.code);

  final String code;

  @override
  String toString() => 'MediaAuthorizationException($code)';
}

abstract interface class MediaAuthorizationGateway {
  String? get currentUserId;

  Future<Map<String, Object?>> authorize(String deliveryReference);
}

/// Calls the authenticated trusted Edge Function. The function—not the
/// client—checks catalog status, account ownership, and premium entitlement.
final class SupabaseMediaAuthorizationGateway
    implements MediaAuthorizationGateway {
  SupabaseMediaAuthorizationGateway(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<Map<String, Object?>> authorize(String deliveryReference) async {
    final response = await _client.functions.invoke(
      'resolve-media-delivery',
      body: {'delivery_reference': deliveryReference},
    );
    if (response.status < 200 ||
        response.status >= 300 ||
        response.data is! Map) {
      throw const MediaAuthorizationException('authorization_rejected');
    }
    return Map<String, Object?>.from(response.data as Map);
  }
}

final class SupabaseTrustedMediaResolver implements TrustedMediaResolver {
  SupabaseTrustedMediaResolver({required this.gateway, required this.clock});

  final MediaAuthorizationGateway gateway;
  final DateTime Function() clock;

  @override
  Future<EphemeralMediaUrl> resolve(MediaAuthorizationRequest request) async {
    if (gateway.currentUserId != request.accessScope.ownerId) {
      throw const MediaAuthorizationException('account_changed');
    }
    final body = await gateway.authorize(request.deliveryReference);
    final rawUrl = body['signed_url'];
    final rawExpiry = body['expires_at'];
    if (rawUrl is! String || rawExpiry is! String) {
      throw const MediaAuthorizationException('invalid_response');
    }
    final uri = Uri.tryParse(rawUrl);
    final expiresAt = DateTime.tryParse(rawExpiry)?.toUtc();
    final isLocalHttp =
        uri?.scheme == 'http' &&
        (uri?.host == '127.0.0.1' || uri?.host == 'localhost');
    if (uri == null ||
        (!uri.isScheme('https') && !isLocalHttp) ||
        expiresAt == null ||
        !expiresAt.isAfter(clock().toUtc())) {
      throw const MediaAuthorizationException('invalid_capability');
    }
    return EphemeralMediaUrl(value: uri, expiresAt: expiresAt);
  }
}

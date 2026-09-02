import 'dart:convert';

import '../domain/sync_operation.dart';
import '../domain/sync_transport.dart';
import 'sync_rpc_gateway.dart';

/// Authenticated Supabase transport for `sync_push_user_data` and
/// `sync_pull_user_data`.
///
/// The transport never sends a caller identity — the backend derives the owner
/// from the injected session. It only talks to the backend when the gateway is
/// configured and its live session belongs to [ownerUserId]; otherwise every
/// push/pull reports [SyncUnavailable]/[SyncPullUnavailable] so the engine
/// retains the outbox without consuming retry budget. This is the
/// account-switch/logout safety boundary.
final class SupabaseSyncTransport implements SyncTransport {
  SupabaseSyncTransport(
    this._gateway, {
    required this.ownerUserId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SyncRpcGateway _gateway;
  final String ownerUserId;
  final DateTime Function() _clock;

  bool get _available =>
      _gateway.isConfigured && _gateway.currentUserId == ownerUserId;

  @override
  Future<SyncPushResponse> push(SyncOperation operation) async {
    if (!_available) return const SyncUnavailable();
    final envelope = <String, Object?>{
      'operation_id': operation.operationId,
      'kind': operation.kind,
      'payload': jsonDecode(operation.payloadJson),
    };
    final Map<String, dynamic>? body;
    try {
      body = await _gateway.rpc('sync_push_user_data', {
        'p_operations': [envelope],
      });
    } on SyncRpcRejectedException {
      return const SyncRejected(SyncDiagnostics.validationRejected);
    } catch (_) {
      return const SyncRetryableFailure();
    }
    if (body == null) {
      return const SyncRejected(SyncDiagnostics.validationRejected);
    }
    return SyncAccepted(
      projections: _parseProjections(body['projections']),
      cursor: _asInt(body['cursor']),
    );
  }

  @override
  Future<SyncPullResponse> pull({
    required int afterCursor,
    int limit = 100,
  }) async {
    if (!_available) return const SyncPullUnavailable();
    final Map<String, dynamic>? body;
    try {
      body = await _gateway.rpc('sync_pull_user_data', {
        'p_after_cursor': afterCursor,
        'p_limit': limit,
      });
    } catch (_) {
      return const SyncPullRetryable();
    }
    if (body == null) return const SyncPullRetryable();

    final changes = <SyncPullChange>[];
    final rawChanges = body['changes'];
    if (rawChanges is List) {
      for (final raw in rawChanges.whereType<Map>()) {
        final change = Map<String, dynamic>.from(raw);
        final payload = change['payload'];
        changes.add(
          SyncPullChange(
            cursor: _asInt(change['cursor']) ?? 0,
            entityType: change['entity_type']?.toString() ?? '',
            entityId: change['entity_id']?.toString() ?? '',
            operation: change['operation']?.toString() ?? '',
            payloadJson: payload == null ? '{}' : jsonEncode(payload),
            occurredAt:
                DateTime.tryParse(change['occurred_at']?.toString() ?? '') ??
                _clock().toUtc(),
          ),
        );
      }
    }
    return SyncPullSuccess(
      changes: changes,
      cursor: _asInt(body['cursor']) ?? afterCursor,
      projections: _parseProjections(body['projections']),
    );
  }

  List<SyncProjection> _parseProjections(Object? raw) {
    if (raw is! Map) return const [];
    final projections = <SyncProjection>[];
    // The trusted RPC emits an append-only `points` ledger array alongside the
    // authoritative `points_balance`. Cache them together under one local
    // projection so callers cannot mistake a client-derived total for a server
    // balance.
    if (raw['points'] != null || raw['points_balance'] != null) {
      projections.add(
        SyncProjection(
          projectionType: 'points',
          payloadJson: jsonEncode(<String, Object?>{
            if (raw['points'] != null) 'points': raw['points'],
            if (raw['points_balance'] != null)
              'points_balance': raw['points_balance'],
          }),
          serverUpdatedAt: _latestTimestamp(raw['points']) ?? _clock().toUtc(),
        ),
      );
    }
    for (final key in const [
      'weekly_progress',
      'achievements',
      'streak',
      'entitlements',
    ]) {
      final value = raw[key];
      if (value == null) continue;
      projections.add(
        SyncProjection(
          projectionType: key,
          payloadJson: jsonEncode(value),
          serverUpdatedAt: _latestTimestamp(value) ?? _clock().toUtc(),
        ),
      );
    }
    return projections;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  /// Best-effort "most recent" timestamp for a projection, used only to order
  /// the cached read-only summary; the server remains authoritative.
  DateTime? _latestTimestamp(Object? value) {
    final candidates = <DateTime>[];
    void collect(Object? node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (entry.key.toString().endsWith('_at') ||
              entry.key == 'last_movement_date') {
            final parsed = DateTime.tryParse(entry.value?.toString() ?? '');
            if (parsed != null) candidates.add(parsed);
          }
          collect(entry.value);
        }
      } else if (node is List) {
        for (final item in node) {
          collect(item);
        }
      }
    }

    collect(value);
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/analytics/analytics_service.dart';
import 'package:raha_move/core/database/app_database.dart';

/// Emits one privacy-safe event for each server-confirmed positive ledger
/// award. This reads a cached authoritative projection only: it never creates
/// or changes client ledger data.
final class PointsAwardAnalyticsGate {
  factory PointsAwardAnalyticsGate({
    required AppDatabase database,
    required String activeUserId,
    required AnalyticsService analytics,
    DateTime Function()? clock,
  }) => PointsAwardAnalyticsGate._(
    database: database,
    activeUserId: activeUserId,
    analytics: analytics,
    clock: clock,
  );

  PointsAwardAnalyticsGate._({
    required this._database,
    required this.activeUserId,
    required this.analytics,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final String activeUserId;
  final AnalyticsService analytics;
  final DateTime Function() _clock;

  /// One queued delivery pass per owner prevents two concurrent sync triggers
  /// from both observing a missing receipt and tracking the same award.
  static final Map<String, Future<void>> _inFlightByUser =
      <String, Future<void>>{};

  /// Returns the number of events successfully recorded in this pass.
  ///
  /// Consent is checked before querying or writing receipts. A disabled service
  /// therefore leaves every confirmed award pending for a later opted-in pass.
  Future<int> emitPendingAwards() async {
    final previous = _inFlightByUser[activeUserId] ?? Future<void>.value();
    final completion = Completer<void>();
    _inFlightByUser[activeUserId] = completion.future;
    await previous;
    try {
      return await _emitPendingAwards();
    } finally {
      completion.complete();
      if (identical(_inFlightByUser[activeUserId], completion.future)) {
        _inFlightByUser.remove(activeUserId);
      }
    }
  }

  Future<int> _emitPendingAwards() async {
    if (!analytics.isEnabled) return 0;

    final projection =
        await (_database.select(_database.localProgressProjections)..where(
              (row) =>
                  row.userId.equals(activeUserId) &
                  row.projectionType.equals('points'),
            ))
            .getSingleOrNull();
    if (projection == null) return 0;

    var emitted = 0;
    for (final award in _awardsFrom(projection.payloadJson)) {
      final receipt =
          await (_database.select(_database.localAnalyticsEmissionReceipts)
                ..where(
                  (row) =>
                      row.userId.equals(activeUserId) &
                      row.eventName.equals(AnalyticsEventName.pointsAwarded) &
                      row.authoritativeLedgerId.equals(award.ledgerId),
                ))
              .getSingleOrNull();
      if (receipt != null) continue;

      // A synchronous AnalyticsService can signal failure by throwing. Write
      // the receipt only after it returns, preserving this award for retry.
      try {
        analytics.track(
          AnalyticsEvent(
            name: AnalyticsEventName.pointsAwarded,
            properties: <String, Object?>{
              AnalyticsPropertyKey.ruleVersion: award.ruleVersion,
              AnalyticsPropertyKey.pointAmount: award.pointAmount,
              AnalyticsPropertyKey.sourceType: award.sourceType,
            },
          ),
        );
      } catch (_) {
        continue;
      }

      await _database
          .into(_database.localAnalyticsEmissionReceipts)
          .insert(
            LocalAnalyticsEmissionReceiptsCompanion.insert(
              userId: activeUserId,
              eventName: AnalyticsEventName.pointsAwarded,
              authoritativeLedgerId: award.ledgerId,
              emittedAt: _clock().toUtc(),
            ),
          );
      emitted++;
    }
    return emitted;
  }

  Iterable<_ConfirmedAward> _awardsFrom(String payloadJson) sync* {
    final Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } on FormatException {
      return;
    }
    final ledger = decoded is List
        ? decoded
        : decoded is Map
        ? decoded['points']
        : null;
    if (ledger is! List) return;
    for (final entry in ledger.whereType<Map>()) {
      final id = entry['id'];
      final ruleVersion = entry['rule_version'];
      final sourceType = entry['source_type'];
      final points = _asInt(entry['points']);
      // Corrections and malformed/unrecognized ledger rows are not awards.
      if (id is! String ||
          id.isEmpty ||
          ruleVersion is! String ||
          ruleVersion.isEmpty ||
          sourceType is! String ||
          !_allowedSourceTypes.contains(sourceType) ||
          points == null ||
          points <= 0) {
        continue;
      }
      yield _ConfirmedAward(id, ruleVersion, sourceType, points);
    }
  }

  static const _allowedSourceTypes = <String>{
    'session',
    'achievement',
    'challenge',
    'admin',
  };

  int? _asInt(Object? value) => switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}

final class _ConfirmedAward {
  const _ConfirmedAward(
    this.ledgerId,
    this.ruleVersion,
    this.sourceType,
    this.pointAmount,
  );

  final String ledgerId;
  final String ruleVersion;
  final String sourceType;
  final int pointAmount;
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/analytics/analytics_catalog.dart';
import 'package:raha_move/core/analytics/analytics_event.dart';
import 'package:raha_move/core/analytics/analytics_service.dart';
import 'package:raha_move/core/analytics/analytics_service_impls.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/gamification/data/points_award_analytics_gate.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            userId: 'user-1',
            preferredLocale: 'en',
            timezone: 'Asia/Riyadh',
            weeklyGoalDays: 3,
            localUpdatedAt: DateTime.utc(2026, 9, 2),
          ),
        );
  });
  tearDown(() => database.close());

  test(
    'keeps confirmed awards pending while analytics consent is off',
    () async {
      final analytics = InMemoryAnalyticsService();
      await _storeLedger(database, [_award('ledger-1')]);

      expect(await _gate(database, analytics).emitPendingAwards(), 0);
      expect(analytics.recordedEvents, isEmpty);
      expect(
        await database.select(database.localAnalyticsEmissionReceipts).get(),
        isEmpty,
      );

      analytics.setEnabled(true);
      expect(await _gate(database, analytics).emitPendingAwards(), 1);
    },
  );

  test('emits only approved points award properties after consent', () async {
    final analytics = InMemoryAnalyticsService(enabled: true);
    await _storeLedger(database, [
      _award('ledger-1', sourceId: 'private-session-id', userId: 'user-1'),
    ]);

    await _gate(database, analytics).emitPendingAwards();

    expect(analytics.recordedEvents, hasLength(1));
    final event = analytics.recordedEvents.single;
    expect(event.name, AnalyticsEventName.pointsAwarded);
    expect(event.properties, <String, Object?>{
      AnalyticsPropertyKey.ruleVersion: 'points_completion_v1',
      AnalyticsPropertyKey.pointAmount: 10,
      AnalyticsPropertyKey.sourceType: 'session',
    });
    expect(event.properties.values, isNot(contains('ledger-1')));
    expect(event.properties.values, isNot(contains('private-session-id')));
    expect(event.properties.keys, isNot(contains('id')));
    expect(event.properties.keys, isNot(contains('source_id')));
    expect(event.properties.keys, isNot(contains('user_id')));
  });

  test(
    'deduplicates repeated projection processing by authoritative ledger id',
    () async {
      final analytics = InMemoryAnalyticsService(enabled: true);
      await _storeLedger(database, [_award('ledger-1')]);

      await _gate(database, analytics).emitPendingAwards();
      await _storeLedger(database, [_award('ledger-1')]);
      await _gate(database, analytics).emitPendingAwards();

      expect(analytics.recordedEvents, hasLength(1));
    },
  );

  test(
    'serializes concurrent delivery passes for the same user and ledger',
    () async {
      final analytics = InMemoryAnalyticsService(enabled: true);
      await _storeLedger(database, [_award('ledger-1')]);

      final first = _gate(database, analytics).emitPendingAwards();
      final second = _gate(database, analytics).emitPendingAwards();

      expect(await Future.wait([first, second]), unorderedEquals([1, 0]));
      expect(analytics.recordedEvents, hasLength(1));
    },
  );

  test('emits once for each different authoritative ledger id', () async {
    final analytics = InMemoryAnalyticsService(enabled: true);
    await _storeLedger(database, [_award('ledger-1'), _award('ledger-2')]);

    expect(await _gate(database, analytics).emitPendingAwards(), 2);
    expect(analytics.recordedEvents, hasLength(2));
  });

  test('uses durable receipts when a new gate is created after restart', () async {
    final analytics = InMemoryAnalyticsService(enabled: true);
    await _storeLedger(database, [_award('ledger-1')]);
    await _gate(database, analytics).emitPendingAwards();

    // A newly constructed gate models process recreation over the same durable
    // Drift store; it must honor the previously persisted receipt.
    final restartedGate = _gate(database, analytics);
    expect(await restartedGate.emitPendingAwards(), 0);
    expect(analytics.recordedEvents, hasLength(1));
  });

  test(
    'does not mark a receipt when analytics throws and retries later',
    () async {
      final failing = _ThrowingAnalyticsService();
      await _storeLedger(database, [_award('ledger-1')]);

      expect(await _gate(database, failing).emitPendingAwards(), 0);
      expect(
        await database.select(database.localAnalyticsEmissionReceipts).get(),
        isEmpty,
      );

      final recovered = InMemoryAnalyticsService(enabled: true);
      expect(await _gate(database, recovered).emitPendingAwards(), 1);
      expect(recovered.recordedEvents, hasLength(1));
    },
  );
}

PointsAwardAnalyticsGate _gate(
  AppDatabase database,
  AnalyticsService analytics,
) => PointsAwardAnalyticsGate(
  database: database,
  activeUserId: 'user-1',
  analytics: analytics,
  clock: () => DateTime.utc(2026, 9, 2),
);

Future<void> _storeLedger(
  AppDatabase database,
  List<Map<String, Object?>> ledger,
) => database
    .into(database.localProgressProjections)
    .insertOnConflictUpdate(
      LocalProgressProjectionsCompanion.insert(
        userId: 'user-1',
        projectionType: 'points',
        payloadJson: jsonEncode(ledger),
        serverUpdatedAt: DateTime.utc(2026, 9, 2),
      ),
    );

Map<String, Object?> _award(
  String id, {
  String sourceId = 'session-id',
  String userId = 'user-1',
}) => <String, Object?>{
  'id': id,
  'user_id': userId,
  'points': 10,
  'rule_version': 'points_completion_v1',
  'source_type': 'session',
  'source_id': sourceId,
};

final class _ThrowingAnalyticsService implements AnalyticsService {
  @override
  bool get isEnabled => true;

  @override
  void setEnabled(bool enabled) {}

  @override
  void track(AnalyticsEvent event) => throw StateError('transport failure');
}

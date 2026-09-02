import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';

import '../domain/gamification_repository.dart';
import '../domain/weekly_goal_progress.dart';
import 'timezone_movement_date_resolver.dart';

/// Drift-backed local view of RAHA-070 progress. It never creates ledger rows;
/// authoritative server projections replace its estimates after synchronization.
final class DriftGamificationRepository implements GamificationRepository {
  DriftGamificationRepository(
    this._database, {
    required this.activeUserId,
    TimezoneMovementDateResolver? dateResolver,
    DateTime Function()? clock,
  }) : _dateResolver = dateResolver ?? TimezoneMovementDateResolver(),
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final String activeUserId;
  final TimezoneMovementDateResolver _dateResolver;
  final DateTime Function() _clock;

  @override
  Future<WeeklyGoalProgress> currentWeeklyGoal({String? userId}) async {
    final owner = userId ?? activeUserId;
    if (owner != activeUserId) {
      throw StateError('Gamification repository is bound to one active user');
    }
    final profile = await (_database.select(
      _database.localProfiles,
    )..where((row) => row.userId.equals(owner))).getSingleOrNull();
    if (profile == null) throw StateError('Profile not found for active user');

    final currentDate = _dateResolver.resolve(
      _clock().toUtc(),
      profile.timezone,
    );
    final weekStart = currentDate.monday;
    final authoritative = await _authoritativeWeeklyProgress(owner, weekStart);
    final sessions =
        await (_database.select(_database.localRoutineSessions)..where(
              (row) =>
                  row.userId.equals(owner) & row.status.equals('completed'),
            ))
            .get();
    final movementDays = <MovementDate>{};
    var pendingPointAwards = 0;
    final confirmedCompletionSources = authoritative == null
        ? const <String>{}
        : await _confirmedCompletionSources(owner);
    for (final session in sessions) {
      final completedAt = session.completedAt;
      if (completedAt == null) continue;
      final sessionTimezone = session.completedTimezone ?? profile.timezone;
      final day = _dateResolver.resolve(completedAt, sessionTimezone);
      if (day.monday != weekStart) continue;
      // A ledger source is the server's idempotency identity for a completion.
      // It is stronger than the local sync state: a response can have been
      // accepted before the local outbox cleanup runs.
      if (confirmedCompletionSources.contains(session.id)) continue;
      if (session.syncState != SyncState.synced) {
        movementDays.add(day);
        pendingPointAwards++;
      }
    }
    if (authoritative != null) {
      final authoritativeDates = await _authoritativeMovementDates(owner);
      // The server projection remains the authority. Only unresolved local
      // completions are layered on top so an offline completion is visible
      // immediately; source IDs prevent it being added again after sync.
      return WeeklyGoalProgress(
        weekStart: authoritative.weekStart,
        goalDays: authoritative.goalDays,
        movementDays: authoritativeDates.isEmpty
            ? authoritative.movementDays + movementDays.length
            : {...authoritativeDates, ...movementDays}.length,
        pendingPointAwards: pendingPointAwards,
        isAuthoritative: pendingPointAwards == 0,
        confirmedPoints: authoritative.confirmedPoints,
      );
    }
    return WeeklyGoalProgress(
      weekStart: weekStart,
      goalDays: validatedWeeklyGoalDays(profile.weeklyGoalDays),
      movementDays: movementDays.length,
      pendingPointAwards: pendingPointAwards,
      isAuthoritative: false,
    );
  }

  Future<WeeklyGoalProgress?> _authoritativeWeeklyProgress(
    String owner,
    MovementDate expectedWeekStart,
  ) async {
    final row =
        await (_database.select(_database.localProgressProjections)..where(
              (projection) =>
                  projection.userId.equals(owner) &
                  projection.projectionType.equals('weekly_progress'),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    final payload = _decodeMap(row.payloadJson);
    if (payload == null) return null;
    final weekStart = _movementDateFromServerTimestamp(
      payload['week_start'],
      payload['timezone'],
    );
    final goalDays = _asInt(payload['goal_days']);
    final movementDays = _asInt(payload['movement_days']);
    if (weekStart == null ||
        weekStart != expectedWeekStart ||
        goalDays == null ||
        movementDays == null) {
      return null;
    }
    final confirmedPoints = await _confirmedPoints(owner);
    return WeeklyGoalProgress(
      weekStart: weekStart,
      goalDays: validatedWeeklyGoalDays(goalDays),
      movementDays: movementDays,
      pendingPointAwards: 0,
      isAuthoritative: true,
      confirmedPoints: confirmedPoints,
    );
  }

  Future<int?> _confirmedPoints(String owner) async {
    final row =
        await (_database.select(_database.localProgressProjections)..where(
              (projection) =>
                  projection.userId.equals(owner) &
                  projection.projectionType.equals('points'),
            ))
            .getSingleOrNull();
    final value = row == null ? null : _decodeJson(row.payloadJson);
    if (value == null) return null;
    if (value is Map) {
      // The server's balance projection is authoritative when supplied. Do not
      // infer a total from local completions or any client-created value.
      final balance = _asInt(value['points_balance']);
      if (balance != null) return balance;
    }
    // `points` is otherwise the server's append-only ledger array. Include
    // corrections (negative entries) exactly as returned by the server.
    final ledger = value is List
        ? value
        : (value is Map ? value['points'] : null);
    if (ledger is! List) return null;
    return ledger.fold<int>(0, (sum, entry) {
      if (entry is! Map) return sum;
      return sum + (_asInt(entry['points']) ?? 0);
    });
  }

  Future<Set<String>> _confirmedCompletionSources(String owner) async {
    final row =
        await (_database.select(_database.localProgressProjections)..where(
              (projection) =>
                  projection.userId.equals(owner) &
                  projection.projectionType.equals('points'),
            ))
            .getSingleOrNull();
    final value = row == null ? null : _decodeJson(row.payloadJson);
    final ledger = value is List
        ? value
        : (value is Map ? value['points'] : null);
    if (ledger is! List) return const <String>{};
    return ledger
        .whereType<Map>()
        .where((entry) => entry['source_type'] == 'session')
        .map((entry) => entry['source_id'])
        .whereType<String>()
        .toSet();
  }

  Future<Set<MovementDate>> _authoritativeMovementDates(String owner) async {
    final row = await (_database.select(_database.localProgressProjections)
          ..where(
            (projection) =>
                projection.userId.equals(owner) &
                projection.projectionType.equals('weekly_progress'),
          ))
        .getSingleOrNull();
    final dates = row == null ? null : _decodeMap(row.payloadJson)?['movement_dates'];
    if (dates is! List) return const <MovementDate>{};
    return dates
        .whereType<String>()
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((value) => MovementDate(value.year, value.month, value.day))
        .toSet();
  }

  Map<String, dynamic>? _decodeMap(String source) {
    final value = _decodeJson(source);
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Object? _decodeJson(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      return null;
    }
  }

  /// The server emits [weekStart] as a timestamptz. Resolving its instant in the
  /// payload's IANA timezone is essential: a Sunday UTC instant can be Monday
  /// in a positive-offset timezone. Never parse it as a device-local date.
  MovementDate? _movementDateFromServerTimestamp(
    Object? weekStart,
    Object? timezone,
  ) {
    if (weekStart is! String || timezone is! String || timezone.isEmpty) {
      return null;
    }
    final instant = DateTime.tryParse(weekStart);
    if (instant == null) return null;
    return _dateResolver.resolve(instant, timezone);
  }

  int? _asInt(Object? value) => switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}

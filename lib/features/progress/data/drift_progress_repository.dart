import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/gamification/data/timezone_movement_date_resolver.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';

import '../domain/progress_repository.dart';
import '../domain/progress_summary.dart';

/// Reads completed-session history from Drift. It deliberately derives all
/// figures from stable session IDs, preventing a synced acknowledgement from
/// being displayed as a second completion.
final class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(
    this._database, {
    required this.activeUserId,
    TimezoneMovementDateResolver? dateResolver,
  }) : _dateResolver = dateResolver ?? TimezoneMovementDateResolver();

  final AppDatabase _database;
  final String activeUserId;
  final TimezoneMovementDateResolver _dateResolver;

  @override
  Stream<ProgressSummary> watchWeeklySummary({
    required MovementDate weekStart,
    required String locale,
  }) async* {
    // Watching the joined tables means session finalization, feedback, content,
    // profile timezone, or a projection-only sync refreshes the read model.
    await for (final _
        in _database
            .customSelect(
              '''SELECT COUNT(*) AS revision
         FROM local_routine_sessions s
         LEFT JOIN local_session_feedback f ON f.session_id = s.id
         LEFT JOIN local_routine_translations t ON t.routine_id = s.routine_id
         LEFT JOIN local_routine_taxonomies rt ON rt.routine_id = s.routine_id
         LEFT JOIN local_taxonomy_translations tt ON tt.taxonomy_key = rt.taxonomy_key
         WHERE s.user_id = ?''',
              variables: [Variable.withString(activeUserId)],
              readsFrom: {
                _database.localRoutineSessions,
                _database.localSessionFeedback,
                _database.localRoutineTranslations,
                _database.localRoutineTaxonomies,
                _database.localTaxonomyTranslations,
                _database.localTaxonomies,
                _database.localProfiles,
                _database.localProgressProjections,
              },
            )
            .watch()) {
      yield await _load(weekStart: weekStart, locale: locale);
    }
  }

  Future<ProgressSummary> _load({
    required MovementDate weekStart,
    required String locale,
  }) async {
    final profile = await (_database.select(
      _database.localProfiles,
    )..where((row) => row.userId.equals(activeUserId))).getSingleOrNull();
    if (profile == null) throw StateError('Profile not found for active user');

    final sessions =
        await (_database.select(_database.localRoutineSessions)..where(
              (row) =>
                  row.userId.equals(activeUserId) &
                  row.status.equals('completed'),
            ))
            .get();
    final localWeekSessions = sessions.where((session) {
      final completedAt = session.completedAt;
      if (completedAt == null) return false;
      final timezone = session.completedTimezone ?? profile.timezone;
      return _dateResolver.resolve(completedAt, timezone).monday == weekStart;
    }).toList()..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    final authority = await _authoritativeWeek(weekStart);
    final pending = localWeekSessions.where((session) {
      // Failed and pending-delete rows are neither trusted totals nor pending
      // confirmations. Only an unresolved upsert is eligible for the overlay.
      return session.syncState == SyncState.pendingCreate ||
          session.syncState == SyncState.pendingUpdate;
    }).toList();
    // Detailed progress has no server projection contract. It is always read
    // from valid local completed sessions, whose primary key prevents a synced
    // acknowledgement from becoming a second history entry.
    final visibleHistory = localWeekSessions
        .where(
          (session) =>
              session.syncState != SyncState.failed &&
              session.syncState != SyncState.pendingDelete,
        )
        .toList();

    final feedbackRows = await (_database.select(
      _database.localSessionFeedback,
    )..where((row) => row.userId.equals(activeUserId))).get();
    final feedbackBySession = {
      for (final row in feedbackRows) row.sessionId: row,
    };
    final routineNames = await _routineNames(visibleHistory, locale);
    final localAreaLabels = await _bodyAreas(visibleHistory, locale);
    var muchBetter = 0;
    var littleBetter = 0;
    var same = 0;
    var lessComfortable = 0;
    for (final session in localWeekSessions) {
      switch (feedbackBySession[session.id]?.rating) {
        case 'much_better':
          muchBetter++;
        case 'little_better':
          littleBetter++;
        case 'same':
          same++;
        case 'less_comfortable':
          lessComfortable++;
        case null:
          break;
        default:
          break;
      }
    }
    final pendingDays = <MovementDate>{
      for (final session in pending)
        _dateResolver.resolve(
          session.completedAt!,
          session.completedTimezone ?? profile.timezone,
        ),
    };
    final authoritativeDays = authority.movementDates;
    final localMovementDays = <MovementDate>{
      for (final session in visibleHistory)
        _dateResolver.resolve(
          session.completedAt!,
          session.completedTimezone ?? profile.timezone,
        ),
    };
    final movementDays = authority.hasExactMovementDates
        ? {...authoritativeDays!, ...pendingDays}.length
        : localMovementDays.length;
    final localActiveSeconds = visibleHistory.fold<int>(
      0,
      (sum, session) => sum + session.actualDurationSeconds,
    );
    return ProgressSummary(
      weekStart: weekStart,
      weeklyGoalDays:
          authority.goalDays ?? validatedWeeklyGoalDays(profile.weeklyGoalDays),
      movementDays: movementDays,
      verifiedActiveSeconds: localActiveSeconds,
      completedRoutines: visibleHistory.length,
      bodyAreas: localAreaLabels,
      feedback: FeedbackTrend(
        muchBetter: muchBetter,
        littleBetter: littleBetter,
        same: same,
        lessComfortable: lessComfortable,
      ),
      recentHistory: visibleHistory
          .take(10)
          .map(
            (session) => CompletedRoutineHistory(
              sessionId: session.id,
              routineName: routineNames[session.routineId],
              completedDay: _dateResolver.resolve(
                session.completedAt!,
                session.completedTimezone ?? profile.timezone,
              ),
              verifiedActiveSeconds: session.actualDurationSeconds,
              isProvisional: pending.contains(session),
            ),
          )
          .toList(growable: false),
      hasProvisionalProgress: pending.isNotEmpty,
    );
  }

  Future<_WeeklyAuthority> _authoritativeWeek(MovementDate expectedWeek) async {
    final row =
        await (_database.select(_database.localProgressProjections)..where(
              (item) =>
                  item.userId.equals(activeUserId) &
                  item.projectionType.equals('weekly_progress'),
            ))
            .getSingleOrNull();
    if (row == null) return const _WeeklyAuthority.absent();
    try {
      final value = jsonDecode(row.payloadJson);
      if (value is! Map<String, dynamic>) {
        return const _WeeklyAuthority.absent();
      }
      final json = value;
      final timezone = json['timezone'];
      final timestamp = json['week_start'];
      if (timezone is! String || timestamp is! String) {
        return const _WeeklyAuthority.absent();
      }
      final parsed = DateTime.tryParse(timestamp);
      if (parsed == null ||
          _dateResolver.resolve(parsed, timezone) != expectedWeek) {
        return const _WeeklyAuthority.absent();
      }
      final movementDates = json['movement_dates'];
      final dates = movementDates is List
          ? movementDates
                .whereType<String>()
                .map(DateTime.tryParse)
                .whereType<DateTime>()
                .map((date) => MovementDate(date.year, date.month, date.day))
                .toSet()
          : null;
      final goal = _asIntOrNull(json['goal_days']);
      return _WeeklyAuthority(
        movementDays: _asInt(json['movement_days']),
        goalDays: goal == null ? null : validatedWeeklyGoalDays(goal),
        movementDates: dates,
      );
    } on Object {
      return const _WeeklyAuthority.absent();
    }
  }

  int _asInt(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  int? _asIntOrNull(Object? value) => value == null ? null : _asInt(value);

  Future<Map<String, String>> _routineNames(
    List<LocalRoutineSession> sessions,
    String locale,
  ) async {
    final result = <String, String>{};
    for (final routineId in sessions.map((row) => row.routineId).toSet()) {
      final preferred =
          await (_database.select(_database.localRoutineTranslations)..where(
                (row) =>
                    row.routineId.equals(routineId) & row.locale.equals(locale),
              ))
              .getSingleOrNull();
      final fallback =
          preferred ??
          await (_database.select(_database.localRoutineTranslations)..where(
                (row) =>
                    row.routineId.equals(routineId) & row.locale.equals('en'),
              ))
              .getSingleOrNull();
      if (fallback != null) result[routineId] = fallback.name;
    }
    return result;
  }

  Future<List<ProgressBodyArea>> _bodyAreas(
    List<LocalRoutineSession> sessions,
    String locale,
  ) async {
    final keys = <String>{};
    for (final session in sessions) {
      final rows = await (_database.select(
        _database.localRoutineTaxonomies,
      )..where((row) => row.routineId.equals(session.routineId))).get();
      for (final row in rows) {
        final taxonomy = await (_database.select(
          _database.localTaxonomies,
        )..where((item) => item.key.equals(row.taxonomyKey))).getSingleOrNull();
        if (taxonomy?.kind == 'body_area') keys.add(row.taxonomyKey);
      }
    }
    return _bodyAreasForKeys(keys, locale);
  }

  Future<List<ProgressBodyArea>> _bodyAreasForKeys(
    Set<String> keys,
    String locale,
  ) async {
    final areas = <ProgressBodyArea>[];
    for (final key in keys) {
      final label =
          await (_database.select(_database.localTaxonomyTranslations)..where(
                (row) =>
                    row.taxonomyKey.equals(key) & row.locale.equals(locale),
              ))
              .getSingleOrNull();
      final fallback =
          label ??
          await (_database.select(_database.localTaxonomyTranslations)..where(
                (row) => row.taxonomyKey.equals(key) & row.locale.equals('en'),
              ))
              .getSingleOrNull();
      if (fallback != null) {
        areas.add(ProgressBodyArea(key: key, label: fallback.label));
      }
    }
    areas.sort((a, b) => a.label.compareTo(b.label));
    return areas;
  }
}

final class _WeeklyAuthority {
  const _WeeklyAuthority({
    required this.movementDays,
    required this.goalDays,
    required this.movementDates,
  }) : isPresent = true;

  const _WeeklyAuthority.absent()
    : movementDays = 0,
      goalDays = null,
      movementDates = null,
      isPresent = false;

  final int movementDays;
  final int? goalDays;
  final Set<MovementDate>? movementDates;
  final bool isPresent;

  bool get hasExactMovementDates =>
      isPresent &&
      movementDates != null &&
      movementDays == movementDates!.length;
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/check_in/data/drift_check_in_repository.dart';
import 'package:raha_move/features/check_in/domain/body_state.dart';
import 'package:raha_move/features/check_in/domain/check_in_answers.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2026, 8, 30, 12);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await _seed(database, now);
  });

  tearDown(() => database.close());

  DriftCheckInRepository repository() =>
      DriftCheckInRepository(database, clock: () => now);

  CheckInAnswers answers({
    String? positionKey = 'seated',
    Set<String> bodyAreaKeys = const {'neck', 'shoulders'},
  }) => CheckInAnswers(
    bodyState: BodyState.stiff,
    goalKey: 'ease_stiffness',
    bodyAreaKeys: bodyAreaKeys,
    availableMinutes: 5,
    positionKey: positionKey,
  );

  test('persists one complete check-in with its body areas', () async {
    await repository().save(
      userId: 'user-1',
      checkInId: 'check-in-1',
      startedAt: now.subtract(const Duration(minutes: 1)),
      answers: answers(),
    );

    final row = await (database.select(
      database.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).getSingle();
    expect(row.userId, 'user-1');
    expect(row.bodyState, 'stiff');
    expect(row.goalKey, 'ease_stiffness');
    expect(row.availableMinutes, 5);
    expect(row.positionKey, 'seated');
    expect(row.startedAt.toUtc(), now.subtract(const Duration(minutes: 1)));
    expect(row.completedAt!.toUtc(), now);

    final areas = await database.select(database.localCheckInBodyAreas).get();
    expect(areas.map((a) => a.bodyAreaKey).toSet(), {'neck', 'shoulders'});
  });

  test('persists a null position key for "any position"', () async {
    await repository().save(
      userId: 'user-1',
      checkInId: 'check-in-any',
      startedAt: now,
      answers: answers(positionKey: null),
    );

    final row = await (database.select(
      database.localCheckIns,
    )..where((r) => r.id.equals('check-in-any'))).getSingle();
    expect(row.positionKey, isNull);
  });

  test('re-saving the same id updates in place without duplicating', () async {
    final repo = repository();
    await repo.save(
      userId: 'user-1',
      checkInId: 'check-in-1',
      startedAt: now,
      answers: answers(),
    );
    await repo.save(
      userId: 'user-1',
      checkInId: 'check-in-1',
      startedAt: now,
      answers: answers(bodyAreaKeys: const {'hips'}),
    );

    final rows = await (database.select(
      database.localCheckIns,
    )..where((r) => r.id.equals('check-in-1'))).get();
    expect(rows, hasLength(1));

    final areas = await database.select(database.localCheckInBodyAreas).get();
    expect(areas.map((a) => a.bodyAreaKey).toSet(), {'hips'});
  });
}

Future<void> _seed(AppDatabase database, DateTime now) async {
  for (final (key, kind) in const [
    ('neck', 'body_area'),
    ('shoulders', 'body_area'),
    ('upper_back', 'body_area'),
    ('lower_back', 'body_area'),
    ('hips', 'body_area'),
    ('knees', 'body_area'),
    ('full_body', 'body_area'),
    ('ease_stiffness', 'goal'),
    ('move_more_freely', 'goal'),
    ('feel_energized', 'goal'),
    ('relax', 'goal'),
    ('desk_break', 'goal'),
    ('seated', 'position'),
    ('standing', 'position'),
    ('floor', 'position'),
  ]) {
    await database
        .into(database.localTaxonomies)
        .insert(LocalTaxonomiesCompanion.insert(key: key, kind: kind));
  }

  await database
      .into(database.localProfiles)
      .insert(
        LocalProfilesCompanion.insert(
          userId: 'user-1',
          preferredLocale: 'en',
          timezone: 'Asia/Riyadh',
          weeklyGoalDays: 3,
          localUpdatedAt: now,
        ),
      );
}

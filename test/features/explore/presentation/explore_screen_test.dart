import 'dart:ui' show SemanticsAction;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/theme/app_theme.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_routine_details_screen.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';
import 'package:raha_move/features/saved_routines/application/saved_routines_providers.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routine.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routines_repository.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';

void main() {
  testWidgets('unfiltered Explore remains usable in both locales at 200%', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await _pumpExplore(tester, locale, const _PopulatedRepository());
      await tester.pumpAndSettle();

      final card = find.byKey(const Key('explore_routine_routine'));
      expect(card, findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(ExploreScreen))),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      final cardSemantics = tester.getSemantics(card).getSemanticsData();
      expect(cardSemantics.hasAction(SemanticsAction.tap), isTrue);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byKey(const Key('explore_saved_routines')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('explore_card_duration')),
        150,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'all exercises remain readable and Start stays reachable while scrolling',
    (tester) async {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        final source = _allowedDetails(locale);
        final details = source.copyWith(
          bodyAreas: {'shoulders'},
          presentation: source.presentation.copyWith(
            movements: List.generate(
              8,
              (index) => MovementPreviewEntry(
                name: locale.languageCode == 'ar'
                    ? 'حركة هادئة للكتفين مع التنفس ببطء ${index + 1}'
                    : 'Gentle shoulder movement with slow breathing ${index + 1}',
                durationSeconds: 30 + index * 5,
              ),
            ),
          ),
        );
        await _pumpDetails(tester, locale, details);
        await tester.pumpAndSettle();
        final start = find.byKey(const Key('explore_start'));
        expect(start.hitTestable(), findsOneWidget);
        final position = tester.getTopLeft(start);
        final artwork = tester.widget<Image>(
          find.byKey(const Key('explore_details_artwork')),
        );
        expect((artwork.image as AssetImage).assetName, contains('SHOULDERS'));
        for (var index = 0; index < 8; index++) {
          final row = find.byKey(Key('explore_movement_$index'));
          await tester.scrollUntilVisible(
            row,
            160,
            scrollable: find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          );
          expect(row, findsOneWidget);
          expect(start.hitTestable(), findsOneWidget);
          expect(tester.getTopLeft(start), position);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
  testWidgets('details metadata and blocked start are accessible at 200%', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await _pumpDetails(tester, locale, _details(locale));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('explore_details_name')), findsOneWidget);
      expect(find.byKey(const Key('explore_details_artwork')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('explore_details_equipment')),
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(
        find.byKey(const Key('explore_details_equipment')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('explore_start_blocked')), findsOneWidget);
      expect(find.byKey(const Key('explore_details_save')), findsNothing);
      final start = find.byKey(const Key('explore_start'));
      expect(start, findsOneWidget);
      expect(
        tester
            .getSemantics(start)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('explore_details_equipment')))
            .getSemanticsData()
            .label,
        contains(locale.languageCode == 'ar' ? 'بدون أدوات' : 'No equipment'),
      );
      expect(
        Directionality.of(
          tester.element(find.byType(ExploreRoutineDetailsScreen)),
        ),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      await tester.ensureVisible(start);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'details save control changes immediately between save and unsave',
    (tester) async {
      await _pumpDetails(
        tester,
        const Locale('en'),
        _allowedDetails(const Locale('en')),
      );
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('explore_details_save'));
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Remove from saved'), findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Save routine'), findsOneWidget);
    },
  );

  testWidgets('ineligible details never render a save control', (tester) async {
    for (final reason in RoutineStartBlock.values) {
      final source = _details(const Locale('en'));
      final details = ExploreRoutineDetails(
        presentation: source.presentation,
        eligibility: RoutineStartEligibility.blocked(reason),
        equipmentLabels: source.equipmentLabels,
      );
      await _pumpDetails(tester, const Locale('en'), details);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('explore_details_save')), findsNothing);
      expect(find.byKey(const Key('explore_start_blocked')), findsOneWidget);
    }
  });

  testWidgets(
    'save control is disabled with preserved semantics while pending',
    (tester) async {
      final repository = _DelayedSavedRepository();
      await _pumpDetails(
        tester,
        const Locale('en'),
        _allowedDetails(const Locale('en')),
        savedRepository: repository,
      );
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('explore_details_save'));
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(save);
      await tester.pump();
      expect(repository.saveCalls, 1);
      expect(
        tester
            .getSemantics(save)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      repository.completeSave();
      await tester.pumpAndSettle();
      expect(find.text('Remove from saved'), findsOneWidget);
    },
  );

  testWidgets('routine retry recovers and empty state has no filter actions', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      final repository = _RecoveringRoutinesRepository();
      await _pumpExplore(tester, locale, repository);
      await tester.pumpAndSettle();
      final retry = find.byKey(const Key('explore_retry'));
      expect(retry, findsOneWidget);
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(repository.reads, 2);
      expect(find.byKey(const Key('explore_retry')), findsNothing);
      expect(find.byKey(const Key('explore_saved_routines')), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _pumpExplore(
  WidgetTester tester,
  Locale locale,
  ExploreRepository repository,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 640);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(repository),
        exploreLocaleProvider.overrideWithValue(locale),
        activeUserIdProvider.overrideWithValue('user'),
        savedRoutinesRepositoryProvider.overrideWithValue(
          const _SavedRepository(),
        ),
      ],
      child: _app(locale, const ExploreScreen(initialBodyArea: 'neck')),
    ),
  );
}

Future<void> _pumpDetails(
  WidgetTester tester,
  Locale locale,
  ExploreRoutineDetails details, {
  SavedRoutinesRepository savedRepository = const _SavedRepository(),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 640);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(
          _DetailsRepository(details),
        ),
        exploreLocaleProvider.overrideWithValue(locale),
        activeUserIdProvider.overrideWithValue('user'),
        savedRoutinesRepositoryProvider.overrideWithValue(savedRepository),
      ],
      child: _app(
        locale,
        const ExploreRoutineDetailsScreen(routineId: 'routine'),
      ),
    ),
  );
}

Widget _app(Locale locale, Widget home) => MaterialApp(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.forLocale(locale),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
    child: child!,
  ),
  home: home,
);

ExploreRoutineDetails _details(Locale locale) {
  final arabic = locale.languageCode == 'ar';
  return ExploreRoutineDetails(
    presentation: RoutinePresentation(
      routineId: 'routine',
      name: arabic ? 'استراحة الكتفين' : 'Shoulder reset',
      summary: arabic ? 'استراحة هادئة.' : 'A calm reset.',
      movements: [
        MovementPreviewEntry(
          name: arabic ? 'دوائر الكتفين' : 'Shoulder circles',
          durationSeconds: 60,
        ),
      ],
      difficulty: DifficultyLevel.beginner,
      estimatedDurationSeconds: 60,
      positions: const {'seated'},
      equipment: const {'body_weight'},
    ),
    eligibility: const RoutineStartEligibility.blocked(
      RoutineStartBlock.unavailable,
    ),
    equipmentLabels: {'body_weight': arabic ? 'بدون أدوات' : 'No equipment'},
  );
}

ExploreRoutineDetails _allowedDetails(Locale locale) {
  final details = _details(locale);
  return ExploreRoutineDetails(
    presentation: details.presentation,
    eligibility: const RoutineStartEligibility.allowed(),
    equipmentLabels: details.equipmentLabels,
  );
}

class _EmptyExploreRepository implements ExploreRepository {
  const _EmptyExploreRepository();
  @override
  Future<List<ExploreCategory>> categories(String locale) async => const [];
  @override
  Future<List<ExploreRoutineCard>> browse({
    required String locale,
    String? context,
    required ExploreFilters filters,
  }) async => const [];
  @override
  Future<ExploreRoutineDetails?> details(
    String routineId,
    String locale,
  ) async => null;
}

class _PopulatedRepository extends _EmptyExploreRepository {
  const _PopulatedRepository();
  @override
  Future<List<ExploreRoutineCard>> browse({
    required String locale,
    String? context,
    required ExploreFilters filters,
  }) async => [
    ExploreRoutineCard(
      routineId: 'routine',
      name: locale == 'ar' ? 'استراحة الكتفين' : 'Shoulder reset',
      summary: locale == 'ar' ? 'استراحة هادئة.' : 'A calm routine.',
      durationSeconds: 300,
      difficulty: DifficultyLevel.beginner,
      positions: const {'seated'},
      equipment: const {'body_weight'},
      movementCount: 1,
    ),
  ];
}

class _RecoveringRoutinesRepository extends _EmptyExploreRepository {
  int reads = 0;
  @override
  Future<List<ExploreRoutineCard>> browse({
    required String locale,
    String? context,
    required ExploreFilters filters,
  }) async {
    expect(context, isNull);
    expect(filters.isEmpty, isTrue);
    reads++;
    if (reads == 1) throw StateError('cache unavailable');
    return const [];
  }
}

class _DetailsRepository extends _EmptyExploreRepository {
  const _DetailsRepository(this.value);
  final ExploreRoutineDetails value;
  @override
  Future<ExploreRoutineDetails?> details(
    String routineId,
    String locale,
  ) async => value;
}

class _SavedRepository implements SavedRoutinesRepository {
  const _SavedRepository();
  @override
  Future<bool> isSaved({
    required String userId,
    required String routineId,
  }) async => false;
  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) async => const [];
  @override
  Future<void> save({
    required String userId,
    required String routineId,
  }) async {}
  @override
  Future<void> unsave({
    required String userId,
    required String routineId,
  }) async {}
}

class _DelayedSavedRepository extends _SavedRepository {
  final Completer<void> _saveCompleter = Completer<void>();
  int saveCalls = 0;

  @override
  Future<void> save({required String userId, required String routineId}) async {
    saveCalls++;
    await _saveCompleter.future;
  }

  void completeSave() => _saveCompleter.complete();
}

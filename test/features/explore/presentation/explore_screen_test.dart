import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/explore/presentation/explore_routine_details_screen.dart';
import 'package:raha_move/features/explore/presentation/explore_screen.dart';
import 'package:raha_move/features/recommendations/domain/routine_presentation.dart';

void main() {
  testWidgets('populated Explore and filter sheet remain usable at 200%', (
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
      expect(
        tester.getSemantics(find.byKey(const Key('explore_duration_filter'))),
        isNotNull,
      );

      await tester.tap(find.byKey(const Key('explore_duration_filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('explore_filter_apply')), findsOneWidget);
      expect(
        tester.getSemantics(find.byKey(const Key('explore_filter_apply'))),
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('explore_filter_apply')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('details metadata and blocked start are accessible at 200%', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await _pumpDetails(tester, locale, _details(locale));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('explore_details_name')), findsOneWidget);
      expect(
        find.byKey(const Key('explore_details_equipment')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('explore_start_blocked')), findsOneWidget);
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
      await tester.scrollUntilVisible(start, 200);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('category retry replaces the error with cached category data', (
    tester,
  ) async {
    final repository = _RecoveringCategoriesRepository();
    await _pumpExplore(tester, const Locale('en'), repository);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('explore_categories_retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('explore_categories_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('explore_category_desk')), findsOneWidget);
    expect(repository.categoryReads, 2);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpExplore(
  WidgetTester tester,
  Locale locale,
  ExploreRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(repository),
        exploreLocaleProvider.overrideWithValue(locale),
      ],
      child: _app(locale, const ExploreScreen()),
    ),
  );
}

Future<void> _pumpDetails(
  WidgetTester tester,
  Locale locale,
  ExploreRoutineDetails details,
) async {
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(
          _DetailsRepository(details),
        ),
        exploreLocaleProvider.overrideWithValue(locale),
      ],
      child: _app(
        locale,
        const ExploreRoutineDetailsScreen(routineId: 'routine'),
      ),
    ),
  );
}

Widget _app(Locale locale, Widget home) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(2)),
  child: MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
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

class _RecoveringCategoriesRepository extends _EmptyExploreRepository {
  int categoryReads = 0;
  @override
  Future<List<ExploreCategory>> categories(String locale) async {
    categoryReads++;
    if (categoryReads == 1) throw StateError('cache unavailable');
    return const [ExploreCategory(key: 'desk', label: 'Desk')];
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

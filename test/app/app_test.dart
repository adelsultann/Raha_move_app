import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/app.dart';
import 'package:raha_move/features/home/home_providers.dart';
import 'package:raha_move/features/explore/application/explore_providers.dart';
import 'package:raha_move/features/explore/domain/explore_models.dart';
import 'package:raha_move/features/gamification/domain/weekly_goal_progress.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/today/application/today_providers.dart';

import '../features/onboarding/support/onboarding_test_harness.dart';

void main() {
  testWidgets('renders the localized foundation screen in English', (
    tester,
  ) async {
    final container = buildOnboardingContainer(
      repository: FakeOnboardingRepository()..language = AppLanguage.en,
    );
    addTearDown(container.dispose);
    final todayContainer = ProviderContainer(
      parent: container,
      overrides: [
        homeCatalogProvider.overrideWith(
          (ref) async => const HomeCatalog([], {}),
        ),
        exploreRoutinesProvider(filters: const ExploreFilters())
            .overrideWith((ref) async => []),
        todayDashboardProvider.overrideWith(
          (ref) => Stream.value(_todayDashboard()),
        ),
      ],
    );
    addTearDown(todayContainer.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: todayContainer,
        child: const RahaMoveApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Make room for movement'), findsOneWidget);
  });

  testWidgets('renders Arabic with right-to-left directionality', (
    tester,
  ) async {
    final container = buildOnboardingContainer(
      repository: FakeOnboardingRepository()..language = AppLanguage.ar,
    );
    addTearDown(container.dispose);
    final todayContainer = ProviderContainer(
      parent: container,
      overrides: [
        homeCatalogProvider.overrideWith(
          (ref) async => const HomeCatalog([], {}),
        ),
        exploreRoutinesProvider(filters: const ExploreFilters())
            .overrideWith((ref) async => []),
        todayDashboardProvider.overrideWith(
          (ref) => Stream.value(_todayDashboard()),
        ),
      ],
    );
    addTearDown(todayContainer.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: todayContainer,
        child: const RahaMoveApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('امنح جسمك وقتًا للحركة'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });
}

TodayDashboard _todayDashboard() => TodayDashboard(
  weeklyGoal: const WeeklyGoalProgress(
    weekStart: MovementDate(2026, 9, 7),
    goalDays: 3,
    movementDays: 0,
    pendingPointAwards: 0,
    isAuthoritative: true,
  ),
  resumableRoutine: null,
  latestCompletedRoutine: null,
);

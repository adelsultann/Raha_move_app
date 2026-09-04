import 'dart:ui' show SemanticsAction;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/saved_routines/application/saved_routines_providers.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routine.dart';
import 'package:raha_move/features/saved_routines/domain/saved_routines_repository.dart';
import 'package:raha_move/features/saved_routines/presentation/saved_routines_screen.dart';
import 'package:raha_move/features/sync/application/sync_providers.dart';

void main() {
  testWidgets('shows populated saved history in RTL and LTR at compact 200%', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      final arabic = locale.languageCode == 'ar';
      await _pump(
        tester,
        locale,
        _Repository(
          items: [
            SavedRoutine(
              routineId: 'available',
              title: arabic ? 'روتين متاح' : 'Available routine',
              isPlayable: true,
            ),
            SavedRoutine(
              routineId: 'unavailable',
              title: arabic ? 'روتين غير متاح' : 'Unavailable routine',
              isPlayable: false,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('saved_routine_available')), findsOneWidget);
      expect(
        find.byKey(const Key('saved_routine_unavailable_message')),
        findsOneWidget,
      );
      expect(
        Directionality.of(tester.element(find.byType(SavedRoutinesScreen))),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('shows a loading state before saved routines arrive', (
    tester,
  ) async {
    final repository = _LoadingRepository();
    await _pump(tester, const Locale('en'), repository);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_routines_empty_title')), findsOneWidget);
  });

  testWidgets('shows unavailable history without a tappable playback path', (
    tester,
  ) async {
    await _pump(
      tester,
      const Locale('en'),
      const _Repository(
        items: [
          SavedRoutine(
            routineId: 'retired',
            title: 'Retired routine',
            isPlayable: false,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('saved_routine_retired'));
    expect(
      find.byKey(const Key('saved_routine_unavailable_message')),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(card)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
  });

  testWidgets('playable saved routine sends its stable ID to navigation', (
    tester,
  ) async {
    String? opened;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeUserIdProvider.overrideWithValue('user'),
          savedRoutinesRepositoryProvider.overrideWithValue(
            const _Repository(
              items: [
                SavedRoutine(
                  routineId: 'available',
                  title: 'Available routine',
                  isPlayable: true,
                ),
              ],
            ),
          ),
          savedRoutinesLocaleProvider.overrideWithValue(const Locale('en')),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SavedRoutinesScreen(onOpenRoutine: (id) => opened = id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved_routine_available')));
    expect(opened, 'available');
  });

  testWidgets('shows recoverable error and retry', (tester) async {
    final repository = _RecoveringRepository();
    await _pump(tester, const Locale('en'), repository);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved_routines_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_routines_empty_title')), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Locale locale,
  SavedRoutinesRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeUserIdProvider.overrideWithValue('user'),
        savedRoutinesRepositoryProvider.overrideWithValue(repository),
        savedRoutinesLocaleProvider.overrideWithValue(locale),
      ],
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SavedRoutinesScreen(),
        ),
      ),
    ),
  );
}

class _Repository implements SavedRoutinesRepository {
  const _Repository({this.items = const []});
  final List<SavedRoutine> items;
  @override
  Future<bool> isSaved({
    required String userId,
    required String routineId,
  }) async => false;
  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) async => items;
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

class _RecoveringRepository extends _Repository {
  int reads = 0;
  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) async {
    if (reads++ == 0) throw StateError('temporary');
    return const [];
  }
}

class _LoadingRepository extends _Repository {
  final Completer<List<SavedRoutine>> _completer =
      Completer<List<SavedRoutine>>();

  @override
  Future<List<SavedRoutine>> list({
    required String userId,
    required String locale,
  }) => _completer.future;

  void complete() => _completer.complete(const []);
}

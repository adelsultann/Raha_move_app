import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/reminders/application/reminder_providers.dart';
import 'package:raha_move/features/reminders/domain/reminder_repository.dart';
import 'package:raha_move/features/reminders/domain/reminder_schedule.dart';
import 'package:raha_move/features/reminders/presentation/reminder_settings_screen.dart';

void main() {
  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('reminder settings is accessible in ${locale.languageCode}', (
      tester,
    ) async {
      await tester.pumpWidget(_app(locale));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reminder_time')), findsOneWidget);
      expect(find.byKey(const Key('reminder_save')), findsOneWidget);
      expect(
        tester
            .widget<Directionality>(find.byType(Directionality).first)
            .textDirection,
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      final handle = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.byKey(const Key('reminder_save')))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      handle.dispose();
    });
  }

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets(
      'reminder settings remains usable at compact 200% scale in ${locale.languageCode}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(_app(locale, textScale: 2));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const Key('reminder_save')),
          200,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('reminder_save')), findsOneWidget);
        expect(
          tester
              .widget<Directionality>(find.byType(Directionality).first)
              .textDirection,
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
      },
    );
  }

  testWidgets('denied permission exposes accessible settings recovery', (
    tester,
  ) async {
    final platform = _Platform(status: ReminderPermission.denied);
    await tester.pumpWidget(_app(const Locale('en'), platform: platform));
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('reminder_open_settings'));
    expect(button, findsOneWidget);
    await tester.tap(button);
    expect(platform.openSettingsCalls, 1);
  });

  testWidgets('scheduling failure exposes retry action', (tester) async {
    final platform = _Platform(
      status: ReminderPermission.granted,
      failSchedule: true,
    );
    await tester.pumpWidget(_app(const Locale('en'), platform: platform));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reminder_save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reminder_retry_schedule')), findsOneWidget);
  });
}

Widget _app(Locale locale, {double textScale = 1, _Platform? platform}) =>
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        reminderRepositoryProvider.overrideWithValue(_Repo()),
        reminderPermissionStoreProvider.overrideWithValue(_Store()),
        reminderPlatformProvider.overrideWithValue(platform ?? _Platform()),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const ReminderSettingsScreen(),
        ),
      ),
    );

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async =>
      const AuthState(activeUserId: 'user', status: AuthStatus.anonymous);
}

class _Repo implements ReminderRepository {
  @override
  Future<ReminderSchedule?> read(String _) async => null;
  @override
  Future<void> save(ReminderSchedule _) async {}
  @override
  Future<void> remove(String _) async {}
}

class _Store implements ReminderPermissionStore {
  @override
  Future<bool> wasDenied(String _) async => false;
  @override
  Future<void> clearDenied(String _) async {}
  @override
  Future<void> recordDenied(String _) async {}
}

class _Platform implements ReminderPlatform {
  _Platform({
    this.status = ReminderPermission.notDetermined,
    this.failSchedule = false,
  });
  final ReminderPermission status;
  final bool failSchedule;
  var openSettingsCalls = 0;
  @override
  Future<void> cancel(String _) async {}
  @override
  Future<String> currentIanaTimezone() async => 'Asia/Riyadh';
  @override
  Future<ReminderPermission> permissionStatus() async => status;
  @override
  Future<void> openSettings() async => openSettingsCalls++;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule(
    ReminderSchedule _,
    ReminderNotificationContent content,
  ) async {
    if (failSchedule) throw StateError('schedule failed');
  }
}

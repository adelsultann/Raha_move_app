import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/onboarding/application/locale_controller.dart';
import 'package:raha_move/features/onboarding/domain/app_language.dart';
import 'package:raha_move/features/profile/application/profile_controller.dart';
import 'package:raha_move/features/profile/application/profile_providers.dart';
import 'package:raha_move/features/profile/domain/account_deletion_action.dart';
import 'package:raha_move/features/profile/domain/profile_settings.dart';
import 'package:raha_move/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('shows every Profile control in Arabic RTL on compact 200%', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_language')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_delete_account')),
      300,
    );
    expect(find.byKey(const Key('profile_delete_account')), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Profile controls in English LTR on compact 200%', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_language')), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_delete_account')),
      300,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'deletion confirmation exposes semantic actions and pending truth',
    (tester) async {
      await tester.pumpWidget(_app(const Locale('en'), deletion: _Deletion()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile_delete_account')),
        300,
      );
      await tester.tap(find.byKey(const Key('profile_delete_account')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_confirm_delete')), findsOneWidget);
      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(
        find.byKey(const Key('profile_confirm_delete')),
      );
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      handle.dispose();
      await tester.tap(find.byKey(const Key('profile_confirm_delete')));
      await tester.pumpAndSettle();
      expect(find.textContaining('deletion is scheduled'), findsOneWidget);
    },
  );

  testWidgets('failed setting save is visible and retryable', (tester) async {
    _FailingProfile.failures = 1;
    await tester.pumpWidget(_app(const Locale('en'), failing: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_sound')).last);
    await tester.pump();
    expect(find.byKey(const Key('profile_save_retry')), findsOneWidget);
    tester
        .widget<SnackBarAction>(find.byKey(const Key('profile_save_retry')))
        .onPressed();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_save_retry')), findsNothing);
  });
}

Widget _app(
  Locale locale, {
  AccountDeletionAction? deletion,
  bool failing = false,
}) => ProviderScope(
  overrides: [
    profileControllerProvider.overrideWith(
      failing ? _FailingProfile.new : _Profile.new,
    ),
    authControllerProvider.overrideWith(_Auth.new),
    localeControllerProvider.overrideWith(_Locale.new),
    accountDeletionActionProvider.overrideWithValue(
      deletion ?? const UnavailableAccountDeletionAction(),
    ),
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
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: ProfileScreen(
      onSavedRoutines: () {},
      onHelp: () {},
      onPrivacy: () {},
      onTerms: () {},
    ),
  ),
);

class _Profile extends ProfileController {
  static const value = ProfileSettings(
    language: AppLanguage.ar,
    weeklyGoalDays: 3,
    permittedPositions: {'seated'},
    soundEnabled: true,
    vibrationEnabled: true,
    wifiOnlyDownloads: true,
    reminderInterest: false,
    analyticsEnabled: false,
    crashReportingEnabled: false,
  );
  @override
  Future<ProfileSettings> build() async => value;
  @override
  Future<void> saveSettings(ProfileSettings settings) async {}
}

final class _FailingProfile extends _Profile {
  static var failures = 1;
  @override
  Future<void> saveSettings(ProfileSettings settings) async {
    if (failures-- > 0) throw StateError('offline');
  }
}

final class _Auth extends AuthController {
  @override
  Future<AuthState> build() async =>
      const AuthState(activeUserId: 'user', status: AuthStatus.anonymous);
}

final class _Locale extends LocaleController {
  @override
  Future<Locale> build() async => const Locale('ar');
  @override
  Future<void> selectLanguage(AppLanguage language) async {}
}

final class _Deletion implements AccountDeletionAction {
  @override
  Future<AccountDeletionResult> requestDeletion({
    required bool isRegisteredAccount,
  }) async => AccountDeletionResult.acceptedWithPendingCleanup;
}

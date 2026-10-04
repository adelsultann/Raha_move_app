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
import 'package:raha_move/features/profile/data/rpc_account_deletion_action.dart';
import 'package:raha_move/features/profile/domain/account_deletion_action.dart';
import 'package:raha_move/features/profile/domain/profile_settings.dart';
import 'package:raha_move/features/profile/presentation/profile_screen.dart';
import 'package:raha_move/features/profile/presentation/account_deletion_recovery_gate.dart';
import 'package:raha_move/app/theme/appearance_controller.dart';

void main() {
  testWidgets('profile shows requested account and settings sections', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const Key('profile_log_in')), findsOneWidget);
    expect(find.byKey(const Key('profile_create_account')), findsOneWidget);
    expect(find.byKey(const Key('profile_movement_experience')), findsNothing);
    expect(find.byKey(const Key('profile_weekly_goal')), findsNothing);
    expect(find.byKey(const Key('profile_positions')), findsNothing);
    expect(find.byKey(const Key('profile_analytics')), findsNothing);
    expect(find.byKey(const Key('profile_crash_reporting')), findsNothing);
  });

  testWidgets('shows every Profile control in Arabic RTL on compact 200%', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_language')),
      300,
    );
    expect(find.byKey(const Key('profile_language')), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_language')),
      300,
    );
    expect(find.byKey(const Key('profile_language')), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
    expect(find.byKey(const Key('profile_appearance')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows log in and create account to a guest in Arabic RTL', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_log_in')), findsOneWidget);
    expect(find.byKey(const Key('profile_create_account')), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets(
    'does not show the create-account prompt to an authenticated user',
    (tester) async {
      await tester.pumpWidget(
        _app(const Locale('en'), authStatus: AuthStatus.authenticated),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_log_in')), findsNothing);
      expect(find.byKey(const Key('profile_create_account')), findsNothing);
    },
  );

  testWidgets(
    'deletion confirmation exposes semantic actions and pending truth',
    (tester) async {
      await tester.pumpWidget(_app(const Locale('en'), deletion: _Deletion()));
      await tester.pumpAndSettle();
      final delete = find.byKey(const Key('profile_delete_account'));
      await tester.scrollUntilVisible(delete, 300);
      tester.widget<ListTile>(delete).onTap!();
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

  testWidgets('notifications opens the reminders entry', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_notifications')),
      200,
    );
    await tester.tap(find.byKey(const Key('profile_notifications')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_reminders')), findsOneWidget);
  });

  testWidgets('pending deletion cleanup shows localized retry control', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountDeletionRecoveryProvider.overrideWith(
            (_) async => AccountDeletionCleanupResult.pending,
          ),
        ],
        child: const AccountDeletionRecoveryGate(child: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('account_deletion_recovery_retry')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cleanup retry restores app only after recovery completes', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountDeletionRecoveryProvider.overrideWith(
            (_) async => attempts++ == 0
                ? AccountDeletionCleanupResult.pending
                : AccountDeletionCleanupResult.completed,
          ),
        ],
        child: const AccountDeletionRecoveryGate(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text('normal route'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finishing account cleanup'), findsOneWidget);
    expect(find.text('normal route'), findsNothing);
    await tester.tap(find.byKey(const Key('account_deletion_recovery_retry')));
    await tester.pumpAndSettle();
    expect(find.text('normal route'), findsOneWidget);
  });

  testWidgets('deletion recovery is localized and blocks its child in Arabic', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('ar');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountDeletionRecoveryProvider.overrideWith(
            (_) async => AccountDeletionCleanupResult.pending,
          ),
        ],
        child: const AccountDeletionRecoveryGate(child: Text('normal route')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نُكمل تنظيف الحساب'), findsOneWidget);
    expect(find.text('normal route'), findsNothing);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets(
    'language changes immediately while Profile route and user settings remain',
    (tester) async {
      await tester.pumpWidget(_languageApp());
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(
        tester
            .widget<Directionality>(find.byType(Directionality).first)
            .textDirection,
        TextDirection.ltr,
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('profile_language')),
        200,
      );
      await tester.tap(find.byKey(const Key('profile_language')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_language_ar')));
      await tester.pumpAndSettle();

      expect(find.text('اللغة'), findsOneWidget);
      expect(_EditableProfile.lastSaved?.language, AppLanguage.ar);
      expect(
        tester
            .widget<Directionality>(find.byType(Directionality).first)
            .textDirection,
        TextDirection.rtl,
      );
    },
  );

  testWidgets('appearance page offers light, dark and night choices', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_appearance')),
      200,
    );
    await tester.tap(find.byKey(const Key('profile_appearance')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_appearance_dark')), findsOneWidget);
    expect(find.byKey(const Key('profile_appearance_light')), findsOneWidget);
    expect(find.byKey(const Key('profile_appearance_night')), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile_appearance_night')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RadioGroup<AppAppearance>>(
            find.byType(RadioGroup<AppAppearance>),
          )
          .groupValue,
      AppAppearance.night,
    );
  });
}

Widget _app(
  Locale locale, {
  AccountDeletionAction? deletion,
  AuthStatus authStatus = AuthStatus.anonymous,
}) => ProviderScope(
  overrides: [
    profileControllerProvider.overrideWith(_Profile.new),
    authControllerProvider.overrideWith(() => _Auth(status: authStatus)),
    localeControllerProvider.overrideWith(_Locale.new),
    appearanceControllerProvider.overrideWith(_TestAppearance.new),
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
    ),
  ),
);

Widget _languageApp() => ProviderScope(
  overrides: [
    profileControllerProvider.overrideWith(_EditableProfile.new),
    authControllerProvider.overrideWith(_Auth.new),
    localeControllerProvider.overrideWith(_ImmediateLocale.new),
    appearanceControllerProvider.overrideWith(_TestAppearance.new),
  ],
  child: Consumer(
    builder: (context, ref, _) => MaterialApp(
      locale: ref.watch(localeControllerProvider).value,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ProfileScreen(
        onSavedRoutines: () {},
        onHelp: () {},
        onPrivacy: () {},
      ),
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

final class _Auth extends AuthController {
  _Auth({this.status = AuthStatus.anonymous});

  final AuthStatus status;

  @override
  Future<AuthState> build() async =>
      AuthState(activeUserId: 'user', status: status);
}

final class _Locale extends LocaleController {
  @override
  Future<Locale> build() async => const Locale('ar');
  @override
  Future<void> selectLanguage(AppLanguage language) async {}
}

final class _EditableProfile extends _Profile {
  static ProfileSettings? lastSaved;
  @override
  Future<ProfileSettings> build() async =>
      _Profile.value.copyWith(language: AppLanguage.en);

  @override
  Future<void> saveSettings(ProfileSettings settings) async {
    lastSaved = settings;
    state = AsyncData(settings);
  }
}

final class _ImmediateLocale extends LocaleController {
  @override
  Future<Locale> build() async => const Locale('en');

  @override
  Future<void> selectLanguage(AppLanguage language) async {
    state = AsyncData(Locale(language.code));
  }
}

final class _TestAppearance extends AppearanceController {
  @override
  Future<AppAppearance> build() async => AppAppearance.dark;

  @override
  Future<void> select(AppAppearance appearance) async {
    state = AsyncData(appearance);
  }
}

final class _Deletion implements AccountDeletionAction {
  @override
  Future<AccountDeletionResult> requestDeletion({
    required bool isRegisteredAccount,
  }) async => AccountDeletionResult.acceptedWithPendingCleanup;
}

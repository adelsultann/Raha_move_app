import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/application/auth_providers.dart';
import 'package:raha_move/features/authentication/domain/auth_account.dart';
import 'package:raha_move/features/authentication/domain/auth_failure.dart';
import 'package:raha_move/features/authentication/domain/auth_repository.dart';
import 'package:raha_move/features/authentication/domain/guest_identity_store.dart';
import 'package:raha_move/features/authentication/presentation/email_confirmation_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_in_screen.dart';
import 'package:raha_move/features/authentication/presentation/sign_up_screen.dart';

void main() {
  testWidgets('sign-in renders in English with LTR and stable controls', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const SignInScreen(), isConfigured: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_in_email')), findsOneWidget);
    expect(find.byKey(const Key('sign_in_password')), findsOneWidget);
    expect(find.byKey(const Key('sign_in_submit')), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('sign-in renders in Arabic with RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SignInScreen(),
        isConfigured: false,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('sign-in shows a localized invalid-credentials error', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SignInScreen(),
        isConfigured: true,
        emailError: const AuthFailureException(AuthFailure.invalidCredentials),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('sign_in_email')),
      'a@example.com',
    );
    await tester.enterText(find.byKey(const Key('sign_in_password')), 'wrong');
    await tester.tap(find.byKey(const Key('sign_in_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_in_error')), findsOneWidget);
    expect(find.text('The email or password is incorrect.'), findsOneWidget);
  });

  testWidgets('sign-in surfaces offline state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SignInScreen(),
        isConfigured: false,
        emailError: const AuthFailureException(AuthFailure.networkOffline),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('sign_in_email')),
      'a@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('sign_in_password')),
      'secret1',
    );
    await tester.tap(find.byKey(const Key('sign_in_submit')));
    await tester.pumpAndSettle();

    expect(
      find.text("You're offline. Please check your connection and try again."),
      findsOneWidget,
    );
  });

  testWidgets('sign-up renders in Arabic with RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SignUpScreen(),
        isConfigured: false,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_up_email')), findsOneWidget);
    expect(find.byKey(const Key('sign_up_password')), findsOneWidget);
    expect(find.text('أنشئ حسابك'), findsWidgets);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('sign-up shows an email-in-use error', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SignUpScreen(),
        isConfigured: true,
        signUpError: const AuthFailureException(AuthFailure.emailInUse),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('sign_up_email')),
      'a@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('sign_up_password')),
      'secret1',
    );
    await tester.tap(find.byKey(const Key('sign_up_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_up_error')), findsOneWidget);
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });

  testWidgets('confirmation renders the pending email and resend action', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EmailConfirmationScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email_confirmation_body')), findsOneWidget);
    expect(find.byKey(const Key('email_confirmation_resend')), findsOneWidget);
    expect(find.text('Check your email'), findsWidgets);
  });

  testWidgets('sign-in remains usable at 200% text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_wrap(const SignInScreen(), isConfigured: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_in_submit')), findsOneWidget);
    expect(find.byKey(const Key('sign_in_email')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(
  Widget child, {
  bool isConfigured = true,
  Locale? locale,
  AuthFailureException? emailError,
  AuthFailureException? signUpError,
}) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeRepository(
          isConfigured: isConfigured,
          emailError: emailError,
          signUpError: signUpError,
        ),
      ),
      guestIdentityStoreProvider.overrideWithValue(_FakeStore()),
    ],
  );
  addTearDown(container.dispose);

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

final class _FakeRepository implements AuthRepository {
  _FakeRepository({
    required this.isConfigured,
    this.emailError,
    this.signUpError,
  });

  @override
  final bool isConfigured;

  final AuthFailureException? emailError;
  final AuthFailureException? signUpError;

  @override
  Stream<AuthAccount?> watchAccount() => Stream<AuthAccount?>.value(null);

  @override
  Future<AuthAccount?> restoreSession() async => null;

  @override
  Future<AuthAccount> signInAnonymously() async =>
      const AuthAccount(id: 'anon-1', isAnonymous: true, emailConfirmed: false);

  @override
  Future<AuthAccount> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final error = emailError;
    if (error != null) throw error;
    return const AuthAccount(
      id: 'account-b',
      isAnonymous: false,
      emailConfirmed: true,
    );
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final error = signUpError;
    if (error != null) throw error;
    return SignUpOutcome.needsConfirmation(email);
  }

  @override
  Future<AuthAccount> convertAnonymousToEmail({
    required String email,
    required String password,
  }) async => throw const AuthFailureException(AuthFailure.networkOffline);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resendConfirmation({required String email}) async {}
}

final class _FakeStore implements GuestIdentityStore {
  String id = 'guest-1';

  @override
  Future<String> currentOrCreateGuestId() async => id;

  @override
  Future<String> currentLocalUserId() async => id;

  @override
  Future<void> ensureProfile(String userId) async {}

  @override
  Future<void> linkGuestToSupabaseUid({
    required String guestId,
    required String supabaseUid,
  }) async {
    if (guestId != supabaseUid) id = supabaseUid;
  }

  @override
  Future<void> activateAccount(String accountId) async {
    id = accountId;
  }

  @override
  Future<void> resetForSignOut() async {
    id = 'guest-fresh';
  }
}

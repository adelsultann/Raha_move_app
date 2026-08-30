// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Raha Move';

  @override
  String get foundationMessage =>
      'Your calm movement companion is getting ready.';

  @override
  String get catalogBootstrapLoading => 'Preparing your movement catalog…';

  @override
  String get catalogBootstrapError =>
      'We couldn\'t prepare your content right now.';

  @override
  String get catalogBootstrapRetry => 'Retry';

  @override
  String get authLoading => 'Preparing your space…';

  @override
  String get authInitError => 'We couldn\'t prepare your identity right now.';

  @override
  String get retry => 'Retry';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccountYet => 'New here? Create an account';

  @override
  String get emailConfirmationTitle => 'Check your email';

  @override
  String get checkYourEmail =>
      'We sent you a confirmation email. Please check your inbox to continue.';

  @override
  String emailConfirmationBody(String email) {
    return 'We sent a confirmation link to $email. Please confirm your email to continue.';
  }

  @override
  String get resendConfirmation => 'Resend confirmation';

  @override
  String get invalidCredentialsError => 'The email or password is incorrect.';

  @override
  String get emailInUseError => 'An account with this email already exists.';

  @override
  String get weakPasswordError => 'Please choose a stronger password.';

  @override
  String get offlineError =>
      'You\'re offline. Please check your connection and try again.';

  @override
  String get unconfirmedError => 'Please confirm your email before signing in.';

  @override
  String get authenticating => 'Please wait…';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get authFailedGeneric => 'Something went wrong. Please try again.';

  @override
  String get languageSelectionWelcomeArabic => 'مرحباً بك في راحة موف';

  @override
  String get languageSelectionWelcomeEnglish => 'Welcome to Raha Move';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLoading => 'Getting things ready…';

  @override
  String get onboardingError => 'We couldn\'t get things ready right now.';

  @override
  String get onboardingPageOneTitle => 'A routine chosen for you';

  @override
  String get onboardingPageOneBody =>
      'Tell us how your body feels, and we\'ll suggest a suitable short routine.';

  @override
  String get onboardingPageTwoTitle => 'Move on your schedule';

  @override
  String get onboardingPageTwoBody =>
      'Choose how much time you have, from a quick desk break to a longer mobility session.';

  @override
  String get onboardingPageThreeTitle => 'Build a comfortable habit';

  @override
  String get onboardingPageThreeBody =>
      'Track your consistency, notice how you feel, and celebrate every movement.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current of $total';
  }
}

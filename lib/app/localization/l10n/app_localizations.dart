import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Raha Move'**
  String get appTitle;

  /// No description provided for @foundationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your calm movement companion is getting ready.'**
  String get foundationMessage;

  /// No description provided for @catalogBootstrapLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your movement catalog…'**
  String get catalogBootstrapLoading;

  /// No description provided for @catalogBootstrapError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t prepare your content right now.'**
  String get catalogBootstrapError;

  /// No description provided for @catalogBootstrapRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get catalogBootstrapRetry;

  /// No description provided for @authLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your space…'**
  String get authLoading;

  /// No description provided for @authInitError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t prepare your identity right now.'**
  String get authInitError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccountYet;

  /// No description provided for @emailConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get emailConfirmationTitle;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent you a confirmation email. Please check your inbox to continue.'**
  String get checkYourEmail;

  /// No description provided for @emailConfirmationBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Please confirm your email to continue.'**
  String emailConfirmationBody(String email);

  /// No description provided for @resendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation'**
  String get resendConfirmation;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentialsError;

  /// No description provided for @emailInUseError.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get emailInUseError;

  /// No description provided for @weakPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get weakPasswordError;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Please check your connection and try again.'**
  String get offlineError;

  /// No description provided for @unconfirmedError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before signing in.'**
  String get unconfirmedError;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get authenticating;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @authFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authFailedGeneric;

  /// No description provided for @languageSelectionWelcomeArabic.
  ///
  /// In en, this message translates to:
  /// **'مرحباً بك في راحة موف'**
  String get languageSelectionWelcomeArabic;

  /// No description provided for @languageSelectionWelcomeEnglish.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Raha Move'**
  String get languageSelectionWelcomeEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboardingLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready…'**
  String get onboardingLoading;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get things ready right now.'**
  String get onboardingError;

  /// No description provided for @onboardingPageOneTitle.
  ///
  /// In en, this message translates to:
  /// **'A routine chosen for you'**
  String get onboardingPageOneTitle;

  /// No description provided for @onboardingPageOneBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us how your body feels, and we\'ll suggest a suitable short routine.'**
  String get onboardingPageOneBody;

  /// No description provided for @onboardingPageTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Move on your schedule'**
  String get onboardingPageTwoTitle;

  /// No description provided for @onboardingPageTwoBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how much time you have, from a quick desk break to a longer mobility session.'**
  String get onboardingPageTwoBody;

  /// No description provided for @onboardingPageThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a comfortable habit'**
  String get onboardingPageThreeTitle;

  /// No description provided for @onboardingPageThreeBody.
  ///
  /// In en, this message translates to:
  /// **'Track your consistency, notice how you feel, and celebrate every movement.'**
  String get onboardingPageThreeBody;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPageIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPageIndicator(int current, int total);

  /// No description provided for @preferencesBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get preferencesBack;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'A few quick preferences'**
  String get preferencesTitle;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us choose routines that suit you. You can change these anytime.'**
  String get preferencesSubtitle;

  /// No description provided for @preferencesExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'How familiar are you with movement?'**
  String get preferencesExperienceLabel;

  /// No description provided for @preferencesRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get preferencesRequired;

  /// No description provided for @preferencesExperienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'New to movement'**
  String get preferencesExperienceBeginner;

  /// No description provided for @preferencesExperienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Some experience'**
  String get preferencesExperienceIntermediate;

  /// No description provided for @preferencesExperienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Very comfortable'**
  String get preferencesExperienceAdvanced;

  /// No description provided for @preferencesPositionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Which positions work best for you?'**
  String get preferencesPositionsLabel;

  /// No description provided for @preferencesPositionsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose none if any position works.'**
  String get preferencesPositionsHint;

  /// No description provided for @preferencesPositionSeated.
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get preferencesPositionSeated;

  /// No description provided for @preferencesPositionStanding.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get preferencesPositionStanding;

  /// No description provided for @preferencesPositionFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get preferencesPositionFloor;

  /// No description provided for @preferencesWeeklyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'How many movement days each week feel right?'**
  String get preferencesWeeklyGoalLabel;

  /// No description provided for @preferencesDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'days per week'**
  String get preferencesDaysPerWeek;

  /// No description provided for @preferencesFewerDays.
  ///
  /// In en, this message translates to:
  /// **'Fewer days'**
  String get preferencesFewerDays;

  /// No description provided for @preferencesMoreDays.
  ///
  /// In en, this message translates to:
  /// **'More days'**
  String get preferencesMoreDays;

  /// No description provided for @preferencesReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders'**
  String get preferencesReminderLabel;

  /// No description provided for @preferencesReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge to move on your schedule.'**
  String get preferencesReminderSubtitle;

  /// No description provided for @preferencesContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get preferencesContinue;

  /// No description provided for @preferencesRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your experience level to continue.'**
  String get preferencesRequiredHint;

  /// No description provided for @preferencesSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your preferences. Please try again.'**
  String get preferencesSaveError;

  /// No description provided for @checkInBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get checkInBack;

  /// No description provided for @checkInStepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String checkInStepIndicator(int current, int total);

  /// No description provided for @checkInContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkInContinue;

  /// No description provided for @checkInRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Please choose an answer to continue.'**
  String get checkInRequiredHint;

  /// No description provided for @checkInSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your check-in. Please try again.'**
  String get checkInSaveError;

  /// No description provided for @checkInBodyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'How does your body feel today?'**
  String get checkInBodyStateTitle;

  /// No description provided for @checkInBodyStateComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get checkInBodyStateComfortable;

  /// No description provided for @checkInBodyStateStiff.
  ///
  /// In en, this message translates to:
  /// **'Stiff'**
  String get checkInBodyStateStiff;

  /// No description provided for @checkInBodyStateTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get checkInBodyStateTired;

  /// No description provided for @checkInBodyStateTense.
  ///
  /// In en, this message translates to:
  /// **'Tense'**
  String get checkInBodyStateTense;

  /// No description provided for @checkInGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you need today?'**
  String get checkInGoalTitle;

  /// No description provided for @checkInGoalEaseStiffness.
  ///
  /// In en, this message translates to:
  /// **'Ease stiffness'**
  String get checkInGoalEaseStiffness;

  /// No description provided for @checkInGoalMoveMoreFreely.
  ///
  /// In en, this message translates to:
  /// **'Move more freely'**
  String get checkInGoalMoveMoreFreely;

  /// No description provided for @checkInGoalFeelEnergized.
  ///
  /// In en, this message translates to:
  /// **'Feel energized'**
  String get checkInGoalFeelEnergized;

  /// No description provided for @checkInGoalRelax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get checkInGoalRelax;

  /// No description provided for @checkInGoalDeskBreak.
  ///
  /// In en, this message translates to:
  /// **'Take a desk break'**
  String get checkInGoalDeskBreak;

  /// No description provided for @checkInBodyAreasTitle.
  ///
  /// In en, this message translates to:
  /// **'Which areas need attention?'**
  String get checkInBodyAreasTitle;

  /// No description provided for @checkInBodyAreasHint.
  ///
  /// In en, this message translates to:
  /// **'Select one or more areas.'**
  String get checkInBodyAreasHint;

  /// No description provided for @checkInAreaNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get checkInAreaNeck;

  /// No description provided for @checkInAreaShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get checkInAreaShoulders;

  /// No description provided for @checkInAreaUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get checkInAreaUpperBack;

  /// No description provided for @checkInAreaLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get checkInAreaLowerBack;

  /// No description provided for @checkInAreaHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get checkInAreaHips;

  /// No description provided for @checkInAreaKnees.
  ///
  /// In en, this message translates to:
  /// **'Knees'**
  String get checkInAreaKnees;

  /// No description provided for @checkInAreaFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get checkInAreaFullBody;

  /// No description provided for @checkInTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time do you have?'**
  String get checkInTimeTitle;

  /// No description provided for @checkInTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String checkInTimeMinutes(int minutes);

  /// No description provided for @checkInPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'What works for you now?'**
  String get checkInPositionTitle;

  /// No description provided for @checkInPositionSeated.
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get checkInPositionSeated;

  /// No description provided for @checkInPositionStanding.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get checkInPositionStanding;

  /// No description provided for @checkInPositionFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get checkInPositionFloor;

  /// No description provided for @checkInPositionAny.
  ///
  /// In en, this message translates to:
  /// **'Any position'**
  String get checkInPositionAny;

  /// No description provided for @checkInStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start today\'s check-in'**
  String get checkInStartTitle;

  /// No description provided for @checkInStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you feel, and we\'ll choose a short routine for you.'**
  String get checkInStartSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

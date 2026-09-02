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

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendationTitle;

  /// No description provided for @recommendationBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get recommendationBack;

  /// No description provided for @recommendationStart.
  ///
  /// In en, this message translates to:
  /// **'Start routine'**
  String get recommendationStart;

  /// No description provided for @recommendationChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get recommendationChooseAnother;

  /// No description provided for @recommendationWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this routine?'**
  String get recommendationWhyTitle;

  /// No description provided for @recommendationPreviewMovements.
  ///
  /// In en, this message translates to:
  /// **'Preview movements'**
  String get recommendationPreviewMovements;

  /// No description provided for @recommendationMovements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get recommendationMovements;

  /// No description provided for @recommendationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t prepare your recommendation right now.'**
  String get recommendationUnavailable;

  /// No description provided for @recommendationEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a matching routine yet.'**
  String get recommendationEmptyTitle;

  /// No description provided for @recommendationEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your check-in or trying again.'**
  String get recommendationEmptyBody;

  /// No description provided for @recommendationRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get recommendationRetry;

  /// No description provided for @recommendationDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String recommendationDurationMinutes(int minutes);

  /// No description provided for @recommendationMovementsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} movements'**
  String recommendationMovementsCount(int count);

  /// No description provided for @recommendationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String recommendationSeconds(int seconds);

  /// No description provided for @recommendationDifficultyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get recommendationDifficultyBeginner;

  /// No description provided for @recommendationDifficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get recommendationDifficultyIntermediate;

  /// No description provided for @recommendationDifficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get recommendationDifficultyAdvanced;

  /// No description provided for @recommendationNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get recommendationNoEquipment;

  /// No description provided for @recommendationReasonBodyAreas.
  ///
  /// In en, this message translates to:
  /// **'Focuses on {areas}.'**
  String recommendationReasonBodyAreas(String areas);

  /// No description provided for @recommendationReasonGoal.
  ///
  /// In en, this message translates to:
  /// **'Matches your goal: {goal}.'**
  String recommendationReasonGoal(String goal);

  /// No description provided for @recommendationReasonTime.
  ///
  /// In en, this message translates to:
  /// **'Fits your {minutes} minutes.'**
  String recommendationReasonTime(int minutes);

  /// No description provided for @recommendationReasonPosition.
  ///
  /// In en, this message translates to:
  /// **'Matches your position: {position}.'**
  String recommendationReasonPosition(String position);

  /// No description provided for @recommendationReasonDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Suited to your level.'**
  String get recommendationReasonDifficulty;

  /// No description provided for @recommendationReasonRecent.
  ///
  /// In en, this message translates to:
  /// **'You completed this routine recently.'**
  String get recommendationReasonRecent;

  /// No description provided for @recommendationReasonDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'It includes a movement you found less comfortable before.'**
  String get recommendationReasonDiscomfort;

  /// No description provided for @recommendationReasonRoutineLessComfortable.
  ///
  /// In en, this message translates to:
  /// **'You found this routine less comfortable before.'**
  String get recommendationReasonRoutineLessComfortable;

  /// No description provided for @recommendationRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like instead?'**
  String get recommendationRejectTitle;

  /// No description provided for @recommendationRejectTooEasy.
  ///
  /// In en, this message translates to:
  /// **'Too easy'**
  String get recommendationRejectTooEasy;

  /// No description provided for @recommendationRejectTooDifficult.
  ///
  /// In en, this message translates to:
  /// **'Too difficult'**
  String get recommendationRejectTooDifficult;

  /// No description provided for @recommendationRejectPosition.
  ///
  /// In en, this message translates to:
  /// **'I can\'t do this position'**
  String get recommendationRejectPosition;

  /// No description provided for @recommendationRejectDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'This area feels uncomfortable'**
  String get recommendationRejectDiscomfort;

  /// No description provided for @recommendationRejectOther.
  ///
  /// In en, this message translates to:
  /// **'Show me something else'**
  String get recommendationRejectOther;

  /// No description provided for @recommendationNoAlternativeTitle.
  ///
  /// In en, this message translates to:
  /// **'No other routine fits right now.'**
  String get recommendationNoAlternativeTitle;

  /// No description provided for @recommendationNoAlternativeBody.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your answers and we\'ll find something else.'**
  String get recommendationNoAlternativeBody;

  /// No description provided for @recommendationEditCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Edit your check-in'**
  String get recommendationEditCheckIn;

  /// No description provided for @recommendationTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get recommendationTotalTime;

  /// No description provided for @recommendationSafetyReminder.
  ///
  /// In en, this message translates to:
  /// **'Move within a comfortable range and stop if you feel sharp pain.'**
  String get recommendationSafetyReminder;

  /// No description provided for @recommendationStartUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get this routine ready. Check your connection and try again.'**
  String get recommendationStartUnavailable;

  /// No description provided for @recommendationStartStorage.
  ///
  /// In en, this message translates to:
  /// **'You need more space to prepare this routine. Clear some space and try again.'**
  String get recommendationStartStorage;

  /// No description provided for @recommendationStartMissingMedia.
  ///
  /// In en, this message translates to:
  /// **'This routine isn\'t available right now.'**
  String get recommendationStartMissingMedia;

  /// No description provided for @playerMovementPosition.
  ///
  /// In en, this message translates to:
  /// **'Movement {current} of {total}'**
  String playerMovementPosition(int current, int total);

  /// No description provided for @playerUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next: {name}'**
  String playerUpNext(String name);

  /// No description provided for @playerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get playerResume;

  /// No description provided for @playerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get playerPrevious;

  /// No description provided for @playerSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get playerSkip;

  /// No description provided for @playerFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get playerFinish;

  /// No description provided for @playerClose.
  ///
  /// In en, this message translates to:
  /// **'End routine'**
  String get playerClose;

  /// No description provided for @playerPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get playerPaused;

  /// No description provided for @playerCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine complete'**
  String get playerCompletedTitle;

  /// No description provided for @playerCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Nice work. You moved through the whole routine.'**
  String get playerCompletedBody;

  /// No description provided for @playerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get playerDone;

  /// No description provided for @playerDefaultCue.
  ///
  /// In en, this message translates to:
  /// **'Move slowly and breathe comfortably.'**
  String get playerDefaultCue;

  /// No description provided for @playerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this routine right now.'**
  String get playerUnavailable;

  /// No description provided for @playerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get playerRetry;

  /// No description provided for @playerExitTitle.
  ///
  /// In en, this message translates to:
  /// **'End routine?'**
  String get playerExitTitle;

  /// No description provided for @playerExitBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress so far won\'t count as a completed routine.'**
  String get playerExitBody;

  /// No description provided for @playerExitKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get playerExitKeepGoing;

  /// No description provided for @playerExitAbandon.
  ///
  /// In en, this message translates to:
  /// **'End routine'**
  String get playerExitAbandon;

  /// No description provided for @playerConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished routine'**
  String get playerConflictTitle;

  /// No description provided for @playerConflictBody.
  ///
  /// In en, this message translates to:
  /// **'You have a routine in progress. Resume it, or end it to start this new one.'**
  String get playerConflictBody;

  /// No description provided for @playerConflictResume.
  ///
  /// In en, this message translates to:
  /// **'Resume routine'**
  String get playerConflictResume;

  /// No description provided for @playerConflictAbandon.
  ///
  /// In en, this message translates to:
  /// **'End and start new'**
  String get playerConflictAbandon;

  /// No description provided for @playerEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine ended'**
  String get playerEndedTitle;

  /// No description provided for @playerEndedBody.
  ///
  /// In en, this message translates to:
  /// **'You can try again whenever you\'re ready.'**
  String get playerEndedBody;

  /// No description provided for @playerSaveErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save progress'**
  String get playerSaveErrorTitle;

  /// No description provided for @playerSaveErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress couldn\'t be saved. Try again to keep it.'**
  String get playerSaveErrorBody;

  /// No description provided for @playerDemonstration.
  ///
  /// In en, this message translates to:
  /// **'Movement demonstration'**
  String get playerDemonstration;

  /// No description provided for @feedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'How does your body feel now?'**
  String get feedbackQuestion;

  /// No description provided for @feedbackActiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{You moved for 1 minute} other{You moved for {minutes} minutes}}'**
  String feedbackActiveMinutes(int minutes);

  /// No description provided for @feedbackMuchBetter.
  ///
  /// In en, this message translates to:
  /// **'Much better'**
  String get feedbackMuchBetter;

  /// No description provided for @feedbackLittleBetter.
  ///
  /// In en, this message translates to:
  /// **'A little better'**
  String get feedbackLittleBetter;

  /// No description provided for @feedbackSame.
  ///
  /// In en, this message translates to:
  /// **'About the same'**
  String get feedbackSame;

  /// No description provided for @feedbackLessComfortable.
  ///
  /// In en, this message translates to:
  /// **'Less comfortable'**
  String get feedbackLessComfortable;

  /// No description provided for @feedbackSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get feedbackSkip;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing.'**
  String get feedbackThanks;

  /// No description provided for @feedbackLessComfortableMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing that. Please stop for today and choose a comfortable option next time.'**
  String get feedbackLessComfortableMessage;

  /// No description provided for @feedbackSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your feedback. Please try again.'**
  String get feedbackSaveError;

  /// No description provided for @feedbackRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get feedbackRetry;

  /// No description provided for @feedbackDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get feedbackDone;

  /// No description provided for @gamificationWeeklyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {goal} movement days this week'**
  String gamificationWeeklyGoalProgress(int completed, int goal);

  /// No description provided for @gamificationPointsPending.
  ///
  /// In en, this message translates to:
  /// **'{points} points pending confirmation'**
  String gamificationPointsPending(int points);

  /// No description provided for @gamificationPointsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{points} movement points confirmed'**
  String gamificationPointsConfirmed(int points);

  /// No description provided for @gamificationProgressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be ready when it can be refreshed.'**
  String get gamificationProgressUnavailable;

  /// No description provided for @gamificationSummarySemantics.
  ///
  /// In en, this message translates to:
  /// **'Weekly movement goal and points'**
  String get gamificationSummarySemantics;
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

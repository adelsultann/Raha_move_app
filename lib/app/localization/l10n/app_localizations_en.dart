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

  @override
  String get preferencesBack => 'Back';

  @override
  String get preferencesTitle => 'A few quick preferences';

  @override
  String get preferencesSubtitle =>
      'This helps us choose routines that suit you. You can change these anytime.';

  @override
  String get preferencesExperienceLabel =>
      'How familiar are you with movement?';

  @override
  String get preferencesRequired => 'Required';

  @override
  String get preferencesExperienceBeginner => 'New to movement';

  @override
  String get preferencesExperienceIntermediate => 'Some experience';

  @override
  String get preferencesExperienceAdvanced => 'Very comfortable';

  @override
  String get preferencesPositionsLabel => 'Which positions work best for you?';

  @override
  String get preferencesPositionsHint => 'Choose none if any position works.';

  @override
  String get preferencesPositionSeated => 'Seated';

  @override
  String get preferencesPositionStanding => 'Standing';

  @override
  String get preferencesPositionFloor => 'Floor';

  @override
  String get preferencesWeeklyGoalLabel =>
      'How many movement days each week feel right?';

  @override
  String get preferencesDaysPerWeek => 'days per week';

  @override
  String get preferencesFewerDays => 'Fewer days';

  @override
  String get preferencesMoreDays => 'More days';

  @override
  String get preferencesReminderLabel => 'Gentle reminders';

  @override
  String get preferencesReminderSubtitle =>
      'A gentle nudge to move on your schedule.';

  @override
  String get preferencesContinue => 'Continue';

  @override
  String get preferencesRequiredHint =>
      'Choose your experience level to continue.';

  @override
  String get preferencesSaveError =>
      'We couldn\'t save your preferences. Please try again.';

  @override
  String get checkInBack => 'Back';

  @override
  String checkInStepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get checkInContinue => 'Continue';

  @override
  String get checkInRequiredHint => 'Please choose an answer to continue.';

  @override
  String get checkInSaveError =>
      'We couldn\'t save your check-in. Please try again.';

  @override
  String get checkInBodyStateTitle => 'How does your body feel today?';

  @override
  String get checkInBodyStateComfortable => 'Comfortable';

  @override
  String get checkInBodyStateStiff => 'Stiff';

  @override
  String get checkInBodyStateTired => 'Tired';

  @override
  String get checkInBodyStateTense => 'Tense';

  @override
  String get checkInGoalTitle => 'What do you need today?';

  @override
  String get checkInGoalEaseStiffness => 'Ease stiffness';

  @override
  String get checkInGoalMoveMoreFreely => 'Move more freely';

  @override
  String get checkInGoalFeelEnergized => 'Feel energized';

  @override
  String get checkInGoalRelax => 'Relax';

  @override
  String get checkInGoalDeskBreak => 'Take a desk break';

  @override
  String get checkInBodyAreasTitle => 'Which areas need attention?';

  @override
  String get checkInBodyAreasHint => 'Select one or more areas.';

  @override
  String get checkInAreaNeck => 'Neck';

  @override
  String get checkInAreaShoulders => 'Shoulders';

  @override
  String get checkInAreaUpperBack => 'Upper back';

  @override
  String get checkInAreaLowerBack => 'Lower back';

  @override
  String get checkInAreaHips => 'Hips';

  @override
  String get checkInAreaKnees => 'Knees';

  @override
  String get checkInAreaFullBody => 'Full body';

  @override
  String get checkInTimeTitle => 'How much time do you have?';

  @override
  String checkInTimeMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get checkInPositionTitle => 'What works for you now?';

  @override
  String get checkInPositionSeated => 'Seated';

  @override
  String get checkInPositionStanding => 'Standing';

  @override
  String get checkInPositionFloor => 'Floor';

  @override
  String get checkInPositionAny => 'Any position';

  @override
  String get checkInStartTitle => 'Start today\'s check-in';

  @override
  String get checkInStartSubtitle =>
      'Tell us how you feel, and we\'ll choose a short routine for you.';

  @override
  String get recommendationTitle => 'Recommended for you';

  @override
  String get recommendationBack => 'Back';

  @override
  String get recommendationStart => 'Start routine';

  @override
  String get recommendationChooseAnother => 'Choose another';

  @override
  String get recommendationWhyTitle => 'Why this routine?';

  @override
  String get recommendationPreviewMovements => 'Preview movements';

  @override
  String get recommendationMovements => 'Movements';

  @override
  String get recommendationUnavailable =>
      'We couldn\'t prepare your recommendation right now.';

  @override
  String get recommendationEmptyTitle =>
      'We couldn\'t find a matching routine yet.';

  @override
  String get recommendationEmptyBody =>
      'Try adjusting your check-in or trying again.';

  @override
  String get recommendationRetry => 'Try again';

  @override
  String recommendationDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String recommendationMovementsCount(int count) {
    return '$count movements';
  }

  @override
  String recommendationSeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String get recommendationDifficultyBeginner => 'Beginner';

  @override
  String get recommendationDifficultyIntermediate => 'Intermediate';

  @override
  String get recommendationDifficultyAdvanced => 'Advanced';

  @override
  String get recommendationNoEquipment => 'No equipment';

  @override
  String recommendationReasonBodyAreas(String areas) {
    return 'Focuses on $areas.';
  }

  @override
  String recommendationReasonGoal(String goal) {
    return 'Matches your goal: $goal.';
  }

  @override
  String recommendationReasonTime(int minutes) {
    return 'Fits your $minutes minutes.';
  }

  @override
  String recommendationReasonPosition(String position) {
    return 'Matches your position: $position.';
  }

  @override
  String get recommendationReasonDifficulty => 'Suited to your level.';

  @override
  String get recommendationReasonRecent =>
      'You completed this routine recently.';

  @override
  String get recommendationReasonDiscomfort =>
      'It includes a movement you found less comfortable before.';

  @override
  String get recommendationReasonRoutineLessComfortable =>
      'You found this routine less comfortable before.';

  @override
  String get recommendationRejectTitle => 'What would you like instead?';

  @override
  String get recommendationRejectTooEasy => 'Too easy';

  @override
  String get recommendationRejectTooDifficult => 'Too difficult';

  @override
  String get recommendationRejectPosition => 'I can\'t do this position';

  @override
  String get recommendationRejectDiscomfort => 'This area feels uncomfortable';

  @override
  String get recommendationRejectOther => 'Show me something else';

  @override
  String get recommendationNoAlternativeTitle =>
      'No other routine fits right now.';

  @override
  String get recommendationNoAlternativeBody =>
      'Try adjusting your answers and we\'ll find something else.';

  @override
  String get recommendationEditCheckIn => 'Edit your check-in';

  @override
  String get recommendationTotalTime => 'Total time';

  @override
  String get recommendationSafetyReminder =>
      'Move within a comfortable range and stop if you feel sharp pain.';

  @override
  String get recommendationStartUnavailable =>
      'We couldn\'t get this routine ready. Check your connection and try again.';

  @override
  String get recommendationStartStorage =>
      'You need more space to prepare this routine. Clear some space and try again.';

  @override
  String get recommendationStartMissingMedia =>
      'This routine isn\'t available right now.';

  @override
  String playerMovementPosition(int current, int total) {
    return 'Movement $current of $total';
  }

  @override
  String playerUpNext(String name) {
    return 'Up next: $name';
  }

  @override
  String get playerPause => 'Pause';

  @override
  String get playerResume => 'Resume';

  @override
  String get playerPrevious => 'Previous';

  @override
  String get playerSkip => 'Skip';

  @override
  String get playerFinish => 'Finish';

  @override
  String get playerClose => 'End routine';

  @override
  String get playerPaused => 'Paused';

  @override
  String get playerCompletedTitle => 'Routine complete';

  @override
  String get playerCompletedBody =>
      'Nice work. You moved through the whole routine.';

  @override
  String get playerDone => 'Done';

  @override
  String get playerDefaultCue => 'Move slowly and breathe comfortably.';

  @override
  String get playerUnavailable => 'We couldn\'t open this routine right now.';

  @override
  String get playerRetry => 'Try again';

  @override
  String get playerExitTitle => 'End routine?';

  @override
  String get playerExitBody =>
      'Your progress so far won\'t count as a completed routine.';

  @override
  String get playerExitKeepGoing => 'Keep going';

  @override
  String get playerExitAbandon => 'End routine';

  @override
  String get playerConflictTitle => 'Unfinished routine';

  @override
  String get playerConflictBody =>
      'You have a routine in progress. Resume it, or end it to start this new one.';

  @override
  String get playerConflictResume => 'Resume routine';

  @override
  String get playerConflictAbandon => 'End and start new';

  @override
  String get playerEndedTitle => 'Routine ended';

  @override
  String get playerEndedBody => 'You can try again whenever you\'re ready.';

  @override
  String get playerSaveErrorTitle => 'Couldn\'t save progress';

  @override
  String get playerSaveErrorBody =>
      'Your progress couldn\'t be saved. Try again to keep it.';

  @override
  String get playerDemonstration => 'Movement demonstration';

  @override
  String get feedbackQuestion => 'How does your body feel now?';

  @override
  String feedbackActiveMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'You moved for $minutes minutes',
      one: 'You moved for 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get feedbackMuchBetter => 'Much better';

  @override
  String get feedbackLittleBetter => 'A little better';

  @override
  String get feedbackSame => 'About the same';

  @override
  String get feedbackLessComfortable => 'Less comfortable';

  @override
  String get feedbackSkip => 'Skip for now';

  @override
  String get feedbackThanks => 'Thanks for sharing.';

  @override
  String get feedbackLessComfortableMessage =>
      'Thanks for sharing that. Please stop for today and choose a comfortable option next time.';

  @override
  String get feedbackSaveError =>
      'We couldn\'t save your feedback. Please try again.';

  @override
  String get feedbackRetry => 'Try again';

  @override
  String get feedbackDone => 'Done';

  @override
  String gamificationWeeklyGoalProgress(int completed, int goal) {
    return '$completed of $goal movement days this week';
  }

  @override
  String gamificationPointsPending(int points) {
    return '$points points pending confirmation';
  }

  @override
  String gamificationPointsConfirmed(int points) {
    return '$points movement points confirmed';
  }

  @override
  String get gamificationProgressUnavailable =>
      'Your progress will be ready when it can be refreshed.';

  @override
  String get gamificationSummarySemantics => 'Weekly movement goal and points';
}

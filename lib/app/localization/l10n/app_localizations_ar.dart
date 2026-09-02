// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'راحة موف';

  @override
  String get foundationMessage => 'رفيقك الهادئ للحركة يستعد للانطلاق.';

  @override
  String get catalogBootstrapLoading => 'نحضّر قائمة الحركات الخاصة بك…';

  @override
  String get catalogBootstrapError => 'تعذّر تحضير المحتوى الآن.';

  @override
  String get catalogBootstrapRetry => 'إعادة المحاولة';

  @override
  String get authLoading => 'نجهّز مساحتك…';

  @override
  String get authInitError => 'تعذّر تجهيز هويتك الآن.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get noAccountYet => 'جديد هنا؟ أنشئ حسابًا';

  @override
  String get emailConfirmationTitle => 'تحقّق من بريدك';

  @override
  String get checkYourEmail =>
      'أرسلنا لك رسالة تأكيد. يرجى التحقق من بريدك للمتابعة.';

  @override
  String emailConfirmationBody(String email) {
    return 'أرسلنا رابط تأكيد إلى $email. يرجى تأكيد بريدك الإلكتروني للمتابعة.';
  }

  @override
  String get resendConfirmation => 'إعادة إرسال التأكيد';

  @override
  String get invalidCredentialsError =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailInUseError => 'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get weakPasswordError => 'يرجى اختيار كلمة مرور أقوى.';

  @override
  String get offlineError =>
      'أنت غير متصل. يرجى التحقق من اتصالك والمحاولة مجددًا.';

  @override
  String get unconfirmedError =>
      'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get authenticating => 'يرجى الانتظار…';

  @override
  String get cancel => 'إلغاء';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get authFailedGeneric => 'حدث خطأ ما. يرجى المحاولة مجددًا.';

  @override
  String get languageSelectionWelcomeArabic => 'مرحباً بك في راحة موف';

  @override
  String get languageSelectionWelcomeEnglish => 'Welcome to Raha Move';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLoading => 'نجهّز الأمور…';

  @override
  String get onboardingError => 'تعذّر تجهيز الأمور الآن.';

  @override
  String get onboardingPageOneTitle => 'روتين مختار لك';

  @override
  String get onboardingPageOneBody =>
      'أخبرنا كيف يشعر جسمك، وسنقترح لك روتينًا قصيرًا مناسبًا.';

  @override
  String get onboardingPageTwoTitle => 'تحرّك حسب جدولك';

  @override
  String get onboardingPageTwoBody =>
      'اختر الوقت المتاح لديك، من استراحة مكتب سريعة إلى جلسة حركة أطول.';

  @override
  String get onboardingPageThreeTitle => 'ابنِ عادة مريحة';

  @override
  String get onboardingPageThreeBody =>
      'تابع انتظامك، لاحظ كيف تشعر، واحتفِ بكل حركة.';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String get preferencesBack => 'رجوع';

  @override
  String get preferencesTitle => 'تفضيلات سريعة';

  @override
  String get preferencesSubtitle =>
      'يساعدنا هذا على اختيار روتين يناسبك. يمكنك تغييرها في أي وقت.';

  @override
  String get preferencesExperienceLabel => 'ما مدى معرفتك بالحركة والتمارين؟';

  @override
  String get preferencesRequired => 'مطلوب';

  @override
  String get preferencesExperienceBeginner => 'جديد على الحركة';

  @override
  String get preferencesExperienceIntermediate => 'لديّ بعض الخبرة';

  @override
  String get preferencesExperienceAdvanced => 'أرتاح كثيرًا مع الحركة';

  @override
  String get preferencesPositionsLabel => 'ما الأوضاع التي تناسبك؟';

  @override
  String get preferencesPositionsHint =>
      'اتركها فارغة إذا كانت كل الأوضاع مناسبة لك.';

  @override
  String get preferencesPositionSeated => 'جلوس';

  @override
  String get preferencesPositionStanding => 'وقوف';

  @override
  String get preferencesPositionFloor => 'على الأرض';

  @override
  String get preferencesWeeklyGoalLabel =>
      'كم عدد أيام الحركة التي تناسبك في الأسبوع؟';

  @override
  String get preferencesDaysPerWeek => 'أيام في الأسبوع';

  @override
  String get preferencesFewerDays => 'أيام أقل';

  @override
  String get preferencesMoreDays => 'أيام أكثر';

  @override
  String get preferencesReminderLabel => 'تذكيرات لطيفة';

  @override
  String get preferencesReminderSubtitle => 'تنبيه لطيف للحركة وفق جدولك.';

  @override
  String get preferencesContinue => 'متابعة';

  @override
  String get preferencesRequiredHint => 'اختر مستوى خبرتك للمتابعة.';

  @override
  String get preferencesSaveError =>
      'تعذّر حفظ تفضيلاتك. يرجى المحاولة مجددًا.';

  @override
  String get checkInBack => 'رجوع';

  @override
  String checkInStepIndicator(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get checkInContinue => 'متابعة';

  @override
  String get checkInRequiredHint => 'يرجى اختيار إجابة للمتابعة.';

  @override
  String get checkInSaveError =>
      'تعذّر حفظ تسجيلك اليومي. يرجى المحاولة مجددًا.';

  @override
  String get checkInBodyStateTitle => 'كيف يشعر جسمك اليوم؟';

  @override
  String get checkInBodyStateComfortable => 'مرتاح';

  @override
  String get checkInBodyStateStiff => 'متيبّس';

  @override
  String get checkInBodyStateTired => 'متعب';

  @override
  String get checkInBodyStateTense => 'مشدود';

  @override
  String get checkInGoalTitle => 'ما الذي تحتاجه اليوم؟';

  @override
  String get checkInGoalEaseStiffness => 'تخفيف التيبس';

  @override
  String get checkInGoalMoveMoreFreely => 'تحرّك بحرية أكبر';

  @override
  String get checkInGoalFeelEnergized => 'الشعور بالنشاط';

  @override
  String get checkInGoalRelax => 'الاسترخاء';

  @override
  String get checkInGoalDeskBreak => 'استراحة من المكتب';

  @override
  String get checkInBodyAreasTitle => 'ما المناطق التي تحتاج اهتمامًا؟';

  @override
  String get checkInBodyAreasHint => 'اختر منطقة واحدة أو أكثر.';

  @override
  String get checkInAreaNeck => 'الرقبة';

  @override
  String get checkInAreaShoulders => 'الكتفان';

  @override
  String get checkInAreaUpperBack => 'أعلى الظهر';

  @override
  String get checkInAreaLowerBack => 'أسفل الظهر';

  @override
  String get checkInAreaHips => 'الوركان';

  @override
  String get checkInAreaKnees => 'الركبتان';

  @override
  String get checkInAreaFullBody => 'الجسم كاملاً';

  @override
  String get checkInTimeTitle => 'كم الوقت المتاح لديك؟';

  @override
  String checkInTimeMinutes(int minutes) {
    return '$minutes دقائق';
  }

  @override
  String get checkInPositionTitle => 'ما الذي يناسبك الآن؟';

  @override
  String get checkInPositionSeated => 'جلوس';

  @override
  String get checkInPositionStanding => 'وقوف';

  @override
  String get checkInPositionFloor => 'على الأرض';

  @override
  String get checkInPositionAny => 'أي وضع';

  @override
  String get checkInStartTitle => 'ابدأ تسجيل اليوم';

  @override
  String get checkInStartSubtitle =>
      'أخبرنا كيف تشعر، وسنختار لك روتينًا قصيرًا مناسبًا.';

  @override
  String get recommendationTitle => 'مختار لك';

  @override
  String get recommendationBack => 'رجوع';

  @override
  String get recommendationStart => 'ابدأ الروتين';

  @override
  String get recommendationChooseAnother => 'اختر غيره';

  @override
  String get recommendationWhyTitle => 'لماذا هذا الروتين؟';

  @override
  String get recommendationPreviewMovements => 'معاينة الحركات';

  @override
  String get recommendationMovements => 'الحركات';

  @override
  String get recommendationUnavailable => 'تعذّر تجهيز توصيتك الآن.';

  @override
  String get recommendationEmptyTitle => 'لم نجد روتينًا مناسبًا بعد.';

  @override
  String get recommendationEmptyBody =>
      'جرّب تعديل تسجيلك اليومي أو المحاولة مجددًا.';

  @override
  String get recommendationRetry => 'حاول مجددًا';

  @override
  String recommendationDurationMinutes(int minutes) {
    return '$minutes دقائق';
  }

  @override
  String recommendationMovementsCount(int count) {
    return '$count حركات';
  }

  @override
  String recommendationSeconds(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get recommendationDifficultyBeginner => 'مبتدئ';

  @override
  String get recommendationDifficultyIntermediate => 'متوسط';

  @override
  String get recommendationDifficultyAdvanced => 'متقدم';

  @override
  String get recommendationNoEquipment => 'بدون أدوات';

  @override
  String recommendationReasonBodyAreas(String areas) {
    return 'يركّز على $areas.';
  }

  @override
  String recommendationReasonGoal(String goal) {
    return 'يناسب هدفك: $goal.';
  }

  @override
  String recommendationReasonTime(int minutes) {
    return 'يناسب وقتك: $minutes دقائق.';
  }

  @override
  String recommendationReasonPosition(String position) {
    return 'يناسب وضعك: $position.';
  }

  @override
  String get recommendationReasonDifficulty => 'مناسب لمستواك.';

  @override
  String get recommendationReasonRecent => 'أكملت هذا الروتين مؤخرًا.';

  @override
  String get recommendationReasonDiscomfort =>
      'يتضمّن حركة وجدتها أقل راحة من قبل.';

  @override
  String get recommendationReasonRoutineLessComfortable =>
      'وجدت هذا الروتين أقل راحة من قبل.';

  @override
  String get recommendationRejectTitle => 'ماذا تفضّل بدلًا منه؟';

  @override
  String get recommendationRejectTooEasy => 'سهل جدًا';

  @override
  String get recommendationRejectTooDifficult => 'صعب جدًا';

  @override
  String get recommendationRejectPosition => 'لا أستطيع هذا الوضع';

  @override
  String get recommendationRejectDiscomfort => 'هذه المنطقة غير مريحة';

  @override
  String get recommendationRejectOther => 'أرني شيئًا آخر';

  @override
  String get recommendationNoAlternativeTitle =>
      'لا يوجد روتين آخر مناسب الآن.';

  @override
  String get recommendationNoAlternativeBody =>
      'جرّب تعديل إجاباتك وسنجد لك خيارًا آخر.';

  @override
  String get recommendationEditCheckIn => 'عدّل تسجيلك اليومي';

  @override
  String get recommendationTotalTime => 'الوقت الإجمالي';

  @override
  String get recommendationSafetyReminder =>
      'تحرّك ضمن نطاق مريح وتوقّف إذا شعرت بألم حاد.';

  @override
  String get recommendationStartUnavailable =>
      'تعذّر تجهيز هذا الروتين. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String get recommendationStartStorage =>
      'تحتاج مساحة أكبر لتجهيز هذا الروتين. وفّر بعض المساحة وحاول مجددًا.';

  @override
  String get recommendationStartMissingMedia => 'هذا الروتين غير متاح حاليًا.';

  @override
  String playerMovementPosition(int current, int total) {
    return 'الحركة $current من $total';
  }

  @override
  String playerUpNext(String name) {
    return 'التالي: $name';
  }

  @override
  String get playerPause => 'إيقاف مؤقت';

  @override
  String get playerResume => 'متابعة';

  @override
  String get playerPrevious => 'السابق';

  @override
  String get playerSkip => 'تخطّي';

  @override
  String get playerFinish => 'إنهاء';

  @override
  String get playerClose => 'إنهاء الروتين';

  @override
  String get playerPaused => 'متوقف مؤقتًا';

  @override
  String get playerCompletedTitle => 'اكتمل الروتين';

  @override
  String get playerCompletedBody => 'أحسنت، أكملت الروتين كاملًا.';

  @override
  String get playerDone => 'تم';

  @override
  String get playerDefaultCue => 'تحرّك ببطء وتنفّس بارتياح.';

  @override
  String get playerUnavailable => 'تعذّر فتح هذا الروتين الآن.';

  @override
  String get playerRetry => 'حاول مجددًا';

  @override
  String get playerExitTitle => 'إنهاء الروتين؟';

  @override
  String get playerExitBody => 'لن يُحتسب تقدمك حتى الآن كروتين مكتمل.';

  @override
  String get playerExitKeepGoing => 'متابعة';

  @override
  String get playerExitAbandon => 'إنهاء الروتين';

  @override
  String get playerConflictTitle => 'روتين غير مكتمل';

  @override
  String get playerConflictBody =>
      'لديك روتين قيد التقدم. تابعه، أو أنهِه لبدء هذا الروتين الجديد.';

  @override
  String get playerConflictResume => 'متابعة الروتين';

  @override
  String get playerConflictAbandon => 'إنهاء وبدء جديد';

  @override
  String get playerEndedTitle => 'انتهى الروتين';

  @override
  String get playerEndedBody => 'يمكنك المحاولة مجددًا متى ما كنت مستعدًا.';

  @override
  String get playerSaveErrorTitle => 'تعذّر حفظ التقدّم';

  @override
  String get playerSaveErrorBody =>
      'تعذّر حفظ تقدّمك. حاول مجددًا للاحتفاظ به.';

  @override
  String get playerDemonstration => 'عرض الحركة';

  @override
  String get feedbackQuestion => 'كيف يشعر جسمك الآن؟';

  @override
  String feedbackActiveMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'تحرّكت لمدة $minutes دقيقة',
      many: 'تحرّكت لمدة $minutes دقيقة',
      few: 'تحرّكت لمدة $minutes دقائق',
      two: 'تحرّكت لمدة دقيقتين',
      one: 'تحرّكت لمدة دقيقة واحدة',
      zero: 'لم تتحرّك بعد',
    );
    return '$_temp0';
  }

  @override
  String get feedbackMuchBetter => 'أفضل بكثير';

  @override
  String get feedbackLittleBetter => 'أفضل قليلًا';

  @override
  String get feedbackSame => 'نفس الشيء تقريبًا';

  @override
  String get feedbackLessComfortable => 'أقل راحة';

  @override
  String get feedbackSkip => 'تخطّي الآن';

  @override
  String get feedbackThanks => 'شكرًا لمشاركتنا.';

  @override
  String get feedbackLessComfortableMessage =>
      'شكرًا لإخبارنا. توقّف لليوم واختر خيارًا مريحًا في المرة القادمة.';

  @override
  String get feedbackSaveError => 'تعذّر حفظ تقييمك. يرجى المحاولة مجددًا.';

  @override
  String get feedbackRetry => 'حاول مجددًا';

  @override
  String get feedbackDone => 'تم';

  @override
  String gamificationWeeklyGoalProgress(int completed, int goal) {
    return '$completed من $goal أيام حركة هذا الأسبوع';
  }

  @override
  String gamificationPointsPending(int points) {
    return '$points نقاط بانتظار التأكيد';
  }

  @override
  String gamificationPointsConfirmed(int points) {
    return 'تم تأكيد $points من نقاط الحركة';
  }

  @override
  String get gamificationProgressUnavailable => 'سيظهر تقدّمك عند تحديثه.';

  @override
  String get gamificationSummarySemantics => 'هدف الحركة الأسبوعي والنقاط';
}

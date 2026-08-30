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
}

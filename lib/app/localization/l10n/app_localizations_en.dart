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
}

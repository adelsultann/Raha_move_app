import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/features/authentication/domain/auth_failure.dart';

/// Maps a domain [AuthFailure] to its localized, calm, non-technical message.
String authFailureMessage(AppLocalizations strings, AuthFailure? failure) {
  return switch (failure) {
    AuthFailure.invalidCredentials => strings.invalidCredentialsError,
    AuthFailure.emailInUse => strings.emailInUseError,
    AuthFailure.weakPassword => strings.weakPasswordError,
    AuthFailure.networkOffline => strings.offlineError,
    AuthFailure.unconfirmed => strings.unconfirmedError,
    // Cancellation is a control-flow state, not a user-facing error; fall back
    // to a neutral message so it never renders a bare "Cancel" label.
    AuthFailure.cancelled ||
    AuthFailure.unknown ||
    null => strings.authFailedGeneric,
  };
}

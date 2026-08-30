import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_account.freezed.dart';

/// The authenticated (or anonymous) Supabase account.
///
/// [id] is the stable Supabase auth uid, never a provider id or a local
/// filename. It becomes the sole identity after a guest is linked or an
/// existing account is adopted.
@freezed
abstract class AuthAccount with _$AuthAccount {
  const factory AuthAccount({
    required String id,
    required bool isAnonymous,
    required bool emailConfirmed,
  }) = _AuthAccount;
}

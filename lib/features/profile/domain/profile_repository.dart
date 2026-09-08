import 'profile_settings.dart';

abstract interface class ProfileRepository {
  Future<ProfileSettings> read(String userId);
  Future<void> save(String userId, ProfileSettings settings);
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../onboarding/domain/app_language.dart';
import '../domain/profile_repository.dart';
import '../domain/profile_settings.dart';

final class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  static String _consentKey(String userId) => 'telemetry_consent_$userId';

  @override
  Future<ProfileSettings> read(String userId) async {
    final profile = await (_database.select(
      _database.localProfiles,
    )..where((row) => row.userId.equals(userId))).getSingle();
    final preferences = await (_database.select(
      _database.localUserPreferences,
    )..where((row) => row.userId.equals(userId))).getSingle();
    final consent = await (_database.select(
      _database.environmentEntries,
    )..where((row) => row.key.equals(_consentKey(userId)))).getSingleOrNull();
    final consentValues = _decodeConsent(consent?.value);
    final positions = preferences.preferredPositionsJson.isEmpty
        ? <String>{}
        : (jsonDecode(preferences.preferredPositionsJson) as List<dynamic>)
              .cast<String>()
              .toSet();
    return ProfileSettings(
      language: AppLanguage.fromCode(profile.preferredLocale) ?? AppLanguage.ar,
      weeklyGoalDays: profile.weeklyGoalDays,
      permittedPositions: positions,
      soundEnabled: preferences.soundEnabled,
      vibrationEnabled: preferences.vibrationEnabled,
      wifiOnlyDownloads: preferences.downloadOnWifiOnly,
      reminderInterest: preferences.reminderInterest,
      analyticsEnabled: consentValues['analytics'] == true,
      crashReportingEnabled: consentValues['crashReporting'] == true,
    );
  }

  @override
  Future<void> save(String userId, ProfileSettings settings) =>
      LocalUserDataRepository(
        _database,
        activeUserId: userId,
        clock: _clock,
      ).saveProfilePreferences(
        profile: LocalProfilesCompanion(
          userId: Value(userId),
          preferredLocale: Value(settings.language.code),
          weeklyGoalDays: Value(settings.weeklyGoalDays),
        ),
        preferences: LocalUserPreferencesCompanion(
          userId: Value(userId),
          soundEnabled: Value(settings.soundEnabled),
          vibrationEnabled: Value(settings.vibrationEnabled),
          downloadOnWifiOnly: Value(settings.wifiOnlyDownloads),
          reminderInterest: Value(settings.reminderInterest),
          preferredPositionsJson: Value(
            jsonEncode(settings.permittedPositions.toList()..sort()),
          ),
        ),
        analyticsConsent: settings.analyticsEnabled,
        crashReportingConsent: settings.crashReportingEnabled,
      );

  Map<String, dynamic> _decodeConsent(String? source) {
    if (source == null || source.isEmpty) return const {};
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}

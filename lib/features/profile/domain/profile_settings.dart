import '../../onboarding/domain/app_language.dart';

/// Local-first settings owned by the Profile feature.
final class ProfileSettings {
  const ProfileSettings({
    required this.language,
    required this.weeklyGoalDays,
    required this.permittedPositions,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.wifiOnlyDownloads,
    required this.reminderInterest,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
  });

  final AppLanguage language;
  final int weeklyGoalDays;
  final Set<String> permittedPositions;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool wifiOnlyDownloads;
  final bool reminderInterest;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;

  ProfileSettings copyWith({
    AppLanguage? language,
    int? weeklyGoalDays,
    Set<String>? permittedPositions,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? wifiOnlyDownloads,
    bool? reminderInterest,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
  }) => ProfileSettings(
    language: language ?? this.language,
    weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
    permittedPositions: permittedPositions ?? this.permittedPositions,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
    reminderInterest: reminderInterest ?? this.reminderInterest,
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
  );
}

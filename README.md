# Raha Move

Arabic-first, beginner-friendly mobility routines that work from locally available content.

## Requirements

- Flutter `3.47.0` (Dart `3.13.0`), pinned in `.fvmrc`
- Android API 24+; iOS 15+

## Environments

Choose an environment through a compile-time define. Configuration contains only non-secret identifiers; credentials belong in local/CI secret stores.

```powershell
flutter run --dart-define=RAHA_ENV=development
flutter run --dart-define=RAHA_ENV=staging
flutter run --dart-define=RAHA_ENV=test
flutter run --dart-define=RAHA_ENV=production
```

## Development commands

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format .
dart analyze
flutter test
flutter build apk --debug --dart-define=RAHA_ENV=development
```

Generated files are committed and must be refreshed after changing a route, provider, Freezed model, Drift table, localization resource, or asset.

## Foundation scope

RAHA-010 establishes project structure and tooling only. Product features, remote services, secrets, and licensed media are intentionally not included.

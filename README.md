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

Remote synchronization and private media delivery are enabled only when both
public Supabase client values are supplied. Tests and the bundled starter flow
leave them unset and remain offline:

```powershell
flutter run `
  --dart-define=RAHA_ENV=development `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-public-publishable-key
```

Never use a Supabase service-role key in the application. The service role is
available only inside trusted backend functions such as
`resolve-media-delivery`.

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

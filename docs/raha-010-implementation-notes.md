# RAHA-010 implementation notes

## Confirmed requirements

- Flutter is pinned to 3.47.0 / Dart 3.13.0 and supports Android API 24+ and iOS 15+.
- The workspace uses feature-first layers. The foundation feature demonstrates a domain model and application provider; routing, configuration, database, localization, theme, and asset access remain outside domain code.
- Riverpod, generated typed GoRouter routes, Freezed/JSON models, Drift, `gen_l10n`, and FlutterGen all have compiling examples.
- Development, staging, test, and production are selected with the non-secret `RAHA_ENV` compile-time define.

## Assumption

The checked-in `logo.png` is an approved non-sensitive Raha-owned asset and is used only to prove generated asset access.

## Open decision / required engineering review

On 2026-08-22, Pub resolution under Flutter 3.47.0 found that the available `riverpod_lint` is incompatible with both `custom_lint` and `freezed_lint` when using Riverpod 3.4 and Freezed 3. The workspace retains `riverpod_lint` and omits `custom_lint` / `freezed_lint` rather than downgrading the runtime stack. Engineering should revisit this when compatible releases are available.

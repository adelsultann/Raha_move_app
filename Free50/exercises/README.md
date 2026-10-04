# Free50 exercise video workspace

This directory contains internal development fixtures only. The original MP4
filenames are preserved under `originals/videos/` and grouped by movement area
for content review:

- `upper_body/`
- `spine_back/`
- `hips_pelvis/`
- `legs_knees/`

`asset_inventory.csv` records technical metadata and checksums without treating
a filename as a permanent Raha exercise ID. Ten reviewed fixture clips are
copied into `assets/starter_content/media/videos/free50/` using stable Raha
delivery filenames for the internal five-minute routine. Those copies remain
covered by the Free50 development-only release restriction in
`docs/decisions/raha-026-provider-fixture-review.md`.

## Edit exercise guidance

The English and Arabic names, descriptions, short cues, and ordered instructions
for these videos live with the other starter exercises in
`content/authoring/exercise_guidance.json`. Match the Raha exercise ID in
`app_routine_mapping.csv`; edit both locale entries there and follow the
authoring instructions in `content/authoring/README.md`.

Run `dart run tool/content_import/bin/build_free50_starter_routine.dart` from
the repository root to regenerate `starter_catalog.json` and its checksum.
When guidance changes, the builder also advances the bundled release number so
an installed development app imports the new wording at startup. Rebuild and
reopen the app. Do not edit the generated manifest directly.

Do not publish these files, upload them to a public bucket, or include them in
beta or production builds. `tool/release_media_guard.dart` enforces that build
boundary.

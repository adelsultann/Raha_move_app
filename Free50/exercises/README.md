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

Do not publish these files, upload them to a public bucket, or include them in
beta or production builds. `tool/release_media_guard.dart` enforces that build
boundary.

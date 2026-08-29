# Raha Move Content Import Tool

`dart run tool/content_import/bin/import_content.dart <input-dir> <output-dir>`

The tool converts reviewed authoring data into deterministic, normalized Raha
Move manifests. It is for content operations only; it must not be run against
purchased source media or license records stored in the repository.

## Required input files

- `provider_metadata.csv`: `provider,source_exercise_id,source_filename`
- `mappings.csv`: `provider,source_exercise_id,raha_exercise_id`
- `exercises.csv`: the authoring columns in `docs/assets_strcture.md`, plus
  the required `access_tier` column (`free` or `premium`)
- `media_assets.csv`: the authoring columns in `docs/assets_strcture.md`
- `routines.json`: a list of Raha-authored `Routine` JSON records
- `media/`: source and delivery files named by `source_filename` and
  `delivery_file`

All provider-to-Raha mappings are explicit. The tool never derives a Raha ID
from a provider ID or filename. Invalid, ambiguous, or incomplete records are
excluded from the generated manifests and listed in `import_report.json`.

## Output

- `exercises.json`
- `media_assets.json`
- `routines.json`
- `import_report.json`

The manifest writer sorts records and JSON keys, so unchanged inputs produce
byte-identical output. Correct source data in the CSV/JSON inputs rather than
editing generated manifests.

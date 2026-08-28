# Raha Move Asset Structure

Related documents:

- [database.md](database.md) defines the normalized exercise, provider, media, and routine records.
- [project-structure.md](project-structure.md) defines the Flutter architecture and offline media strategy.
- [product-brief.md](product-brief.md) defines the exercise-content requirements.

## Purpose

This document defines how Raha Move stores, names, documents, imports, validates, and delivers exercise GIFs or videos, especially when a provider supplies media files without JSON metadata.

GymVisual is a possible media provider. Its media must be treated as licensed source material, while Raha Move maintains its own provider-independent exercise metadata and permanent IDs.

## What GymVisual Provides

GymVisual currently sells exercise illustrations, animated GIFs, and videos. Its official exercise-list page also provides an `.xls` exercise list containing fields such as provider ID, exercise name, equipment, target body part, and muscles. GymVisual states that the first digits of a downloaded filename are its reference ID.

Therefore, the GymVisual workflow should use:

```text
Purchased GIF or video
+ GymVisual reference ID from its filename
+ GymVisual exercise spreadsheet or product-page information
+ Raha Move-authored metadata and Arabic translation
= normalized Raha Move exercise record
```

Do not scrape the public website as the production content pipeline. Retain the purchased files, order evidence, official spreadsheet, and the license applicable at purchase time.

## License Requirements

GymVisual's published regular license currently says that purchased high-resolution, non-watermarked media may be used to illustrate mobile applications, subject to its restrictions. It also says that purchased media may not be redistributed, made available for download, transferred to third parties, posted to AI platforms, or used to generate AI content.

Project rules:

1. Use only media purchased by Raha Move and covered by the relevant license.
2. Never use watermarked previews or public thumbnails as application assets.
3. Keep invoices, order records, the license text, and the purchase date in private internal storage.
4. Do not commit purchased source media to a public repository.
5. Do not expose original files through public object-storage URLs.
6. Do not send GymVisual media to AI tools or use it as image-generation input.
7. Confirm with GymVisual that Raha Move's planned CDN, caching, subscription, and offline-download behavior complies with the license before production launch.
8. Recheck the license before each new purchase because website terms may change.

This document records an engineering approach, not legal advice.

Official references:

- [GymVisual license](https://gymvisual.com/content/9-license)
- [GymVisual exercise list](https://gymvisual.com/content/10-list-of-exercises)
- [GymVisual media catalog](https://gymvisual.com/13-media-content)

## Core Identity Rule

A GymVisual ID or filename must never be the permanent Raha Move exercise ID.

```text
Raha exercise ID:       raha_ex_000151
GymVisual provider ID:  4297
Purchased source file:  429713.gif
Delivery file:          raha_ex_000151_gymvisual_v1_720.gif
```

The Raha ID survives if the GIF is replaced with a video, if a different demonstration is selected, or if another provider is used later.

Store the provider mapping in the database:

```text
provider = gymvisual
source_exercise_id = 4297
exercise_id = raha_ex_000151
```

Some GymVisual filenames can contain suffix digits that distinguish media, style, or character variants. The importer must derive IDs using the provider's documented naming convention and verify them against the official spreadsheet or product page. It must not blindly assume that the full filename stem is the exercise ID.

## Recommended Directory Structure

Purchased files and private license records should live outside the public application repository. Only starter assets explicitly approved for bundling belong under Flutter's `assets/` directory.

```text
Raha_move_app/
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   └── starter_content/
│       ├── manifests/
│       │   ├── exercises.json
│       │   └── routines.json
│       └── media/
│           ├── gifs/
│           └── videos/
│
├── content/
│   ├── schemas/
│   │   ├── exercise_manifest.schema.json
│   │   └── media_manifest.schema.json
│   ├── manifests/
│   │   ├── exercises.csv
│   │   ├── exercises.json
│   │   ├── media_assets.csv
│   │   └── routines.json
│   └── imports/
│       └── gymvisual/
│           ├── mappings/
│           │   └── gymvisual_to_raha.csv
│           └── reports/
│               ├── import_report.json
│               └── rejected_rows.csv
│
└── tools/
    └── content_import/
```

Private, access-controlled storage outside the repository:

```text
raha-content-source-private/
└── gymvisual/
    ├── licenses/
    │   ├── license_snapshot_YYYY-MM-DD.pdf
    │   ├── order_receipts/
    │   └── purchase_register.csv
    ├── metadata/
    │   └── gymvisual_exercise_list_YYYY-MM-DD.xls
    └── originals/
        ├── gifs/
        └── videos/
```

The `content/imports/gymvisual` directory may contain provider IDs and normalized text metadata, but not purchased media, private invoices, contracts, account information, or confidential license notes.

## File Naming

### Original purchased files

Preserve the exact downloaded filename in private source storage. Never rename or overwrite the only original.

Record its checksum immediately:

```text
provider_filename
sha256
purchase_order
downloaded_at
media_type
```

### Processed delivery files

Delivery filenames use Raha identity rather than provider identity:

```text
<raha_exercise_id>_<provider>_<variant>_<size>.<extension>
```

Examples:

```text
raha_ex_000151_gymvisual_female_720.gif
raha_ex_000151_gymvisual_female_720.mp4
raha_ex_000151_gymvisual_female_poster.webp
```

Rules:

- Lowercase ASCII only.
- Use underscores, not spaces.
- Include the Raha exercise ID.
- Include provider and meaningful variant.
- Include size or delivery profile where multiple encodings exist.
- Do not include translated exercise names in filenames.
- Changing file bytes creates a new media version or checksum; do not silently replace cached content.

## Creating Metadata Without Provider JSON

Raha Move owns a manifest for every approved exercise and media file. The initial import can start from GymVisual's `.xls` list, but every record must be reviewed and enriched for Raha Move.

### Required exercise fields

| Field | Source | Requirement |
|---|---|---|
| `id` | Raha Move | Stable ID such as `raha_ex_000151` |
| `provider` | Importer | `gymvisual` |
| `sourceExerciseId` | Filename and spreadsheet | Verified provider reference |
| `name.en` | Spreadsheet/product page, edited | Reviewed English name |
| `name.ar` | Raha Move | Human-reviewed Arabic name |
| `description.en` | Raha Move | Short, non-medical description |
| `description.ar` | Raha Move | Human-reviewed Arabic description |
| `bodyAreas` | Spreadsheet plus review | Raha taxonomy keys |
| `targetMuscles` | Spreadsheet plus review | Optional normalized muscle keys |
| `equipment` | Spreadsheet plus review | Raha taxonomy keys |
| `difficulty` | Raha Move | Beginner, intermediate, or advanced |
| `positions` | Raha Move | Seated, standing, floor, or other |
| `goals` | Raha Move | Recommendation goal keys |
| `contexts` | Raha Move | Mobility, desk break, warm-up, etc. |
| `status` | Raha Move | Draft, review, published, or retired |
| `safetyReviewStatus` | Raha Move | Required before publishing |

Do not automatically publish provider classifications. The provider's labels may not match Raha Move's beginner-focused mobility taxonomy or safety requirements.

### Required media fields

| Field | Purpose |
|---|---|
| `id` | Stable Raha media ID |
| `exerciseId` | Links to the Raha exercise |
| `provider` | `gymvisual` |
| `sourceExerciseId` | Provider traceability |
| `sourceFilename` | Exact purchased filename |
| `type` | `gif` or `video` |
| `deliveryFile` | Processed storage object name |
| `mimeType` | `image/gif`, `video/mp4`, etc. |
| `width` and `height` | Pixel dimensions |
| `durationMs` | Playback duration |
| `sha256` | Integrity and cache invalidation |
| `variant` | Character, angle, style, or other distinction |
| `preferred` | Default demonstration flag |
| `licenseReference` | Internal license registry key |
| `status` | Draft, review, published, or retired |

### Example normalized manifest

```json
{
  "id": "raha_ex_000151",
  "source": {
    "provider": "gymvisual",
    "sourceExerciseId": "4297",
    "licenseReference": "gymvisual_order_2026_001"
  },
  "content": {
    "name": {
      "en": "Kneeling Back Rotation Stretch",
      "ar": "تمدد دوران الظهر من وضع الركوع"
    },
    "description": {
      "en": "A controlled kneeling rotation for gentle upper-body mobility.",
      "ar": "دوران متحكم به من وضع الركوع لدعم حركة الجزء العلوي من الجسم."
    }
  },
  "classification": {
    "category": "mobility",
    "bodyAreas": ["upper_back"],
    "equipment": ["body_weight"],
    "difficulty": "beginner",
    "positions": ["floor"],
    "goals": ["move_more_freely"]
  },
  "media": [
    {
      "id": "media_raha_ex_000151_gymvisual_01",
      "provider": "gymvisual",
      "sourceFilename": "429713.gif",
      "type": "gif",
      "deliveryFile": "raha_ex_000151_gymvisual_female_720.gif",
      "mimeType": "image/gif",
      "width": 720,
      "height": 720,
      "durationMs": 5400,
      "sha256": "<calculated-sha256>",
      "variant": "female",
      "preferred": true
    }
  ],
  "raha": {
    "contexts": ["everyday_mobility"],
    "safetyReviewStatus": "pending",
    "status": "draft"
  }
}
```

The example source ID and filename illustrate the mapping pattern and must be verified against the purchased item before use.

## CSV Authoring Workflow

For manual content work, a spreadsheet is easier to review than editing JSON directly. Use these files:

### `exercises.csv`

```text
raha_id,provider,source_exercise_id,name_en,name_ar,description_en,description_ar,category,body_areas,equipment,difficulty,positions,goals,contexts,safety_review_status,status
```

Use pipe-separated stable keys inside multi-value cells, for example:

```text
neck|shoulders
seated|standing
ease_stiffness|desk_break
```

### `media_assets.csv`

```text
media_id,raha_exercise_id,provider,source_exercise_id,source_filename,type,delivery_file,mime_type,width,height,duration_ms,sha256,variant,preferred,license_reference,status
```

The content tool validates the CSV files and generates normalized JSON for the application seed package and database import. Generated JSON must not be edited by hand; corrections belong in the source CSV or content-management system.

## Import Workflow

```text
Purchase and download media
  -> archive untouched original privately
  -> record receipt and license reference
  -> calculate SHA-256 checksum
  -> import GymVisual .xls metadata
  -> match filename reference to provider exercise ID
  -> assign or reuse stable Raha exercise ID
  -> map provider terms to Raha taxonomies
  -> write English and Arabic app content
  -> inspect the complete animation visually
  -> complete movement and safety review
  -> generate optimized delivery asset
  -> validate manifest and media properties
  -> upload to private object storage
  -> insert draft database records
  -> publish through an atomic content release
```

If the spreadsheet row, product page, and filename disagree, quarantine the asset in the import report. Never guess the mapping.

## GIF Versus Video

### GIF advantages

- Naturally loops.
- Simple to preview.
- Broad rendering support.
- Useful for short, silent demonstrations.

### GIF limitations

- Usually much larger than modern video at similar visual quality.
- No efficient audio track.
- Less control over seeking and precise playback state.
- Can use more memory and battery during long sessions.
- May not integrate as cleanly with pause, preload, and progress controls.

### Video advantages

- Better compression and download size.
- Stronger playback, pause, buffering, and preloading controls.
- Better fit for the planned routine player.
- Multiple delivery qualities can be generated.

### Recommended Raha Move policy

Prefer licensed MP4 video for production routine playback when the provider offers the same approved movement in video form. GIF can be used for prototypes, previews, or when it is the only licensed format.

Do not assume that a GIF purchase authorizes conversion into video. Confirm whether format conversion or transcoding is permitted by the applicable license. If confirmed, preserve the GIF as the licensed original and record the MP4 as a derived delivery asset linked to it.

The domain model remains media-neutral:

```text
Exercise
  └── one or more MediaAsset records
      ├── GIF demonstration
      ├── MP4 demonstration
      └── poster image
```

## Storage and Delivery

Use object storage paths that separate environment, provider, access level, and version:

```text
exercise-media/
└── production/
    ├── free/
    │   └── raha_ex_000151/
    │       └── v1/
    │           └── raha_ex_000151_gymvisual_female_720.mp4
    └── premium/
        └── raha_ex_000245/
            └── v1/
                └── raha_ex_000245_gymvisual_female_720.mp4
```

- Keep the bucket private unless the license explicitly permits public delivery.
- Store object keys in the database, not expiring signed URLs.
- Generate short-lived URLs through trusted backend code.
- Apply entitlement checks to premium media.
- Cache the active routine and preload the next exercise.
- Use checksums and versioned paths to invalidate stale cached files.
- Do not package the full purchased library inside the application binary.
- Bundle only a small, explicitly approved starter set needed for offline first use.

## Flutter Asset Declaration

Only bundled starter content is declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/starter_content/manifests/
    - assets/starter_content/media/gifs/
    - assets/starter_content/media/videos/
```

Remote catalog media is not declared as a Flutter asset. The app downloads it through the media repository and stores it in the device cache.

## Validation Before Publishing

Every exercise must pass automated and human validation.

Automated checks:

- Raha exercise and media IDs are unique.
- Provider and source ID mapping is unique.
- Referenced source and delivery files exist.
- File extension matches detected MIME type.
- Checksum matches the stored value.
- Width, height, duration, and byte size are within supported limits.
- GIF or video can be decoded fully.
- The loop has no corrupt frames.
- Exactly one preferred playable asset exists for each published exercise.
- Arabic and English names exist.
- All taxonomy keys exist in the database.
- Published routines reference only published exercises and media.
- A license reference and purchase record exist.

Human checks:

- The animation matches its exercise name and classifications.
- The movement is appropriate for the intended routine and audience.
- Start and end frames loop acceptably.
- The character remains visible at phone size.
- The background works with the Raha routine player.
- Left/right orientation and any asymmetry are documented.
- A qualified reviewer approves movement and safety suitability.
- Arabic and English wording is natural and avoids medical claims.

## Git and Security Rules

The public repository must ignore purchased source media and private commercial records. Example ignore rules:

```gitignore
# Licensed provider source files and private commercial records
/private_content/
/raha-content-source-private/
**/gymvisual/originals/
**/gymvisual/licenses/
**/gymvisual/order_receipts/

# Generated delivery media is uploaded through the content pipeline
/content/build/
```

Do not add a broad `*.gif` or `*.mp4` ignore rule because Raha-owned or explicitly approved starter assets may legitimately belong in the repository. Ignore sensitive directories by path.

## Minimum Prototype Approach

For the first prototype:

1. Purchase or license a very small set of relevant stretching/mobility assets.
2. Preserve original filenames privately.
3. Create `exercises.csv` and `media_assets.csv` manually.
4. Give every movement a Raha ID.
5. Add reviewed Arabic and English names.
6. Generate a small JSON starter manifest.
7. Bundle only the approved prototype files under `assets/starter_content`.
8. Test GIF and MP4 performance on one representative Android and iOS device.
9. Choose the production playback format after measuring download size, memory, battery, pause behavior, and visual quality.

This approach allows Raha Move to test the experience without making GymVisual filenames or classifications part of the permanent application architecture.


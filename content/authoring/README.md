# Starter content authoring

`exercise_guidance.json` is the source of truth for the bundled catalog's
localized exercise text. Use the stable Raha exercise ID from
`Free50/exercises/app_routine_mapping.csv` for the ten Free50 fixtures. The two
older starter exercises are included in the same file.

Each ID has `en` and `ar` entries with `name`, `description`, `short_cue`, and
ordered `instructions`. Each instruction is one short action. Keep both
languages aligned in sequence, use natural non-clinical wording, and have the
movement and safety wording reviewed before publishing. An empty array means
the player shows the description and cue without numbered steps.

`routine_guidance.json` is the source of truth for the two bundled routines.
Find a routine by its stable `raha_rt_...` ID. Edit `en.name` and `ar.name`
for the titles shown in the app, and `en.summary` and `ar.summary` for the
short description shown on routine cards and details. The ordered `steps`
array links to exercises by their stable `raha_ex_...` IDs. Each step also has
a stable `raha_rs_...` ID; leave it unchanged when reordering, and give any new
step a unique ID. Reorder entries or change their duration, rest, or optional
flag to change the routine.
The builder calculates the routine's estimated duration from those values.
For the instructions shown under each exercise video, edit the corresponding
entry in `exercise_guidance.json`; routine steps reuse those instructions and
do not duplicate them.

After editing, run this command from the repository root:

```shell
dart run tool/content_import/bin/build_free50_starter_routine.dart
```

The builder validates all twelve starter exercises, both routines, their links,
and both locales. It writes `exercise_translations`, `routine_translations`,
and `routine_steps` into `assets/starter_content/manifests/starter_catalog.json`,
recalculates the checksum, and increments the bundled release ID when content
changes. `routine_translations` must stay in that generated runtime manifest:
the local database uses it to show English and Arabic routine titles and
summaries offline. Rebuild and reopen a development app to load the new
release; hot reload alone does not re-import bundled catalog data. Never edit
the generated manifest directly. The Free50 media remains for internal testing
only and cannot ship in beta or production builds.

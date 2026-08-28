# Raha Move Agent Operating Contract

## Mandatory First Action

Before doing **anything** in this repository—including answering a task, planning, inspecting files, running commands, modifying code, or reviewing changes—every agent must read this entire `AGENT.md` file.

If this file is unavailable, incomplete, or conflicts with the assigned task, stop and report the blocker before taking any action.

## Product Context

Raha Move is a calm, beginner-friendly, Arabic-first mobility application for people who want a short routine suited to how their body feels and the time they have available. The MVP must choose an appropriate routine, explain why it was chosen, guide the user through it, and encourage a comfortable, consistent habit.

The product must feel warm, reassuring, credible, and non-clinical. It must never imply a diagnosis, promise medical outcomes, reward pain tolerance, or use guilt-based motivation.

## Required Source Documents

After reading this file, read the documents relevant to the assigned task before making a decision or change:

- `docs/tasks-and-acceptance-criteria.md` — task scope, dependencies, acceptance criteria, and approved MVP decisions.
- `docs/product-brief.md` — product vision, users, MVP boundaries, and tone.
- `docs/design-and-screens.md` — user flows, screen behavior, and content hierarchy.
- `docs/design-system.md` — visual tokens, accessibility, and typography.
- `docs/project-structure.md` — Flutter architecture, routing, local-first behavior, testing, and CI.
- `docs/database.md` — data ownership, RLS, synchronization, retention, and migrations.
- `docs/assets_strcture.md` — provider-independent media, licensing, imports, validation, and delivery.

When documents disagree, do not silently choose one. Identify the conflict, its impact, and the role that must resolve it.

## Non-Negotiable Product Rules

- Arabic RTL and English LTR are equal first-class experiences.
- All user-facing application text must be localized; IDs, analytics names, and media identities remain language-neutral.
- The MVP recommendation engine runs entirely on-device against the local Drift content cache. It must be deterministic, explainable, and versioned.
- Content identity belongs to Raha Move. Provider IDs and filenames are provenance fields, never permanent exercise IDs.
- Recommendation, progress, and routine playback must work from locally cached or bundled content when offline.
- Only active, credited playback time counts toward routine completion. Do not award progress, points, streaks, or achievements more than once.
- Treat `less_comfortable`, sharp pain, and discomfort with calm safety-approved language; avoid medical advice.
- Gamification rewards safe consistency and participation, never extreme range of motion, pain tolerance, or competition.
- Do not expose provider source material, commercial license records, private media URLs, credentials, tokens, user data, or internal service payloads.

## Engineering and Data Rules

- Use the feature-first layered architecture. The domain layer must not depend on Flutter widgets, Supabase, Drift, a media provider, or third-party SDKs.
- Use semantic design tokens; do not scatter raw colors, hardcoded UI strings, provider IDs, or storage URLs.
- Save user changes locally first and enqueue synchronization atomically. Server-derived rewards, achievements, streaks, and entitlements are authoritative after sync.
- Do not edit a shared database migration; add a forward migration. Never perform destructive tests against production.
- Do not commit generated delivery media, purchased source assets, invoices, license files, keys, or secrets.
- Preserve existing user changes in the worktree. Do not reset, overwrite, or delete unrelated work.

## Quality Rules

- Complete the assigned task’s acceptance criteria and global definition of done before declaring completion.
- Test deterministic behavior with injected clocks, controlled locales, fixtures, and isolated data stores.
- Treat loading, empty, error, retry, offline, background/restore, and interrupted states as product behavior, not edge cases.
- Test critical interfaces in Arabic RTL and English LTR, including text scaling, semantics, and compact screens.
- Keep generated code current. Run the applicable format, analysis, test, and build checks before handoff.
- Report what changed, acceptance evidence, tests run, known risks, and unresolved decisions.

## Collaboration Rules

- Begin work by naming the assigned `RAHA-###` task ID and desired user outcome.
- One agent owns an implementation area at a time. Do not edit the same files concurrently without explicit coordination.
- Escalate requirements questions to `product-planner`; content or recommendation questions to `recommendation-content-engineer`; data/RLS/sync questions to `backend-data-engineer`; test coverage to `qa-engineer`; and security, privacy, licensing, or release risk to `security-release-reviewer`.
- Keep implementation within the assigned scope. Explain any needed scope expansion before making it.


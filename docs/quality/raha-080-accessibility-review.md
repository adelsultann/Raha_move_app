# RAHA-080 accessibility and bilingual visual review

## Scope and environments

Review the critical journey in Arabic RTL and English LTR on a compact
360 x 640 logical-pixel phone and a standard phone. Repeat every check at 200%
text scale and with the operating-system reduced-motion setting enabled.

Critical journey: language selection and onboarding, Today, five-step check-in,
recommendation and preview, routine player, feedback, and bottom navigation.

## Automated acceptance evidence

- Widget tests exercise Arabic RTL, English LTR, compact layouts, and 200% text
  scaling for onboarding, check-in, recommendation, Today, player, feedback,
  and progress. `routine_player_screen_test.dart` includes the compact
  last-step control regression that previously hid Finish and verifies
  screen-reader names for the player controls.
- `test/app/theme/app_theme_test.dart` verifies a minimum 4.5:1 ratio for
  primary controls, primary text, supporting text, and destructive controls.
- Player controls expose localized labels through tooltips, preserve directional
  arrows, have at least 56dp targets, and wrap instead of clipping at large
  text sizes.
- The live timer is excluded from screen-reader announcements; the current
  movement, progress, paused status, headings, controls, feedback choices, and
  navigation retain their localized semantics. Essential movement names wrap
  rather than being truncated at large text scales; optional cues remain compact
  so controls stay visible.
- Reduced motion stops the non-essential player placeholder movement and makes
  onboarding transitions and page-indicator changes immediate. Selection,
  completion, warning, and error states retain text and/or icons in addition to
  color.

## Required manual device checklist

For each locale, device size, text scale, and motion setting above:

1. Complete the core journey and confirm no clipped or hidden required action.
2. With TalkBack or VoiceOver, confirm the focus order is heading/progress,
   current content, primary controls, then secondary controls; confirm labels,
   values, selected states, and hints make sense without sight.
3. Confirm selected cards, completion, errors, and body-area activity remain
   understandable without their colors.
4. Confirm focus indicators and all interactive targets are clear and at least
   48dp (primary player and form controls are 56dp).
5. Confirm reduced motion removes non-essential movement without concealing
   pause, progress, or completion status.

Record the reviewer, device/OS, locale, text scale, and result in the release
evidence for RAHA-080. This checklist intentionally contains no user data,
credentials, provider payloads, or media URLs.

## Completed manual review

**Reviewer:** Product owner  
**Date:** 2026-09-12  
**Device/OS:** Android 15 (compact and standard phone configurations)  
**Screen reader:** TalkBack

| Configuration | Result | Notes |
|---|---|---|
| Compact phone, Arabic RTL | Pass | No issues reported. |
| Compact phone, English LTR | Pass | No issues reported. |
| Standard phone, Arabic RTL | Pass | No issues reported. |
| Standard phone, English LTR | Pass | No issues reported. |
| 200% text scale | Pass | Required actions remained available. |
| Reduced motion | Pass | Status remained understandable. |
| TalkBack | Pass | Controls and flow remained understandable. |

The reviewer reported all reviewed configurations as passing with no issues.

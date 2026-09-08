# RAHA-064 — Profile, Settings, and Account Controls Scope Decision

**Decision owner:** Adel (product-planner)
**Decision date:** 2026-09-06
**Status:** Approved for MVP implementation; legal review remains mandatory before public release.

## Decisions

1. Profile settings include language, weekly movement goal, permitted movement
   positions, sound, vibration, Wi-Fi-only downloads, reminder interest, and
   separate analytics and crash-reporting consent controls. Every setting is
   saved locally first and enqueues an atomic preference update for later sync.
2. Locale changes apply immediately and retain the current route and all local
   user data.
3. Accessibility settings provide an explanation that Raha Move follows the
   device text-size setting. An app-specific text-scale override and a
   reduced-motion preference are out of scope.
4. Reminder interest is only an opt-in preference. This task must not request
   notification permission, schedule notifications, or add reminder timing;
   those behaviors remain owned by RAHA-065.
5. Subscription and purchase controls remain hidden until entitlement behavior
   is approved and implemented.
6. Profile exposes saved routines, a localized help screen without a feedback
   submission channel, and localized privacy and terms placeholder screens.
   Those legal screens clearly state that the final public-release policy and
   terms are pending review; no external URL or personal-data collection is
   introduced by this task.
7. Registered-account deletion requires a recent sign-in or re-authentication
   as supplied by the authentication provider, plus explicit confirmation.
   Guest deletion requires explicit confirmation but no credential prompt.
   A trusted backend deletion request begins the 30-day cleanup workflow.
   After the request is accepted, the app clears secure credentials, local
   user data, and private-media cache metadata. A recoverable error leaves the
   user signed in and does not claim deletion succeeded.

## Privacy boundary

The 30-day deletion target, applicable legal requirements, data residency,
and analytics/crash-vendor deletion or anonymization workflows require the
RAHA-082 security and privacy review before any public release. This task must
not add user-entered feedback, legal assertions, production telemetry, or
subscription behavior.

## Review triggers

Revisit this decision when a public legal policy, support channel, notification
scheduler, entitlement scope, or production analytics/crash vendor is approved.

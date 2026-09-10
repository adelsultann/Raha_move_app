# RAHA-065 — Gentle reminders

**Status:** Approved MVP implementation  
**Decision owner:** Adel  
**Decision date:** 2026-09-09

## Decision

- Each user has at most one device-local recurring weekly schedule. Its default
  is every day at 18:00 in the device's current IANA timezone.
- Schedules intentionally do not synchronize in this MVP. This resolves the
  source-document tension in favor of RAHA-065's device-local configuration
  acceptance criteria; revisit if cross-device reminders become required.
- The schedule is stored locally in `local_reminder_schedules`. It is not
  synchronized, needs no account or network, and creates no analytics events.
- Native permission is requested only from the explicit save/enable action in
  reminder settings, never during onboarding, screen load, reconciliation, or
  app start. A denial is persisted locally and is not prompted again; settings
  provides localized device-settings guidance.
- Notifications use static localized title/body only. They contain no name,
  body state, check-in answer, routine name, health information, identifier,
  URL, or custom payload.
- Opening reminder settings and app resume reconcile schedules with the current
  device IANA timezone without showing a native dialog. Native recurring plans
  retain the selected local wall-clock time through timezone and DST changes.
- Android API 24+ and iOS 15+ are supported. Android notification permission is
  requested only on versions where Android requires it.

## Rationale and review trigger

This keeps a low-pressure habit prompt private to the device and usable
offline. Revisit before adding cross-device schedules, dynamic reminder copy,
analytics, or server-driven notifications.

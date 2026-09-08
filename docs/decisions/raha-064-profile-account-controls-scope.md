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
    A failure before server acceptance leaves the user signed in and does not
    claim deletion succeeded. After server acceptance, the app immediately
    blocks normal access and retries durable local cleanup of secure
    credentials, local user data, and private-media cache metadata until it
    succeeds.

## Approved operational decision (2026-09-08)

Registered-account deletion is accepted only with a recent, valid provider
`auth_time` or `amr.timestamp`; token `iat` is not proof of re-authentication.
A protected `pg_cron` worker runs daily at 03:00 server time. New requests are
eligible for trusted processing after 27 days, preserving up to three daily
processing opportunities before the 30-day target. Each attempt and worker run
is restricted operational audit data and retains no user ID after purge.
Operations must alert if any request is overdue, the latest worker run fails, or
no completed worker run exists for 26 hours. This remains subject to the
pre-release legal review.

### Alert ownership and escalation (approved 2026-09-08)

The **Operations owner** owns the protected generic webhook, its secret rotation,
and acknowledgement/escalation. The alert relay sends only the event type,
observed timestamp, and one or more classifications: `overdue_requests`,
`worker_failed`, or `worker_stale`; it never sends user, request, provider, or
raw-error data. Operations must acknowledge a production alert within one hour,
investigate deletion processing, and escalate an unresolved overdue request to
the privacy/security release owner immediately.

Before staging or production deployment, Operations must configure protected
Vault secrets for the monitor URL and dispatcher token, plus protected Edge
Function secrets for the dispatcher token and generic webhook URL/token. They
must deploy the migration and function, use only a synthetic staging request to
verify a redacted authenticated delivery and webhook acknowledgement, verify no
alert is sent for a healthy monitor result, and retain the staging evidence in
the release record. No secret value, webhook URL, or alert payload containing
identity data belongs in this repository.

## Privacy boundary

The 30-day deletion target, applicable legal requirements, data residency,
and analytics/crash-vendor deletion or anonymization workflows require the
RAHA-082 security and privacy review before any public release. This task must
not add user-entered feedback, legal assertions, production telemetry, or
subscription behavior.

## Review triggers

Revisit this decision when a public legal policy, support channel, notification
scheduler, entitlement scope, or production analytics/crash vendor is approved.

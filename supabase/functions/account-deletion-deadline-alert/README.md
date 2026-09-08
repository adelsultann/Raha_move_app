# account-deletion-deadline-alert

Protected internal relay for RAHA-064 deletion-deadline alerts. It accepts only
an allowlisted, aggregate payload and forwards a newly constructed payload to a
generic Operations webhook. It never logs or forwards user IDs, request IDs,
raw errors, counts, credentials, or request bodies outside that allowlist.

## Deployment configuration

Set these **protected environment secrets** per environment; never commit their
values:

- `ACCOUNT_DELETION_ALERT_DISPATCH_TOKEN`: random bearer token used only by the
  database dispatcher to authenticate this endpoint.
- `ACCOUNT_DELETION_ALERT_WEBHOOK_URL`: Operations-owned HTTPS webhook URL
  (non-HTTPS URLs are rejected).
- `ACCOUNT_DELETION_ALERT_WEBHOOK_TOKEN`: bearer token expected by that webhook.

Also create Vault secrets with the deployment values:

- `raha_064_alert_monitor_url`: this deployed Edge Function URL.
- `raha_064_alert_dispatch_token`: the exact dispatch token above.

Deploy with `verify_jwt = false` only because this endpoint uses the separate
opaque deployment token; the function enforces that token before parsing input.
Do not expose the endpoint/token to mobile clients.

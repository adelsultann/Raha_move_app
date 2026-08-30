# resolve-media-delivery

Authenticated Supabase Edge Function for RAHA-026. It accepts one opaque
`delivery_reference`, verifies published/safety-approved catalog state and the
caller's server-owned entitlement, then creates a five-minute signed URL for
the private `exercise-media` bucket.

The standard Supabase runtime secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and
`SUPABASE_SERVICE_ROLE_KEY` are required. Never add their values to this
repository. Deploy with JWT verification enabled, as configured in
`supabase/config.toml`.

The function must not log or persist its request authorization, storage key,
signed URL, provider data, or raw backend error response.

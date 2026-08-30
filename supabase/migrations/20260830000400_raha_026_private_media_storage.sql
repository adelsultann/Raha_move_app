-- RAHA-026: private media bytes are reachable only through the trusted
-- resolve-media-delivery Edge Function. The service role creates short-lived
-- signed URLs after checking the authenticated user's entitlement.

insert into storage.buckets (id, name, public, file_size_limit)
values ('exercise-media', 'exercise-media', false, 52428800)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit;

-- There is intentionally no SELECT policy for anon/authenticated on this
-- bucket. A future policy must not be added without a security review because
-- it would bypass the entitlement-aware resolver.
drop policy if exists "raha_media_direct_read_anon" on storage.objects;
drop policy if exists "raha_media_direct_read_authenticated" on storage.objects;

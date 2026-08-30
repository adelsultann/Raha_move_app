-- RAHA-026 database/storage contract. Run after all migrations in a local
-- Supabase environment. The Edge Function authorization flow is exercised by
-- its deployment smoke test; these assertions protect the private bucket and
-- catalog metadata boundary.

do $$
begin
  if not exists (
    select 1 from storage.buckets
    where id = 'exercise-media' and public = false
  ) then
    raise exception 'RAHA-026: exercise-media bucket must exist and be private';
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname in (
        'raha_media_direct_read_anon',
        'raha_media_direct_read_authenticated'
      )
  ) then
    raise exception 'RAHA-026: direct media read policy must not exist';
  end if;

  if has_table_privilege('anon', 'public.media_assets', 'select')
     or has_table_privilege('authenticated', 'public.media_assets', 'select')
     or has_table_privilege('anon', 'public.user_entitlements', 'select')
     or has_table_privilege('authenticated', 'public.user_entitlements', 'select') then
    raise exception 'RAHA-026: client roles must not read private delivery or entitlement tables directly';
  end if;
end $$;

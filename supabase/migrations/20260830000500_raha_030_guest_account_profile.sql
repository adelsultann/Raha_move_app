-- RAHA-030: guest identity and optional account access (forward only).
-- The trusted sync RPCs and their bookkeeping tables reference
-- public.profiles(user_id) on delete cascade, but no trigger previously created
-- a profile row when a new auth.users row was inserted. An anonymous guest or a
-- newly registered user therefore had no profile row, and the first sync push
-- failed with a foreign-key violation. This migration creates a SECURITY
-- DEFINER trigger on auth.users that inserts the profile using only the table's
-- safe defaults (preferred_locale 'ar', timezone 'Asia/Riyadh',
-- weekly_goal_days 3). No email, phone, or other auth PII is copied into
-- public.profiles. The existing profiles_updated_at (before update) trigger is
-- untouched.
--
-- The trigger is an idempotent INSERT ... ON CONFLICT DO NOTHING so a duplicate
-- invocation, a race, or a previously backfilled profile cannot error or
-- duplicate. create or replace function plus drop/create trigger keep the
-- migration re-runnable.

create or replace function public.create_profile_for_auth_user()
returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  insert into public.profiles (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end $$;

drop trigger if exists auth_users_create_profile on auth.users;
create trigger auth_users_create_profile
  after insert on auth.users
  for each row
  execute function public.create_profile_for_auth_user();

-- The trigger runs as the definer; the function must not be callable by API
-- roles.
revoke all on function public.create_profile_for_auth_user() from public, anon, authenticated;

-- RAHA-064: account deletion workflow (forward only).
--
-- This migration models the *request* and *trusted deferred purge* lifecycle.
-- Requesting deletion does NOT destroy data synchronously: the authenticated
-- owner records a verified request with a 30-day purge deadline, and a trusted,
-- service-role-only worker performs the actual deletion once the grace period
-- has elapsed. This satisfies the RAHA-001 "complete purge within 30 days of a
-- verified request" target without falsely claiming an immediate purge.
--
-- State machine:
--   requested -> cancelled (owner cancels during the grace period)
--   requested -> purged   (trusted worker deletes data after purge_after)
--
-- Security:
--   * account_deletion_requests is RLS-enabled with NO client policies and its
--     table privileges are revoked from anon/authenticated. Clients act only
--     through the three authenticated RPCs below. Every RPC resolves the caller
--     from auth.uid() and never accepts a user_id argument, so a client cannot
--     target another user's account.
--   * process_due_account_deletions is service-role-only and only touches rows
--     whose purge_after deadline has passed; it cannot be invoked by
--     authenticated/anon clients.
--   * Deleting the auth.users row cascades through profiles to every user-owned
--     public table (check-ins, sessions, feedback, saved routines, preferences,
--     ledger, achievements, streaks, entitlements, sync logs). Server-owned
--     catalog data (exercises, routines, media_assets, providers, releases) is
--     untouched because it is not reachable from auth.users.
--   * The request row survives with user_id NULLed (on delete set null) and
--     status 'purged', so completion is auditable without retaining a link to
--     the deleted identity.
--
-- Identity verification note: re-authentication (Supabase reauthenticate()) and
-- the confirmation UI are caller-side concerns enforced before this RPC is
-- invoked; this layer only enforces that an authenticated session for the
-- requesting user can open or cancel a request. The 30-day grace value is the
-- RAHA-001 placeholder pending PDPL legal review and is enforced by the
-- purge_after check cap plus policy_version. Final GoTrue identity cleanup is
-- also recommended through supabase.auth.admin.deleteUser from a trusted Edge
-- Function in production, to guarantee auth-schema rows and auth hooks are
-- processed; the raw auth.users delete here performs the database-side purge.

create type public.deletion_request_status as enum ('requested', 'cancelled', 'purged');

create table public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  status public.deletion_request_status not null default 'requested',
  policy_version text not null default 'deletion_v1' check (char_length(policy_version) between 1 and 64),
  requested_at timestamptz not null default now(),
  purge_after timestamptz not null,
  cancelled_at timestamptz,
  purged_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (purge_after > requested_at),
  check (purge_after <= requested_at + interval '30 days'),
  check (
    (status = 'requested' and cancelled_at is null and purged_at is null)
    or (status = 'cancelled' and cancelled_at is not null and purged_at is null)
    or (status = 'purged' and purged_at is not null and cancelled_at is null)
  )
);

create unique index account_deletion_requests_one_active
  on public.account_deletion_requests(user_id) where status = 'requested';
create index account_deletion_requests_due
  on public.account_deletion_requests(purge_after) where status = 'requested';

alter table public.account_deletion_requests enable row level security;
revoke all on table public.account_deletion_requests from public, anon, authenticated;
create trigger account_deletion_requests_updated_at
  before update on public.account_deletion_requests
  for each row execute function public.set_updated_at();

-- Flutter contract shared by the owner-facing RPCs. Returned shape:
--   { "version": "raha_064_deletion_v1", "status": <requested|cancelled|none>,
--     "policy_version": "...", "requested_at": "...", "purge_after": "...",
--     "cancelled_at": "..." }
-- Timestamps serialize as ISO-8601 in the session timezone (same convention as
-- the sync projections).
create function public.account_deletion_envelope(p_req public.account_deletion_requests)
returns jsonb language sql stable set search_path = public as $$
  select jsonb_build_object(
    'version', 'raha_064_deletion_v1',
    'status', p_req.status,
    'policy_version', p_req.policy_version,
    'requested_at', p_req.requested_at,
    'purge_after', p_req.purge_after,
    'cancelled_at', p_req.cancelled_at
  );
$$;

-- Owner: open (or re-confirm) a deletion request. Idempotent; does not reset an
-- existing active request's clock. Cancelled requests may be re-requested.
create or replace function public.request_account_deletion()
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  req public.account_deletion_requests%rowtype;
  v_requested_at timestamptz;
  v_purge_after timestamptz;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into req from public.account_deletion_requests
   where user_id = v_uid and status = 'requested'
   limit 1;
  if found then return public.account_deletion_envelope(req); end if;

  v_requested_at := now();
  v_purge_after := v_requested_at + interval '30 days';
  insert into public.account_deletion_requests(user_id, policy_version, requested_at, purge_after)
  values (v_uid, 'deletion_v1', v_requested_at, v_purge_after)
  on conflict (user_id) where status = 'requested' do nothing
  returning * into req;
  if not found then
    select * into req from public.account_deletion_requests
     where user_id = v_uid and status = 'requested'
     limit 1;
  end if;
  return public.account_deletion_envelope(req);
end $$;

-- Owner: cancel an active request during the grace period. Idempotent; returns
-- {status: "none"} when no active request exists.
create or replace function public.cancel_account_deletion()
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  req public.account_deletion_requests%rowtype;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  update public.account_deletion_requests
     set status = 'cancelled', cancelled_at = now()
   where user_id = v_uid and status = 'requested'
   returning * into req;
  if not found then
    return jsonb_build_object('version', 'raha_064_deletion_v1', 'status', 'none');
  end if;
  return public.account_deletion_envelope(req);
end $$;

-- Owner: read the current deletion state (active request, else most recent).
create or replace function public.get_account_deletion_status()
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  req public.account_deletion_requests%rowtype;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into req from public.account_deletion_requests
   where user_id = v_uid
   order by case when status = 'requested' then 0 else 1 end, created_at desc
   limit 1;
  if not found then
    return jsonb_build_object('version', 'raha_064_deletion_v1', 'status', 'none');
  end if;
  return public.account_deletion_envelope(req);
end $$;

-- Trusted worker: purge every request whose grace period has elapsed. Deletes
-- the auth.users row (cascading through profiles to all user-owned public data)
-- and records completion. Service-role only.
create or replace function public.process_due_account_deletions(p_before timestamptz default now())
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  due_ids uuid[];
  due_user_ids uuid[];
  i integer;
  v_id uuid;
  v_uid uuid;
begin
  if p_before > now() then raise exception 'cannot process deletions scheduled in the future'; end if;
  select array_agg(id order by requested_at, id), array_agg(user_id order by requested_at, id)
    into due_ids, due_user_ids
  from public.account_deletion_requests
  where status = 'requested' and purge_after <= p_before;

  if due_ids is null then
    return jsonb_build_object('version', 'raha_064_deletion_v1', 'purged', 0, 'request_ids', '[]'::jsonb);
  end if;

  for i in 1..array_length(due_ids, 1) loop
    v_id := due_ids[i];
    v_uid := due_user_ids[i];
    update public.account_deletion_requests
       set status = 'purged', purged_at = now()
     where id = v_id;
    if v_uid is not null then
      delete from auth.users where id = v_uid;
    end if;
  end loop;

  return jsonb_build_object(
    'version', 'raha_064_deletion_v1',
    'purged', array_length(due_ids, 1),
    'request_ids', to_jsonb(due_ids)
  );
end $$;

-- Trusted-only ACL. The three owner RPCs are the only client surface; the
-- envelope helper and the purge worker are not callable by API roles.
revoke all on function public.account_deletion_envelope(public.account_deletion_requests) from public, anon, authenticated;
revoke all on function public.request_account_deletion() from public, anon, authenticated;
revoke all on function public.cancel_account_deletion() from public, anon, authenticated;
revoke all on function public.get_account_deletion_status() from public, anon, authenticated;
revoke all on function public.process_due_account_deletions(timestamptz) from public, anon, authenticated;
grant execute on function public.request_account_deletion() to authenticated;
grant execute on function public.cancel_account_deletion() to authenticated;
grant execute on function public.get_account_deletion_status() to authenticated;
grant execute on function public.process_due_account_deletions(timestamptz) to service_role;

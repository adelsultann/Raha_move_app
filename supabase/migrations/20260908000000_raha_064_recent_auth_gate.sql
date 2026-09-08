-- RAHA-064 security remediation (forward only): bounded recent-auth for account
-- deletion.
--
-- Blocking High: request_account_deletion previously accepted any authenticated
-- session, however old. Account deletion must require recent identity
-- verification. This migration enforces, server-side, that the caller presents
-- a JWT whose authentication time is within the approved 15-minute window, so a
-- stale or stolen session cannot trigger deletion without re-authenticating.
--
-- Mechanism (Supabase JWT claims, verified against GoTrue v2.196.0):
--   * iat   = token issued-at; it is ADVANCED on every token refresh, so it is
--             only a freshness fallback, not proof of re-authentication.
--   * amr   = array of {method, timestamp, provider}; timestamp is the last
--             actual credential/MFA verification time and is NOT advanced by
--             refresh. This is the authoritative re-authentication signal.
--   * auth_time = OIDC auth time; not currently emitted by Supabase access
--             tokens, honored for forward compatibility.
--
-- The gate resolves the authentication epoch with precedence
--   auth_time -> max(amr[].timestamp) -> iat
-- and rejects: absent (missing), malformed (non-numeric), future (beyond a
-- 5-minute clock-skew allowance), and stale (older than 15 minutes). All
-- comparison is against server time (now()).
--
-- Contract: request_account_deletion is unchanged except it now enforces this
-- gate immediately after resolving auth.uid(). No target user id is ever
-- accepted; ownership remains auth.uid()-scoped. cancel_account_deletion and
-- get_account_deletion_status are intentionally unaffected (non-destructive /
-- read-only). The gate is internal-only (not client-callable).

create or replace function public.assert_recent_authentication(p_max_age interval default interval '15 minutes')
returns void
language plpgsql security definer set search_path = public as $$
declare
  claims jsonb := auth.jwt();
  now_epoch bigint := extract(epoch from now())::bigint;
  auth_epoch bigint := null;
  candidate text;
  min_epoch bigint;
begin
  if claims is null or jsonb_typeof(claims) <> 'object' then
    raise exception 'authentication required';
  end if;

  candidate := claims->>'auth_time';
  if candidate is not null and candidate <> '' then
    if candidate !~ '^[0-9]{1,15}$' then raise exception 'authentication timestamp malformed'; end if;
    auth_epoch := candidate::bigint;
  end if;

  if auth_epoch is null and jsonb_typeof(claims->'amr') = 'array' then
    select max((value->>'timestamp')::bigint) into auth_epoch
    from jsonb_array_elements(claims->'amr') value
    where jsonb_typeof(value) = 'object'
      and value ? 'timestamp'
      and (value->>'timestamp') ~ '^[0-9]{1,15}$';
  end if;

  if auth_epoch is null then
    candidate := claims->>'iat';
    if candidate is not null and candidate <> '' then
      if candidate !~ '^[0-9]{1,15}$' then raise exception 'authentication timestamp malformed'; end if;
      auth_epoch := candidate::bigint;
    end if;
  end if;

  if auth_epoch is null then
    raise exception 'authentication timestamp missing';
  end if;

  if auth_epoch > now_epoch + 300 then
    raise exception 'authentication timestamp in the future';
  end if;

  min_epoch := now_epoch - (extract(epoch from p_max_age))::bigint;
  if auth_epoch < min_epoch then
    raise exception 'authentication expired; please re-authenticate';
  end if;
end $$;

-- Enforce the gate on the destructive request path.
create or replace function public.request_account_deletion()
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid();
  req public.account_deletion_requests%rowtype;
  v_requested_at timestamptz;
  v_purge_after timestamptz;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  perform public.assert_recent_authentication();
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

-- The gate is a trusted internal helper; it is invoked only from security
-- definer RPCs and must not be callable by API roles. request_account_deletion
-- keeps its existing EXECUTE grant to authenticated via create or replace.
revoke all on function public.assert_recent_authentication(interval) from public, anon, authenticated;

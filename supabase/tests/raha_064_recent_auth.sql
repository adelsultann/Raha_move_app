-- Local/disposable RAHA-064 recent-auth gate contract. Run after
-- `supabase db reset` (all migrations applied). Synthetic identities only;
-- rolls back.
--
--   supabase start && supabase db reset
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -v ON_ERROR_STOP=1 -f supabase/tests/raha_064_recent_auth.sql
begin;

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('06400000-0000-0000-0000-000000000001','authenticated','authenticated','raha064r-owner@example.test','',now(),'{}','{}',now(),now()),
  ('06400000-0000-0000-0000-000000000002','authenticated','authenticated','raha064r-other@example.test','',now(),'{}','{}',now(),now());
-- Profiles auto-created by the RAHA-030 auth.users trigger.

do $$ begin
  if has_function_privilege('authenticated','public.assert_recent_authentication(interval)','execute') then raise exception 'RAHA-064: recent-auth gate exposed to clients'; end if;
  if not has_function_privilege('authenticated','public.request_account_deletion()','execute') then raise exception 'RAHA-064: request RPC missing'; end if;
end $$;

-- Helper expressions used throughout (fresh = now; stale = 2h ago).
-- Fresh, fully-formed claim (re-authenticated).
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000001','role','authenticated',
  'iat',(extract(epoch from now()))::bigint,
  'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',(extract(epoch from now()))::bigint,'provider','email'))
)::text, true);
do $$ declare r jsonb; begin
  r := public.request_account_deletion();
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: fresh auth did not open request'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Acceptance: a fresh OIDC auth_time is sufficient without AMR.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000002','role','authenticated',
  'auth_time',(extract(epoch from now()))::bigint,
  'iat',((extract(epoch from now()))::bigint - 7200)
)::text, true);
do $$ declare r jsonb; begin
  r := public.request_account_deletion();
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: fresh auth_time did not open request'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rejection: stale claim (both iat and amr old).
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000002','role','authenticated',
  'iat',((extract(epoch from now()))::bigint - 7200),
  'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',((extract(epoch from now()))::bigint - 7200)))
)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: stale auth accepted';
  exception when raise_exception then if sqlerrm <> 'authentication expired; please re-authenticate' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rejection: absent authoritative claim. Fresh iat is not enough.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000002','role','authenticated','iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: absent timestamp accepted';
  exception when raise_exception then if sqlerrm <> 'authentication timestamp missing' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rejection: malformed authoritative claim (auth_time non-numeric).
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000002','role','authenticated','auth_time','not-a-number','iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: malformed timestamp accepted';
  exception when raise_exception then if sqlerrm <> 'authentication timestamp malformed' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rejection: future authoritative claim (auth_time in the future).
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000002','role','authenticated','auth_time',((extract(epoch from now()))::bigint + 3600),'iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: future timestamp accepted';
  exception when raise_exception then if sqlerrm <> 'authentication timestamp in the future' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rejection: iat fallback is prohibited even when the token is fresh.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000001','role','authenticated','iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: iat fallback accepted';
  exception when raise_exception then if sqlerrm <> 'authentication timestamp missing' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- AMR remains authoritative: a fresh iat cannot renew a stale AMR timestamp;
-- a fresh AMR timestamp is accepted even when iat is stale.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000002','role','authenticated',
  'iat',(extract(epoch from now()))::bigint,
  'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',((extract(epoch from now()))::bigint - 7200)))
)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: refresh-only session (stale amr, fresh iat) accepted';
  exception when raise_exception then if sqlerrm <> 'authentication expired; please re-authenticate' then raise; end if; end $$;
reset role;

set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000002','role','authenticated',
  'iat',((extract(epoch from now()))::bigint - 7200),
  'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',(extract(epoch from now()))::bigint))
)::text, true);
do $$ declare r jsonb; begin
  r := public.request_account_deletion();
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: re-auth (fresh amr, stale iat) rejected'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Malformed AMR is rejected; it must not fall back to iat.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object(
  'sub','06400000-0000-0000-0000-000000000002','role','authenticated',
  'iat',(extract(epoch from now()))::bigint,
  'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp','garbage'))
)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: malformed amr accepted';
  exception when raise_exception then if sqlerrm <> 'authentication timestamp malformed' then raise; end if; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- auth_time has precedence and is bound to server time: 16 minutes is stale.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000002','role','authenticated','auth_time',((extract(epoch from now()))::bigint - 960),'iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin
  perform public.request_account_deletion(); raise exception 'RAHA-064: 16-minute-old token accepted';
  exception when raise_exception then if sqlerrm <> 'authentication expired; please re-authenticate' then raise; end if; end $$;
reset role;

rollback;

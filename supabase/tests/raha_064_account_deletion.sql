-- Local/disposable RAHA-064 account deletion workflow contract. Run after
-- `supabase db reset` (all migrations applied). Uses only synthetic identities
-- and rolls everything back.
--
--   supabase start && supabase db reset
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -v ON_ERROR_STOP=1 -f supabase/tests/raha_064_account_deletion.sql
begin;

-- Synthetic identities. Profiles are auto-created by the RAHA-030 auth.users
-- insert trigger; no explicit profile insert is needed.
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('06400000-0000-0000-0000-000000000001','authenticated','authenticated','raha064-owner@example.test','',now(),'{}','{}',now(),now()),
  ('06400000-0000-0000-0000-000000000002','authenticated','authenticated','raha064-cancel@example.test','',now(),'{}','{}',now(),now()),
  ('06400000-0000-0000-0000-000000000003','authenticated','authenticated','raha064-due@example.test','',now(),'{}','{}',now(),now()),
  ('06400000-0000-0000-0000-000000000004','authenticated','authenticated','raha064-other@example.test','',now(),'{}','{}',now(),now());

-- User-owned data for the due-purge user, to prove cascade deletion.
insert into public.user_preferences(user_id) values ('06400000-0000-0000-0000-000000000003');

-- ---------------------------------------------------------------------------
-- Schema and privilege gate.
-- ---------------------------------------------------------------------------
do $$ begin
  if not exists (select 1 from pg_type where typname = 'deletion_request_status') then raise exception 'RAHA-064: deletion_request_status enum missing'; end if;
  if not exists (select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname = 'account_deletion_requests' and c.relkind = 'r' and c.relrowsecurity) then raise exception 'RAHA-064: request table missing or RLS disabled'; end if;
  if not exists (select 1 from pg_indexes where schemaname = 'public' and indexname = 'account_deletion_requests_one_active') then raise exception 'RAHA-064: active-request uniqueness index missing'; end if;
  if not has_function_privilege('authenticated','public.request_account_deletion()','execute') then raise exception 'RAHA-064: request RPC missing for clients'; end if;
  if not has_function_privilege('authenticated','public.cancel_account_deletion()','execute') then raise exception 'RAHA-064: cancel RPC missing for clients'; end if;
  if not has_function_privilege('authenticated','public.get_account_deletion_status()','execute') then raise exception 'RAHA-064: status RPC missing for clients'; end if;
  if has_function_privilege('authenticated','public.process_due_account_deletions(timestamptz)','execute') then raise exception 'RAHA-064: purge RPC exposed to clients'; end if;
  if has_function_privilege('anon','public.request_account_deletion()','execute') then raise exception 'RAHA-064: anon can request deletion'; end if;
  if has_function_privilege('authenticated','public.account_deletion_envelope(public.account_deletion_requests)','execute') then raise exception 'RAHA-064: envelope helper exposed to clients'; end if;
  if not has_function_privilege('service_role','public.process_due_account_deletions(timestamptz)','execute') then raise exception 'RAHA-064: service_role missing purge RPC'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Clients cannot touch the request table or invoke the purge worker.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000001','role','authenticated','iat',(extract(epoch from now()))::bigint)::text, true);
do $$ begin perform count(*) from public.account_deletion_requests; raise exception 'client read request table'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.account_deletion_requests(user_id,purge_after) values ('06400000-0000-0000-0000-000000000001',now()+interval '1 day'); raise exception 'client inserted request'; exception when insufficient_privilege then null; end $$;
do $$ begin update public.account_deletion_requests set status='cancelled'; raise exception 'client updated request'; exception when insufficient_privilege then null; end $$;
do $$ begin delete from public.account_deletion_requests; raise exception 'client deleted request'; exception when insufficient_privilege then null; end $$;
do $$ begin perform public.process_due_account_deletions(now()); raise exception 'client invoked purge'; exception when insufficient_privilege then null; end $$;
reset role;

set local role anon;
do $$ begin perform public.request_account_deletion(); raise exception 'anon requested deletion'; exception when insufficient_privilege then null; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Request lifecycle (owner). Request is deferred, idempotent, and capped at 30d.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000001','role','authenticated','iat',(extract(epoch from now()))::bigint,'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',(extract(epoch from now()))::bigint)))::text, true);
do $$ declare r jsonb; r2 jsonb; begin
  r := public.request_account_deletion();
  if r->>'version' <> 'raha_064_deletion_v1' then raise exception 'RAHA-064: envelope version incorrect'; end if;
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: status not requested'; end if;
  if r->>'policy_version' <> 'deletion_v2' then raise exception 'RAHA-064: policy_version incorrect'; end if;
  if (r->>'purge_after')::timestamptz <= (r->>'requested_at')::timestamptz then raise exception 'RAHA-064: purge was not deferred'; end if;
  if (r->>'purge_after')::timestamptz > (r->>'requested_at')::timestamptz + interval '30 days' then raise exception 'RAHA-064: purge exceeds 30-day cap'; end if;
  if r->>'cancelled_at' is not null then raise exception 'RAHA-064: fresh request has cancelled_at'; end if;
  r2 := public.request_account_deletion();
  if r2->>'requested_at' <> r->>'requested_at' then raise exception 'RAHA-064: re-request reset the clock'; end if;
  if public.get_account_deletion_status()->>'status' <> 'requested' then raise exception 'RAHA-064: status RPC disagreed'; end if;
end $$;
reset role;
do $$ begin
  if (select count(*) from public.account_deletion_requests where user_id='06400000-0000-0000-0000-000000000001' and status='requested') <> 1 then raise exception 'RAHA-064: expected exactly one active request'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Cancel lifecycle, then re-request after cancel.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000002','role','authenticated','iat',(extract(epoch from now()))::bigint,'amr', jsonb_build_array(jsonb_build_object('method','password','timestamp',(extract(epoch from now()))::bigint)))::text, true);
do $$ declare r jsonb; begin
  r := public.request_account_deletion();
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: cancel-user request failed'; end if;
  r := public.cancel_account_deletion();
  if r->>'status' <> 'cancelled' then raise exception 'RAHA-064: cancel failed'; end if;
  if r->>'cancelled_at' is null then raise exception 'RAHA-064: cancelled_at missing'; end if;
  r := public.cancel_account_deletion();
  if r->>'status' <> 'none' then raise exception 'RAHA-064: second cancel should be none'; end if;
  if public.get_account_deletion_status()->>'status' <> 'cancelled' then raise exception 'RAHA-064: status after cancel incorrect'; end if;
  r := public.request_account_deletion();
  if r->>'status' <> 'requested' then raise exception 'RAHA-064: re-request after cancel failed'; end if;
end $$;
reset role;
do $$ begin
  if (select count(*) from public.account_deletion_requests where user_id='06400000-0000-0000-0000-000000000002') <> 2 then raise exception 'RAHA-064: expected one cancelled and one requested row'; end if;
  if (select count(*) from public.account_deletion_requests where user_id='06400000-0000-0000-0000-000000000002' and status='requested') <> 1 then raise exception 'RAHA-064: expected one active request after re-request'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Owner isolation: another user cannot observe or affect owner's request.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', jsonb_build_object('sub','06400000-0000-0000-0000-000000000004','role','authenticated','iat',(extract(epoch from now()))::bigint)::text, true);
do $$ declare s jsonb; begin
  s := public.get_account_deletion_status();
  if s->>'status' <> 'none' then raise exception 'RAHA-064: other user saw owner request'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Trusted purge: only due requests are purged; audit row survives with null
-- user_id; non-due requests and users remain intact.
-- ---------------------------------------------------------------------------
insert into public.account_deletion_requests(id,user_id,status,policy_version,requested_at,purge_after) values
  ('06400000-0000-0000-0000-000000000101','06400000-0000-0000-0000-000000000003','requested','deletion_v1',now()-interval '29 days',now()-interval '1 minute');

set local role service_role;
do $$ begin perform public.process_due_account_deletions(now()+interval '1 hour'); raise exception 'future purge accepted'; exception when raise_exception then if sqlerrm <> 'cannot process deletions scheduled in the future' then raise; end if; end $$;
do $$ declare r jsonb; begin
  r := public.process_due_account_deletions();
  if r->>'version' <> 'raha_064_deletion_v2' then raise exception 'RAHA-064: purge version incorrect'; end if;
  if (r->>'purged')::int <> 1 then raise exception 'RAHA-064: purge count incorrect'; end if;
end $$;
reset role;

do $$ begin
  if exists (select 1 from auth.users where id='06400000-0000-0000-0000-000000000003') then raise exception 'RAHA-064: auth identity not deleted'; end if;
  if exists (select 1 from public.profiles where user_id='06400000-0000-0000-0000-000000000003') then raise exception 'RAHA-064: profile not deleted'; end if;
  if exists (select 1 from public.user_preferences where user_id='06400000-0000-0000-0000-000000000003') then raise exception 'RAHA-064: user-owned data not deleted'; end if;
  if (select status from public.account_deletion_requests where id='06400000-0000-0000-0000-000000000101') <> 'purged' then raise exception 'RAHA-064: request not marked purged'; end if;
  if (select purged_at from public.account_deletion_requests where id='06400000-0000-0000-0000-000000000101') is null then raise exception 'RAHA-064: purged_at missing'; end if;
  if (select user_id from public.account_deletion_requests where id='06400000-0000-0000-0000-000000000101') is not null then raise exception 'RAHA-064: purged request retained user_id'; end if;
  -- Non-due owner request (future purge_after) must be untouched.
  if (select count(*) from public.account_deletion_requests where user_id='06400000-0000-0000-0000-000000000001' and status='requested') <> 1 then raise exception 'RAHA-064: non-due request was purged'; end if;
  if not exists (select 1 from auth.users where id='06400000-0000-0000-0000-000000000001') then raise exception 'RAHA-064: non-due user was deleted'; end if;
end $$;

rollback;

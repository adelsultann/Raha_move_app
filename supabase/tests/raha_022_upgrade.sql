-- Isolated forward-upgrade proof. The runner creates a disposable database
-- with only the minimal Auth compatibility objects, then this file applies
-- 00000--00200, stores representative history, and applies 00300--00600.
\set ON_ERROR_STOP on
create schema auth;
create table auth.users (id uuid primary key);
create function auth.uid() returns uuid language sql stable as $$ select null::uuid $$;
\i /workspace/supabase/migrations/20260829000000_raha_022_initial_schema.sql
\i /workspace/supabase/migrations/20260829000100_raha_022_security_hardening.sql
\i /workspace/supabase/migrations/20260829000200_raha_022_timed_sessions_and_expiry.sql

insert into auth.users values ('90000000-0000-0000-0000-000000000001');
insert into public.profiles(user_id,display_name) values ('90000000-0000-0000-0000-000000000001','preserved user');
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version) values ('90000000-0000-0000-0000-000000000010','raha_rt_upgrade','retired','beginner','free',60,1);
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source) values ('90000000-0000-0000-0000-000000000020','90000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000010',1,'completed',now()-interval '2 days',now()-interval '2 days',60,60,1,1,0,0,'raha_001_v1','bundled');
insert into public.point_ledger(id,user_id,points,reason_code,source_type,source_id) values ('90000000-0000-0000-0000-000000000030','90000000-0000-0000-0000-000000000001',5,'completion','session','90000000-0000-0000-0000-000000000020');

\i /workspace/supabase/migrations/20260829000300_raha_022_catalog_manifest_and_deployment_gate.sql
\i /workspace/supabase/migrations/20260829000400_raha_022_function_acl_correction.sql
\i /workspace/supabase/migrations/20260829000500_raha_022_session_step_policy_acl_fix.sql
\i /workspace/supabase/migrations/20260829000600_raha_022_session_step_policy_execute.sql

do $$
begin
  if (select display_name from public.profiles where user_id='90000000-0000-0000-0000-000000000001') <> 'preserved user' then raise exception 'profile was not preserved'; end if;
  if not exists (select 1 from public.routine_sessions where id='90000000-0000-0000-0000-000000000020' and status='completed' and actual_duration_seconds=60) then raise exception 'completed session history was not preserved'; end if;
  if not exists (select 1 from public.point_ledger where id='90000000-0000-0000-0000-000000000030') then raise exception 'ledger history was not preserved'; end if;
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='routine_sessions' and column_name='last_credited_at' and is_nullable='NO') then raise exception 'forward session column missing'; end if;
end $$;
\i /workspace/supabase/tests/raha_022_acl_gate.sql

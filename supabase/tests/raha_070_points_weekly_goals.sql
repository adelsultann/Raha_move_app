-- Local/disposable RAHA-070 points & weekly goals contract. Run after db reset
-- (all migrations applied). Uses only synthetic identities; rolls back.
begin;
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('07000000-0000-0000-0000-000000000001','authenticated','authenticated','raha070-owner@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000002','authenticated','authenticated','raha070-other@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000003','authenticated','authenticated','raha070-riyadh@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000004','authenticated','authenticated','raha070-honolulu@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000005','authenticated','authenticated','raha070-snapshot@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000006','authenticated','authenticated','raha070-crossweek@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000007','authenticated','authenticated','raha070-contrast@example.test','',now(),'{}','{}',now(),now()),
  ('07000000-0000-0000-0000-000000000008','authenticated','authenticated','raha070-ruleversion@example.test','',now(),'{}','{}',now(),now());
-- Profiles auto-created by the RAHA-030 auth.users trigger.

insert into public.content_releases(id,version,published_at,manifest_checksum) overriding system value values (700,'raha-070-test',now()-interval '1 minute',repeat('a',64));
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id) values ('07100000-0000-0000-0000-000000000001','raha_ex_070','published','beginner','free',700);
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version,published_at,release_id) values ('07200000-0000-0000-0000-000000000001','raha_rt_070','published','beginner','free',100,1,now()-interval '1 minute',700);
insert into public.routine_steps(id,routine_id,exercise_id,position,duration_seconds) values ('07300000-0000-0000-0000-000000000001','07200000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000001',1,100);

-- Timezones for the deterministic week-boundary/snapshot tests.
update public.profiles set timezone = 'Asia/Riyadh' where user_id = '07000000-0000-0000-0000-000000000003';
update public.profiles set timezone = 'Pacific/Honolulu' where user_id = '07000000-0000-0000-0000-000000000004';
update public.profiles set timezone = 'Pacific/Honolulu' where user_id = '07000000-0000-0000-0000-000000000005';

-- ---------------------------------------------------------------------------
-- ACL: clients cannot award/read projections directly, and cannot write ledger.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ begin
  if has_function_privilege('authenticated','public.is_valid_iana_timezone(text)','execute')
     or has_function_privilege('authenticated','public.award_completion_points(uuid)','execute')
     or has_function_privilege('authenticated','public.weekly_movement_progress(uuid,timestamptz)','execute')
     or has_function_privilege('authenticated','public.sync_authoritative_projections(uuid)','execute')
     or has_function_privilege('authenticated','public.sync_reward_result(uuid,uuid,public.session_status)','execute') then
    raise exception 'RAHA-070: trusted award/projection RPC was exposed to clients';
  end if;
end $$;
do $$ begin insert into public.point_ledger(user_id,points,reason_code,rule_version,source_type) values ('07000000-0000-0000-0000-000000000001',10,'routine_completion','points_completion_v1','session'); raise exception 'client inserted ledger'; exception when insufficient_privilege then null; end $$;
do $$ begin update public.point_ledger set points=0; raise exception 'client updated ledger'; exception when insufficient_privilege then null; end $$;
do $$ begin delete from public.point_ledger; raise exception 'client deleted ledger'; exception when insufficient_privilege then null; end $$;
do $$ begin update public.routine_sessions set completed_timezone='Asia/Riyadh'; raise exception 'client wrote session timezone'; exception when insufficient_privilege then null; end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Award + rule version + idempotency + fallback timezone snapshot.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; sid uuid := '07000000-0000-0000-0000-000000000101'; begin
  r := public.sync_push_user_data(jsonb_build_array(
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000901','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000902','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000903','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));
  if (select status from public.routine_sessions where id=sid) <> 'completed' then raise exception 'qualifying session did not complete'; end if;
  if (select count(*) from public.point_ledger where user_id='07000000-0000-0000-0000-000000000001' and source_type='session' and source_id=sid) <> 1 then raise exception 'expected exactly one award'; end if;
  if not exists (select 1 from public.point_ledger where user_id='07000000-0000-0000-0000-000000000001' and source_id=sid and points=10 and reason_code='routine_completion' and rule_version='points_completion_v1' and source_type='session') then raise exception 'award fields are incorrect'; end if;
  if (select completed_timezone from public.routine_sessions where id=sid) <> 'Asia/Riyadh' then raise exception 'absent completed_timezone did not fall back to profile timezone'; end if;
  if r #>> '{operations,2,reward_result,version}' <> 'raha_025_reward_result_v1' then raise exception 'reward_result version changed'; end if;
  if jsonb_array_length(r #> '{operations,2,reward_result,awards,points}') <> 1
     or r #>> '{operations,2,reward_result,awards,points,0,points}' <> '10'
     or r #>> '{operations,2,reward_result,awards,points,0,rule_version}' <> 'points_completion_v1'
     or r #>> '{operations,2,reward_result,awards,points,0,reason_code}' <> 'routine_completion' then raise exception 'reward_result points contract is incorrect'; end if;
  if r #>> '{projections,points_balance}' <> '10'
     or r #>> '{projections,points,0,rule_version}' <> 'points_completion_v1' then raise exception 'authoritative projection did not carry rule version/balance'; end if;
  if r #>> '{projections,weekly_progress,rule_version}' <> 'movement_day_v1'
     or r #>> '{projections,weekly_progress,timezone}' <> 'Asia/Riyadh'
     or r #>> '{projections,weekly_progress,goal_days}' <> '3' then raise exception 'weekly progress projection is incorrect'; end if;

  -- Replay the exact finalize operation: no new award, same stored response.
  perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000903','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));
  if (select count(*) from public.point_ledger where user_id='07000000-0000-0000-0000-000000000001' and source_type='session' and source_id=sid) <> 1 then raise exception 'replayed finalize duplicated award'; end if;

  -- Direct duplicate finalization of an already-terminal session is rejected.
  begin perform public.complete_routine_session(sid,'raha_001_v1'); raise exception 'duplicate finalize accepted'; exception when raise_exception then if sqlerrm <> 'session is terminal' then raise; end if; end;
end $$;
reset role;

-- The ledger idempotent-source index is the final authority.
do $$ begin
  insert into public.point_ledger(user_id,points,reason_code,rule_version,source_type,source_id)
  values ('07000000-0000-0000-0000-000000000001',10,'routine_completion','points_completion_v1','session','07000000-0000-0000-0000-000000000101');
  raise exception 'duplicate award source accepted';
exception when unique_violation then null; end $$;

-- ---------------------------------------------------------------------------
-- Invalid IANA timezone is rejected defensively before any session is written.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ declare sid uuid := '07000000-0000-0000-0000-000000000105'; begin
  begin
    perform public.sync_push_user_data(jsonb_build_array(
      jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000941','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
      jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000942','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
      jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000943','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1','completed_timezone','Not/AZone'))));
    raise exception 'invalid timezone accepted';
  exception when raise_exception then if sqlerrm <> 'completed_timezone is not a valid IANA timezone' then raise; end if; end;
  if exists (select 1 from public.routine_sessions where id=sid) then raise exception 'invalid-timezone finalize left a session'; end if;
  if exists (select 1 from public.point_ledger where source_id=sid) then raise exception 'invalid-timezone finalize awarded points'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Valid device-captured timezone is snapshotted (overriding profile default).
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; sid uuid := '07000000-0000-0000-0000-000000000106'; begin
  r := public.sync_push_user_data(jsonb_build_array(
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000951','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000952','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000953','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1','completed_timezone','Pacific/Honolulu'))));
  if (select completed_timezone from public.routine_sessions where id=sid) <> 'Pacific/Honolulu' then raise exception 'device-captured timezone was not snapshotted'; end if;
  if (select count(*) from public.point_ledger where source_id=sid and rule_version='points_completion_v1') <> 1 then raise exception 'timezone-carrying finalize did not award'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Completed vs abandoned.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ declare r jsonb; sid uuid := '07000000-0000-0000-0000-000000000102'; begin
  r := public.sync_push_user_data(jsonb_build_array(
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000911','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000912','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000913','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));
  if r #>> '{projections,points_balance}' <> '30' then raise exception 'second qualifying session did not award'; end if;
end $$;
do $$ declare r jsonb; sid uuid := '07000000-0000-0000-0000-000000000103'; begin
  r := public.sync_push_user_data(jsonb_build_array(
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000921','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000922','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','partial','target_duration_seconds',100,'active_duration_seconds',10)),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000923','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));
  if (select status from public.routine_sessions where id=sid) <> 'abandoned' then raise exception 'non-qualifying session was not abandoned'; end if;
  if r #>> '{operations,2,reward_result,final_status}' <> 'abandoned' or jsonb_array_length(r #> '{operations,2,reward_result,awards,points}') <> 0 then raise exception 'abandoned session produced an award'; end if;
  if (select count(*) from public.point_ledger where source_id=sid) <> 0 then raise exception 'abandoned session wrote a ledger row'; end if;
  if r #>> '{projections,points_balance}' <> '30' then raise exception 'abandoned session changed points balance'; end if;
  if (select completed_timezone from public.routine_sessions where id=sid) is not null then raise exception 'abandoned session captured a timezone'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Direct RPC completion (not via sync_push) also awards and snapshots.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000001',true);
do $$ declare result public.session_status; sid uuid := '07000000-0000-0000-0000-000000000104'; begin
  perform public.start_routine_session(sid,'07200000-0000-0000-0000-000000000001',1,null,'explore','1.0.0');
  insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds)
  values (sid,'07300000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000001',1,'completed',100,100);
  result := public.complete_routine_session(sid,'raha_001_v1');
  if result <> 'completed' then raise exception 'direct completion did not complete'; end if;
  if (select count(*) from public.point_ledger where user_id='07000000-0000-0000-0000-000000000001' and source_id=sid and rule_version='points_completion_v1') <> 1 then raise exception 'direct completion did not award exactly one point'; end if;
  if (select completed_timezone from public.routine_sessions where id=sid) <> 'Asia/Riyadh' then raise exception 'direct completion did not snapshot profile timezone'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Owner isolation.
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000002',true);
do $$ declare r jsonb; n integer; begin
  select count(*) into n from public.point_ledger; if n <> 0 then raise exception 'other user read ledger'; end if;
  r := public.sync_pull_user_data(0,100);
  if r #>> '{projections,points_balance}' <> '0' or jsonb_array_length(r->'projections'->'points') <> 0 then raise exception 'other user saw owner points'; end if;
  if r #>> '{projections,weekly_progress,movement_days}' <> '0' then raise exception 'other user saw owner movement days'; end if;
  begin perform public.complete_routine_session('07000000-0000-0000-0000-000000000101','raha_001_v1'); raise exception 'other user finalized owner session'; exception when raise_exception then if sqlerrm <> 'session not found' then raise; end if; end;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Rule-version change coverage. A historical award written under a prior rule
-- version retains that version verbatim, while a new qualifying completion is
-- awarded under points_completion_v1. Idempotency (one award per source_id) is
-- unaffected by the rule-version change.
-- ---------------------------------------------------------------------------
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source) values
 ('07500000-0000-0000-0000-000000000001','07000000-0000-0000-0000-000000000008','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-25T03:00:00Z','2026-08-25T04:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore');

-- Historical award produced by a prior rule version.
insert into public.point_ledger(user_id,points,reason_code,rule_version,source_type,source_id) values
 ('07000000-0000-0000-0000-000000000008',10,'routine_completion','points_completion_v0','session','07500000-0000-0000-0000-000000000001');

set local role authenticated;
select set_config('request.jwt.claim.sub','07000000-0000-0000-0000-000000000008',true);
do $$ declare r jsonb; sid uuid := '07500000-0000-0000-0000-000000000002'; begin
  r := public.sync_push_user_data(jsonb_build_array(
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000961','kind','session_start','payload',jsonb_build_object('id',sid::text,'routine_id','07200000-0000-0000-0000-000000000001','routine_version',1,'source','explore','app_version','1.0.0')),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000962','kind','session_step_upsert','payload',jsonb_build_object('session_id',sid::text,'routine_step_id','07300000-0000-0000-0000-000000000001','exercise_id_snapshot','07100000-0000-0000-0000-000000000001','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
    jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000963','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));

  -- New completion is awarded under the current rule version.
  if not exists (select 1 from public.point_ledger where user_id='07000000-0000-0000-0000-000000000008' and source_id=sid and rule_version='points_completion_v1' and points=10 and reason_code='routine_completion' and source_type='session') then raise exception 'new completion was not awarded points_completion_v1'; end if;

  -- Historical award retains its prior rule version verbatim.
  if (select count(*) from public.point_ledger where source_id='07500000-0000-0000-0000-000000000001') <> 1
     or (select rule_version from public.point_ledger where source_id='07500000-0000-0000-0000-000000000001') <> 'points_completion_v0' then raise exception 'historical award rule version was not preserved'; end if;

  -- The authoritative projection exposes both awards with their own versions.
  if jsonb_array_length(r->'projections'->'points') <> 2 then raise exception 'projection should contain exactly two awards'; end if;
  if not exists (select 1 from jsonb_array_elements(r->'projections'->'points') p where p->>'rule_version'='points_completion_v0' and p->>'source_id'='07500000-0000-0000-0000-000000000001') then raise exception 'projection omitted historical rule version'; end if;
  if not exists (select 1 from jsonb_array_elements(r->'projections'->'points') p where p->>'rule_version'='points_completion_v1' and p->>'source_id'=sid::text) then raise exception 'projection omitted current rule version'; end if;

  -- Idempotency: replaying finalize must not duplicate the new award.
  perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','07000000-0000-0000-0000-000000000963','kind','session_finalize','payload',jsonb_build_object('session_id',sid::text,'completion_policy_version','raha_001_v1'))));
  if (select count(*) from public.point_ledger where source_id=sid) <> 1 then raise exception 'replayed finalize duplicated new award'; end if;
  if (select count(*) from public.point_ledger where source_id='07500000-0000-0000-0000-000000000001') <> 1 then raise exception 'historical award was duplicated'; end if;
end $$;
reset role;

-- ---------------------------------------------------------------------------
-- Week boundaries and timezone (deterministic, via fixed p_at).
-- ---------------------------------------------------------------------------
do $$ declare w jsonb; begin
  -- Riyadh (UTC+3), week of Mon 2026-08-31 .. Sun 2026-09-06.
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000003','2026-09-02T12:00:00Z');
  if (w->>'week_start')::timestamptz <> '2026-08-30T21:00:00Z'::timestamptz then raise exception 'week_start incorrect: %', w->>'week_start'; end if;
  if (w->>'week_end')::timestamptz <> '2026-09-06T21:00:00Z'::timestamptz then raise exception 'week_end incorrect: %', w->>'week_end'; end if;
  if (w->>'movement_days')::int <> 0 then raise exception 'empty week should have 0 movement days'; end if;
end $$;

-- Insert deterministic completed + abandoned sessions for the Riyadh user.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source) values
 ('07400000-0000-0000-0000-000000000001','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-31T03:00:00Z','2026-08-31T04:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000002','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-31T15:00:00Z','2026-08-31T16:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000003','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-09-01T04:00:00Z','2026-09-01T05:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000004','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-30T19:30:00Z','2026-08-30T20:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000005','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-09-06T19:30:00Z','2026-09-06T20:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000006','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'completed','2026-09-06T20:30:00Z','2026-09-06T21:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore'),
 ('07400000-0000-0000-0000-000000000007','07000000-0000-0000-0000-000000000003','07200000-0000-0000-0000-000000000001',1,'abandoned','2026-09-02T08:00:00Z','2026-09-02T09:00:00Z',100,10,1,0,0,1,'raha_001_v1','explore');

do $$ declare w jsonb; begin
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000003','2026-09-02T12:00:00Z');
  -- Mon(2 sessions, same day) + Tue + Sun = 3 distinct movement days.
  -- Sunday-before-week-start (08-30) and Monday-after-week-end (09-07) and the
  -- abandoned session are all excluded.
  if (w->>'movement_days')::int <> 3 then raise exception 'movement_days expected 3, got %', w->>'movement_days'; end if;
  if w->'movement_dates' <> '["2026-08-31","2026-09-01","2026-09-06"]'::jsonb then raise exception 'movement_dates incorrect: %', w->'movement_dates'; end if;
  if w->>'timezone' <> 'Asia/Riyadh' then raise exception 'projection timezone incorrect'; end if;
end $$;

-- The same UTC instant is a different local day/week in another timezone.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source) values
 ('07400000-0000-0000-0000-000000000010','07000000-0000-0000-0000-000000000004','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-30T23:30:00Z','2026-08-31T00:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore');

do $$ declare w jsonb; begin
  -- Honolulu (UTC-10): week of Mon 2026-08-31 (10:00Z). The 00:30Z completion
  -- is local Sunday 08-30, before the week starts, so it is not counted.
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000004','2026-09-02T12:00:00Z');
  if (w->>'week_start')::timestamptz <> '2026-08-31T10:00:00Z'::timestamptz then raise exception 'Honolulu week_start incorrect: %', w->>'week_start'; end if;
  if (w->>'movement_days')::int <> 0 then raise exception 'Honolulu session landed in the wrong week: %', w->>'movement_days'; end if;
  if w->'movement_dates' <> '[]'::jsonb then raise exception 'Honolulu movement_dates should be empty: %', w->'movement_dates'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Per-session timezone snapshot preserves historical day boundaries after a
-- profile timezone change. User 005's profile timezone is Honolulu, but one
-- session captured Asia/Riyadh at completion; the same UTC instant therefore
-- lands on different local days depending on each session's snapshot.
-- ---------------------------------------------------------------------------
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,completed_timezone) values
 ('07400000-0000-0000-0000-000000000011','07000000-0000-0000-0000-000000000005','07200000-0000-0000-0000-000000000001',1,'completed','2026-09-01T08:00:00Z','2026-09-01T09:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh'),
 ('07400000-0000-0000-0000-000000000012','07000000-0000-0000-0000-000000000005','07200000-0000-0000-0000-000000000001',1,'completed','2026-09-01T08:00:00Z','2026-09-01T09:00:00Z',100,100,1,1,0,0,'raha_001_v1','explore',NULL);

do $$ declare w jsonb; begin
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000005','2026-09-02T12:00:00Z');
  -- Session ...011 (Asia/Riyadh snapshot) -> local Tue 2026-09-01.
  -- Session ...012 (NULL -> Honolulu fallback) -> local Sun 2026-08-31.
  if (w->>'movement_days')::int <> 2 then raise exception 'snapshot movement_days expected 2, got %', w->>'movement_days'; end if;
  if w->'movement_dates' <> '["2026-08-31","2026-09-01"]'::jsonb then raise exception 'snapshot movement_dates incorrect: %', w->'movement_dates'; end if;
end $$;

-- An invalid stored profile timezone falls back defensively instead of erroring.
update public.profiles set timezone = 'Not/AZone' where user_id = '07000000-0000-0000-0000-000000000003';
do $$ declare w jsonb; begin
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000003','2026-09-02T12:00:00Z');
  if w is null or w->>'timezone' <> 'UTC' then raise exception 'invalid stored timezone did not fall back to UTC'; end if;
end $$;

-- ---------------------------------------------------------------------------
-- Regression: no cross-week count. The same UTC instant 2026-08-31T00:30:00Z is
-- Sunday 08-30 in Honolulu but Monday 08-31 in Riyadh. For a user whose stored
-- timezone is Asia/Riyadh (reference week Mon 2026-08-31), a session captured in
-- Honolulu at that instant belongs to the PREVIOUS Honolulu week and must not be
-- counted against the current Riyadh week; a session captured in Riyadh at the
-- same instant is Monday and IS counted.
-- ---------------------------------------------------------------------------
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,completed_timezone) values
 ('07400000-0000-0000-0000-000000000021','07000000-0000-0000-0000-000000000006','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-31T00:00:00Z','2026-08-31T00:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore','Pacific/Honolulu'),
 ('07400000-0000-0000-0000-000000000022','07000000-0000-0000-0000-000000000007','07200000-0000-0000-0000-000000000001',1,'completed','2026-08-31T00:00:00Z','2026-08-31T00:30:00Z',100,100,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh');

do $$ declare w jsonb; begin
  -- Honolulu-captured session: Sunday 08-30 -> previous week -> NOT counted.
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000006','2026-09-02T12:00:00Z');
  if (w->>'movement_days')::int <> 0 then raise exception 'cross-week session was counted: %', w->'movement_dates'; end if;
  if w->'movement_dates' <> '[]'::jsonb then raise exception 'cross-week session leaked a movement date: %', w->'movement_dates'; end if;

  -- Riyadh-captured session at the same instant: Monday 08-31 -> counted.
  w := public.weekly_movement_progress('07000000-0000-0000-0000-000000000007','2026-09-02T12:00:00Z');
  if (w->>'movement_days')::int <> 1 then raise exception 'in-week Monday session was not counted: %', w->'movement_dates'; end if;
  if w->'movement_dates' <> '["2026-08-31"]'::jsonb then raise exception 'in-week Monday date incorrect: %', w->'movement_dates'; end if;
end $$;

rollback;

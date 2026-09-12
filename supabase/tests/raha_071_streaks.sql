-- Local/disposable RAHA-071 streak contract. Run after db reset; synthetic only.
begin;
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('07100000-0000-0000-0000-000000000001','authenticated','authenticated','raha071@example.test','',now(),'{}','{}',now(),now());
insert into public.content_releases(id,version,published_at,manifest_checksum) overriding system value values (710,'raha-071-test',now(),repeat('a',64));
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id) values ('07100000-0000-0000-0000-000000000010','raha_ex_071','published','beginner','free',710);
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version,published_at,release_id) values ('07100000-0000-0000-0000-000000000011','raha_rt_071','published','beginner','free',60,1,now(),710);
update public.profiles set timezone='Asia/Riyadh' where user_id='07100000-0000-0000-0000-000000000001';

-- Clients cannot invoke the rule engine or mutate the derived projection.
set local role authenticated;
select set_config('request.jwt.claim.sub','07100000-0000-0000-0000-000000000001',true);
do $$ begin
  if has_function_privilege('authenticated','public.streak_v1_projection(uuid,timestamptz)','execute')
    or has_function_privilege('authenticated','public.refresh_user_streak_v1(uuid)','execute') then
    raise exception 'RAHA-071 trusted streak helper exposed to client';
  end if;
  begin update public.user_streaks set current_streak_days=99; raise exception 'client updated streak'; exception when insufficient_privilege then null; end;
end $$;
reset role;

-- First completion, duplicate same-day completion, and consecutive days count
-- one movement date each. Explicit fixed p_at makes server-time behavior testable.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,completed_timezone) values
 ('07100000-0000-0000-0000-000000000101','07100000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000011',1,'completed','2026-09-01T08:00:00Z','2026-09-01T09:00:00Z',60,60,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh'),
 ('07100000-0000-0000-0000-000000000102','07100000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000011',1,'completed','2026-09-01T10:00:00Z','2026-09-01T11:00:00Z',60,60,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh'),
 ('07100000-0000-0000-0000-000000000103','07100000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000011',1,'completed','2026-09-02T08:00:00Z','2026-09-02T09:00:00Z',60,60,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh');
do $$ declare s jsonb; begin
  s := public.streak_v1_projection('07100000-0000-0000-0000-000000000001','2026-09-02T12:00:00Z');
  if s->>'current_streak_days' <> '2' or s->>'longest_streak_days' <> '2' or s->>'rule_version' <> 'streak_v1' then raise exception 'first/consecutive streak incorrect: %', s; end if;
end $$;

-- Sync projections calculate against trusted server time rather than returning
-- a stale cached row after a missed day.
do $$ declare s jsonb; begin
  update public.user_streaks set current_streak_days=99 where user_id='07100000-0000-0000-0000-000000000001';
  s := public.sync_authoritative_projections('07100000-0000-0000-0000-000000000001')->'streak';
  if s->>'current_streak_days' = '99' then raise exception 'sync returned stale persisted streak'; end if;
end $$;

-- A gap resets active state on the next completion while retaining longest.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,completed_timezone) values
 ('07100000-0000-0000-0000-000000000104','07100000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000011',1,'completed','2026-09-04T08:00:00Z','2026-09-04T09:00:00Z',60,60,1,1,0,0,'raha_001_v1','explore','Asia/Riyadh');
do $$ declare s jsonb; begin
  s := public.streak_v1_projection('07100000-0000-0000-0000-000000000001','2026-09-04T12:00:00Z');
  if s->>'current_streak_days' <> '1' or s->>'longest_streak_days' <> '2' then raise exception 'gap did not reset current streak: %', s; end if;
  -- Delayed synchronization/server date: no device date can make this stale run active.
  s := public.streak_v1_projection('07100000-0000-0000-0000-000000000001','2026-09-07T12:00:00Z');
  if s->>'current_streak_days' <> '0' then raise exception 'stale streak remained active: %', s; end if;
end $$;

-- Travel uses the captured session timezone, not the later profile timezone.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,completed_timezone) values
 ('07100000-0000-0000-0000-000000000105','07100000-0000-0000-0000-000000000001','07100000-0000-0000-0000-000000000011',1,'completed','2026-09-07T23:00:00Z','2026-09-08T00:30:00Z',60,60,1,1,0,0,'raha_001_v1','explore','Pacific/Honolulu');
update public.profiles set timezone='Asia/Riyadh' where user_id='07100000-0000-0000-0000-000000000001';
do $$ declare s jsonb; begin
  s := public.streak_v1_projection('07100000-0000-0000-0000-000000000001','2026-09-08T12:00:00Z');
  if s->>'last_movement_date' <> '2026-09-07' then raise exception 'travel rewrote historical movement date: %', s; end if;
  if s->>'current_streak_days' <> '1' then raise exception 'travel date was treated as current profile date: %', s; end if;
end $$;

-- Migration version is persisted in the read-only sync projection.
do $$ begin
  perform public.refresh_user_streak_v1('07100000-0000-0000-0000-000000000001');
  if (select rule_version from public.user_streaks where user_id='07100000-0000-0000-0000-000000000001') <> 'streak_v1' then raise exception 'streak migration version missing'; end if;
end $$;
rollback;

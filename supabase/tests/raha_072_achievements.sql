-- Local/disposable RAHA-072 achievement contract. Run after db reset.
begin;

insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('07200000-0000-0000-0000-000000000001','authenticated','authenticated','raha072@example.test','',now(),'{}','{}',now(),now());
insert into public.content_releases(id,version,published_at,manifest_checksum) overriding system value values
  (720,'raha-072-test',now(),repeat('a',64));
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version,published_at,release_id) values
  ('07200000-0000-0000-0000-000000000010','raha_rt_072','published','beginner','free',60,1,now(),720);

-- Initial definitions have the approved bilingual content, app-owned icon keys,
-- zero points, published status, and immutable v1 criteria.
do $$ begin
  if (select count(*) from public.achievements where key in ('first_step','gentle_habit_7') and status='published' and points=0 and criteria->>'rule_version'='achievement_sessions_v1') <> 2 then
    raise exception 'initial achievement definitions are incomplete';
  end if;
  if not exists (select 1 from public.achievement_translations t join public.achievements a on a.id=t.achievement_id where a.key='first_step' and t.locale='ar' and t.name='خطوتك الأولى') then
    raise exception 'Arabic achievement translation missing';
  end if;
end $$;

-- Seven server-accepted completions create both eligible badges once. The
-- seventh completion produces the second badge; later completion cannot repeat it.
insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source)
select ('07200000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
  '07200000-0000-0000-0000-000000000001',
  '07200000-0000-0000-0000-000000000010', 1, 'completed',
  now() - ((8-n) || ' days')::interval,
  now() - ((8-n) || ' days')::interval,
  60, 60, 1, 1, 0, 0, 'raha_001_v1', 'explore'
from generate_series(1, 7) n;

do $$ begin
  if (select count(*) from public.user_achievements where user_id='07200000-0000-0000-0000-000000000001') <> 2 then
    raise exception 'eligible achievements were not awarded once';
  end if;
  if not exists (
    select 1 from public.user_achievements ua join public.achievements a on a.id=ua.achievement_id
    where ua.user_id='07200000-0000-0000-0000-000000000001' and a.key='gentle_habit_7'
      and ua.criteria_version=1 and ua.source_id='07200000-0000-0000-0000-000000000007'
  ) then raise exception 'seventh completion did not retain its achievement source'; end if;
end $$;

insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,completed_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source)
values ('07200000-0000-0000-0000-000000000008','07200000-0000-0000-0000-000000000001','07200000-0000-0000-0000-000000000010',1,'completed',now(),now(),60,60,1,1,0,0,'raha_001_v1','explore');
do $$ begin
  if (select count(*) from public.user_achievements where user_id='07200000-0000-0000-0000-000000000001') <> 2 then
    raise exception 'already-earned achievement duplicated';
  end if;
end $$;

-- Mobile roles have no direct award or evaluation capability and receive only
-- their own safe projection through sync.
set local role authenticated;
select set_config('request.jwt.claim.sub','07200000-0000-0000-0000-000000000001',true);
do $$ begin
  if has_function_privilege('authenticated','public.award_completion_achievements(uuid)','execute')
     or has_function_privilege('authenticated','public.achievement_projection(uuid)','execute') then
    raise exception 'trusted achievement helper exposed to client';
  end if;
  begin insert into public.user_achievements(user_id,achievement_id,criteria_version)
    select '07200000-0000-0000-0000-000000000001',id,1 from public.achievements where key='first_step';
    raise exception 'client created achievement';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

do $$ declare p jsonb; begin
  p := public.sync_authoritative_projections('07200000-0000-0000-0000-000000000001')->'achievements';
  if jsonb_array_length(p->'catalog') <> 2 or jsonb_array_length(p->'earned') <> 2 then
    raise exception 'achievement projection missing catalog or awarded state';
  end if;
end $$;

-- Retiring a definition stops new awards but preserves an existing user's
-- localized historical badge in the safe projection.
update public.achievements set status = 'retired' where key = 'first_step';
do $$ declare p jsonb; begin
  p := public.sync_authoritative_projections('07200000-0000-0000-0000-000000000001')->'achievements';
  if not exists (select 1 from jsonb_array_elements(p->'catalog') item
    where item->>'key' = 'first_step' and item->>'status' = 'retired') then
    raise exception 'retired earned achievement lost historical meaning';
  end if;
end $$;

rollback;

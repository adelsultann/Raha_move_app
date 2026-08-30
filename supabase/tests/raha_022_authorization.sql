-- Local-only execution (no project credentials):
--   supabase start && supabase db reset
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -v ON_ERROR_STOP=1 -f supabase/tests/raha_022_authorization.sql
-- Uses only synthetic identities and rolls all fixtures back.
begin;
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
  ('00000000-0000-0000-0000-000000000001','authenticated','authenticated','owner@example.test','',now(),'{}','{}',now(),now()),
  ('00000000-0000-0000-0000-000000000002','authenticated','authenticated','other@example.test','',now(),'{}','{}',now(),now());
-- Profiles for these synthetic users are created automatically by the RAHA-030
-- auth.users insert trigger; no explicit profile insert is needed here.
insert into public.content_releases(id,version,published_at,minimum_app_version,manifest_checksum) overriding system value values
  (1,'past-free',now()-interval '1 minute','1.0.0',repeat('a',64)),
  (2,'future-free',now()+interval '1 day','1.0.0',repeat('b',64)),
  (3,'newer-than-client',now()-interval '1 minute','9.0.0',repeat('c',64));
insert into public.goals(id,key) values ('01000000-0000-0000-0000-000000000001','ease_stiffness');
insert into public.body_areas(id,key) values ('02000000-0000-0000-0000-000000000001','neck');
insert into public.movement_positions(id,key) values ('03000000-0000-0000-0000-000000000001','seated');
insert into public.equipment(id,key) values ('04000000-0000-0000-0000-000000000001','body_weight');
insert into public.goal_translations values ('01000000-0000-0000-0000-000000000001','en','Ease stiffness'),('01000000-0000-0000-0000-000000000001','ar','تخفيف التيبس');
insert into public.body_area_translations values ('02000000-0000-0000-0000-000000000001','en','Neck'),('02000000-0000-0000-0000-000000000001','ar','الرقبة');
insert into public.movement_position_translations values ('03000000-0000-0000-0000-000000000001','en','Seated'),('03000000-0000-0000-0000-000000000001','ar','جلوس');
insert into public.equipment_translations values ('04000000-0000-0000-0000-000000000001','en','Body weight'),('04000000-0000-0000-0000-000000000001','ar','وزن الجسم');
insert into public.recommendation_rule_sets(version,configuration,active_from) values ('rules-v1','{}',now()-interval '1 minute');
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id) values
  ('10000000-0000-0000-0000-000000000001','raha_ex_free','published','beginner','free',1),
  ('10000000-0000-0000-0000-000000000002','raha_ex_future','published','beginner','free',2),
  ('10000000-0000-0000-0000-000000000003','raha_ex_draft','draft','beginner','free',1),
  ('10000000-0000-0000-0000-000000000004','raha_ex_premium','published','beginner','premium',1);
insert into public.exercise_translations values ('10000000-0000-0000-0000-000000000001','en','Free exercise',null,null),('10000000-0000-0000-0000-000000000001','ar','تمرين مجاني',null,null),('10000000-0000-0000-0000-000000000002','en','Future exercise',null,null),('10000000-0000-0000-0000-000000000003','en','Draft exercise',null,null),('10000000-0000-0000-0000-000000000004','en','Premium exercise',null,null);
insert into public.media_assets(id,exercise_id,media_type,storage_bucket,storage_key,mime_type,checksum_sha256,is_preferred,status) values ('11000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','video','private-media','free.mp4','video/mp4',repeat('d',64),true,'published'),('11000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','video','private-media','future.mp4','video/mp4',repeat('e',64),true,'published');
insert into public.exercise_body_areas values ('10000000-0000-0000-0000-000000000001','02000000-0000-0000-0000-000000000001',1),('10000000-0000-0000-0000-000000000002','02000000-0000-0000-0000-000000000001',1);
insert into public.exercise_positions values ('10000000-0000-0000-0000-000000000001','03000000-0000-0000-0000-000000000001');
insert into public.exercise_equipment values ('10000000-0000-0000-0000-000000000001','04000000-0000-0000-0000-000000000001');
insert into public.exercise_goals values ('10000000-0000-0000-0000-000000000001','01000000-0000-0000-0000-000000000001');
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version,published_at,release_id) values
  ('60000000-0000-0000-0000-000000000001','raha_rt_free','published','beginner','free',100,1,now()-interval '1 minute',1),
  ('60000000-0000-0000-0000-000000000002','raha_rt_other','draft','beginner','free',100,1,null,1),
  ('60000000-0000-0000-0000-000000000003','raha_rt_future','published','beginner','free',100,1,now()-interval '1 minute',2),
  ('60000000-0000-0000-0000-000000000004','raha_rt_premium','published','beginner','premium',100,1,now()-interval '1 minute',1);
insert into public.routine_translations values ('60000000-0000-0000-0000-000000000001','en','Free routine','Safe summary'),('60000000-0000-0000-0000-000000000001','ar','روتين مجاني','ملخص آمن'),('60000000-0000-0000-0000-000000000003','en','Future routine','Future summary'),('60000000-0000-0000-0000-000000000004','en','Premium routine','Premium summary');
insert into public.routine_body_areas values ('60000000-0000-0000-0000-000000000001','02000000-0000-0000-0000-000000000001',1);
insert into public.routine_goals values ('60000000-0000-0000-0000-000000000001','01000000-0000-0000-0000-000000000001',1);
insert into public.routine_positions values ('60000000-0000-0000-0000-000000000001','03000000-0000-0000-0000-000000000001');
insert into public.routine_equipment values ('60000000-0000-0000-0000-000000000001','04000000-0000-0000-0000-000000000001');
insert into public.routine_steps(id,routine_id,exercise_id,position,duration_seconds) values ('61000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',1,100),('61000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001',1,100),('61000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000002',1,100),('61000000-0000-0000-0000-000000000004','60000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000004',1,100);
do $$ begin insert into public.routine_steps(routine_id,exercise_id,position,repetition_count) values ('60000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001',2,5); raise exception 'repetition-only routine step accepted'; exception when not_null_violation then null; end $$;
do $$ begin insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,target_duration_seconds) values ('70000000-0000-0000-0000-000000000099','61000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',1,null); raise exception 'nullable session target accepted'; exception when not_null_violation then null; end $$;
insert into public.content_providers(id,key,name,license_type,license_reference) values ('20000000-0000-0000-0000-000000000001','test_provider','Private provider','commercial','private-license');
insert into public.provider_exercises(provider_id,source_exercise_id,exercise_id,source_payload) values ('20000000-0000-0000-0000-000000000001','private-source','10000000-0000-0000-0000-000000000001','{"private":true}');
insert into public.achievements(id,key,category,criteria_version,criteria,status) values ('50000000-0000-0000-0000-000000000001','first_step','consistency',1,'{}','published');
insert into public.point_ledger(user_id,points,reason_code,source_type,source_id) values ('00000000-0000-0000-0000-000000000001',5,'completion','session','70000000-0000-0000-0000-000000000001');
insert into public.user_achievements(user_id,achievement_id,criteria_version) values ('00000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',1);
insert into public.user_streaks(user_id,rule_version) values ('00000000-0000-0000-0000-000000000001','v1');
insert into public.user_entitlements(user_id,entitlement_key,is_active,environment,provider_event_id) values ('00000000-0000-0000-0000-000000000001','premium',false,'sandbox','provider-test-event');

do $$
begin
  if not exists (select 1 from pg_constraint where conrelid='public.routine_steps'::regclass and conname='routine_steps_routine_id_position_key') then raise exception 'routine step uniqueness missing'; end if;
  if not exists (select 1 from pg_constraint where conrelid='public.routine_steps'::regclass and conname='routine_steps_timed_only') then raise exception 'timed-step check missing'; end if;
  if not exists (select 1 from pg_constraint where conrelid='public.routine_sessions'::regclass and conname like '%routine_id_fkey%') then raise exception 'session routine foreign key missing'; end if;
  if (select count(*) from pg_indexes where schemaname='public' and indexname in ('sessions_owner_started','media_assets_one_preferred_published','point_ledger_idempotent_source')) <> 3 then raise exception 'required database indexes missing'; end if;
end $$;

set local role anon;
do $$ declare m jsonb; n integer; begin
  select manifest into m from public.get_next_free_content_release(0,'1.0.0');
  if m is null or jsonb_array_length(m->'exercises') <> 1 or jsonb_array_length(m->'media_assets') <> 1 or jsonb_array_length(m->'routine_steps') <> 1 then raise exception 'eligible manifest did not contain only free released children'; end if;
  if jsonb_array_length(m->'exercise_translations') <> 2 or jsonb_array_length(m->'routine_translations') <> 2 or jsonb_array_length(m->'body_area_translations') <> 2 or jsonb_array_length(m->'goal_translations') <> 2 or jsonb_array_length(m->'movement_position_translations') <> 2 or jsonb_array_length(m->'equipment_translations') <> 2 then raise exception 'manifest lacks bilingual offline catalog data'; end if;
  if jsonb_array_length(m->'exercise_positions') <> 1 or jsonb_array_length(m->'exercise_equipment') <> 1 or jsonb_array_length(m->'exercise_goals') <> 1 or jsonb_array_length(m->'routine_equipment') <> 1 then raise exception 'manifest lacks recommendation or playback relations'; end if;
  if jsonb_path_exists(m,'$.**.storage_key') or jsonb_path_exists(m,'$.**.storage_bucket') or jsonb_path_exists(m,'$.**.provider_id') or jsonb_path_exists(m,'$.**.provider') or jsonb_path_exists(m,'$.**.license_reference') or jsonb_path_exists(m,'$.**.license_type') or jsonb_path_exists(m,'$.**.source_payload') or jsonb_path_exists(m,'$.**.source_exercise_id') then raise exception 'manifest contains a forbidden private key'; end if;
  if m::text like '%private-media%' or m::text like '%private-license%' or m::text like '%commercial%' then raise exception 'manifest leaks private delivery or provenance value'; end if;
  select count(*) into n from public.get_next_free_content_release(0,'0.9.0'); if n <> 0 then raise exception 'incompatible app obtained a release'; end if;
  begin perform public.get_next_free_content_release(0,'not-semver'); raise exception 'malformed app version accepted'; exception when raise_exception then if sqlerrm <> 'app_version must be MAJOR.MINOR.PATCH' then raise; end if; end;
end $$;
do $$ begin if has_schema_privilege('anon','public','create') then raise exception 'anon can create in public schema'; end if; end $$;
do $$ begin perform count(*) from public.exercises; raise exception 'anon direct catalog read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.exercise_translations; raise exception 'anon direct translation read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.media_assets; raise exception 'anon direct media read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.exercise_body_areas; raise exception 'anon direct classification read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.routine_steps; raise exception 'anon direct step read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.provider_exercises; raise exception 'anon provider import read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.content_providers; raise exception 'anon provider registry read allowed'; exception when insufficient_privilege then null; end $$;
reset role;

set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
insert into public.user_preferences(user_id) values ('00000000-0000-0000-0000-000000000001');
insert into public.user_preferred_positions(user_id,position_id) values ('00000000-0000-0000-0000-000000000001','03000000-0000-0000-0000-000000000001');
insert into public.user_avoided_exercises(user_id,exercise_id,reason_code) values ('00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','uncomfortable');
insert into public.user_body_area_preferences(user_id,body_area_id,preference_type) values ('00000000-0000-0000-0000-000000000001','02000000-0000-0000-0000-000000000001','preferred');
insert into public.reminder_schedules(id,user_id,local_time,days_of_week,timezone) values ('40000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','09:00',array[1]::smallint[],'Asia/Riyadh');
insert into public.check_ins(id,user_id,body_state,goal_id,available_minutes,started_at) values ('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','stiff','01000000-0000-0000-0000-000000000001',5,now());
insert into public.check_in_body_areas(check_in_id,body_area_id) values ('30000000-0000-0000-0000-000000000001','02000000-0000-0000-0000-000000000001');
insert into public.recommendations(id,user_id,check_in_id,routine_id,engine_version,rank,score,shown_at) values ('31000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','rules-v1',1,1,now());
insert into public.saved_routines(user_id,routine_id) values ('00000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001');
do $$ begin perform count(*) from public.exercises; raise exception 'authenticated direct catalog read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.content_providers; raise exception 'authenticated provider registry read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform count(*) from public.provider_exercises; raise exception 'authenticated provider import read allowed'; exception when insufficient_privilege then null; end $$;
do $$ begin perform public.start_routine_session('70000000-0000-0000-0000-000000000010','60000000-0000-0000-0000-000000000002',1,null,'explore','1.0.0'); raise exception 'draft routine start accepted'; exception when raise_exception then if sqlerrm <> 'routine is unavailable' then raise; end if; end $$;
do $$ begin perform public.start_routine_session('70000000-0000-0000-0000-000000000011','60000000-0000-0000-0000-000000000003',1,null,'explore','1.0.0'); raise exception 'future routine start accepted'; exception when raise_exception then if sqlerrm <> 'routine is unavailable' then raise; end if; end $$;
do $$ begin perform public.start_routine_session('70000000-0000-0000-0000-000000000012','60000000-0000-0000-0000-000000000004',1,null,'explore','1.0.0'); raise exception 'premium routine start accepted'; exception when raise_exception then if sqlerrm <> 'routine is unavailable' then raise; end if; end $$;
do $$ begin perform public.start_routine_session('70000000-0000-0000-0000-000000000013','60000000-0000-0000-0000-000000000001',2,null,'explore','1.0.0'); raise exception 'mismatched routine version start accepted'; exception when raise_exception then if sqlerrm <> 'routine is unavailable' then raise; end if; end $$;
select public.start_routine_session('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',1,'31000000-0000-0000-0000-000000000001','recommendation','1.0.0');
do $$ declare id uuid; begin id := public.start_routine_session('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',1,'31000000-0000-0000-0000-000000000001','recommendation','1.0.0'); if id <> '70000000-0000-0000-0000-000000000001'::uuid then raise exception 'session start was not idempotent'; end if; end $$;
do $$ begin insert into public.routine_sessions(id,user_id,routine_id,routine_version,status,started_at,target_duration_seconds,total_step_count_snapshot,completion_policy_version,source) values ('70000000-0000-0000-0000-000000000014','00000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',1,'in_progress',now(),100,1,'raha_001_v1','explore'); raise exception 'direct routine session start accepted'; exception when insufficient_privilege then null; end $$;
do $$ begin update public.routine_sessions set last_credited_at=now() where id='70000000-0000-0000-0000-000000000001'; raise exception 'client changed expiry activity time'; exception when insufficient_privilege then null; end $$;
do $$ begin perform public.expire_stale_routine_sessions(); raise exception 'client invoked global expiry maintenance'; exception when insufficient_privilege then null; end $$;
do $$ begin update public.routine_sessions set status='completed',completed_at=now() where id='70000000-0000-0000-0000-000000000001'; raise exception 'client directly completed session'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds) values ('70000000-0000-0000-0000-000000000001','61000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001',1,'completed',100,100); raise exception 'foreign-routine step accepted'; exception when insufficient_privilege then null; end $$;
insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds,started_at,finished_at) values ('70000000-0000-0000-0000-000000000001','61000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',1,'completed',100,100,now()-interval '100 seconds',now());
do $$ declare result public.session_status; begin result := public.complete_routine_session('70000000-0000-0000-0000-000000000001','raha_001_v1'); if result <> 'completed' then raise exception 'qualifying session was not completed'; end if; end $$;
do $$ declare n integer; begin update public.routine_sessions set status='in_progress' where id='70000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'terminal session reopened'; end if; end $$;
insert into public.session_feedback(session_id,user_id,rating,note) values ('70000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','little_better','private');
select public.start_routine_session('70000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000001',1,null,'explore','1.0.0');
insert into public.session_steps(session_id,routine_step_id,exercise_id_snapshot,position_snapshot,status,target_duration_seconds,active_duration_seconds) values ('70000000-0000-0000-0000-000000000002','61000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',1,'partial',100,1);
do $$ declare result public.session_status; begin result := public.complete_routine_session('70000000-0000-0000-0000-000000000002','raha_001_v1'); if result <> 'abandoned' then raise exception 'nonqualifying session was not abandoned'; end if; end $$;
select public.start_routine_session('70000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000001',1,null,'explore','1.0.0');
reset role;
update public.routine_sessions set last_credited_at = now() - interval '24 hours' where id='70000000-0000-0000-0000-000000000003';
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
do $$ declare n integer; begin select count(*) into n from public.expire_my_stale_routine_sessions(); if n <> 1 then raise exception 'stale session was not expired'; end if; select count(*) into n from public.expire_my_stale_routine_sessions(); if n <> 0 then raise exception 'expiry was not idempotent'; end if; end $$;
do $$ declare n integer; begin select count(*) into n from public.profiles; if n <> 1 then raise exception 'owner profile read failed'; end if; select count(*) into n from public.user_preferences; if n <> 1 then raise exception 'owner preferences read failed'; end if; select count(*) into n from public.user_preferred_positions; if n <> 1 then raise exception 'owner preferred positions read failed'; end if; select count(*) into n from public.user_avoided_exercises; if n <> 1 then raise exception 'owner avoided exercises read failed'; end if; select count(*) into n from public.user_body_area_preferences; if n <> 1 then raise exception 'owner body preferences read failed'; end if; select count(*) into n from public.check_ins; if n <> 1 then raise exception 'owner check-in read failed'; end if; select count(*) into n from public.check_in_body_areas; if n <> 1 then raise exception 'owner check-in areas read failed'; end if; select count(*) into n from public.recommendations; if n <> 1 then raise exception 'owner recommendation read failed'; end if; select count(*) into n from public.routine_sessions; if n <> 3 then raise exception 'owner session read failed'; end if; select count(*) into n from public.session_steps; if n <> 2 then raise exception 'owner step read failed'; end if; select count(*) into n from public.session_feedback; if n <> 1 then raise exception 'owner feedback read failed'; end if; select count(*) into n from public.mobile_session_feedback; if n <> 1 then raise exception 'owner feedback view read failed'; end if; select count(*) into n from public.saved_routines; if n <> 1 then raise exception 'owner saved routine read failed'; end if; select count(*) into n from public.reminder_schedules; if n <> 1 then raise exception 'owner reminder read failed'; end if; end $$;
do $$ begin delete from public.profiles where user_id='00000000-0000-0000-0000-000000000001'; raise exception 'client deleted profile'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.exercises(public_id,status,difficulty,access_tier) values ('raha_ex_client_write','draft','beginner','free'); raise exception 'client catalog write allowed'; exception when insufficient_privilege then null; end $$;

select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
do $$ declare n integer; begin
  select count(*) into n from public.profiles; if n <> 1 then raise exception 'other user profile scope wrong'; end if;
  select count(*) into n from public.user_preferences; if n <> 0 then raise exception 'other user read preferences'; end if;
  select count(*) into n from public.user_preferred_positions; if n <> 0 then raise exception 'other user read preferred positions'; end if;
  select count(*) into n from public.user_avoided_exercises; if n <> 0 then raise exception 'other user read avoided exercises'; end if;
  select count(*) into n from public.user_body_area_preferences; if n <> 0 then raise exception 'other user read body preferences'; end if;
  select count(*) into n from public.check_ins; if n <> 0 then raise exception 'other user read check-ins'; end if;
  select count(*) into n from public.check_in_body_areas; if n <> 0 then raise exception 'other user read check-in areas'; end if;
  select count(*) into n from public.recommendations; if n <> 0 then raise exception 'other user read recommendations'; end if;
  select count(*) into n from public.routine_sessions; if n <> 0 then raise exception 'other user read sessions'; end if;
  select count(*) into n from public.session_steps; if n <> 0 then raise exception 'other user read session steps'; end if;
  select count(*) into n from public.session_feedback; if n <> 0 then raise exception 'other user read feedback'; end if;
  select count(*) into n from public.mobile_session_feedback; if n <> 0 then raise exception 'other user read feedback view'; end if;
  select count(*) into n from public.saved_routines; if n <> 0 then raise exception 'other user read saved routines'; end if;
   select count(*) into n from public.reminder_schedules; if n <> 0 then raise exception 'other user read reminders'; end if;
   select count(*) into n from public.point_ledger; if n <> 0 then raise exception 'other user read ledger'; end if;
   select count(*) into n from public.user_achievements; if n <> 0 then raise exception 'other user read achievements'; end if;
   select count(*) into n from public.user_streaks; if n <> 0 then raise exception 'other user read streaks'; end if;
   select count(*) into n from public.user_entitlements; if n <> 0 then raise exception 'other user read entitlements'; end if;
  update public.profiles set display_name='attacker' where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated profile'; end if;
  update public.user_preferences set sound_enabled=false where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated preferences'; end if;
  delete from public.user_preferred_positions where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated preferred positions'; end if;
  delete from public.user_avoided_exercises where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated avoided exercises'; end if;
  delete from public.user_body_area_preferences where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated body preferences'; end if;
  update public.check_ins set body_state='tired' where id='30000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated check-in'; end if;
  delete from public.check_in_body_areas where check_in_id='30000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated check-in areas'; end if;
  update public.recommendations set score=99 where id='31000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated recommendation'; end if;
  update public.routine_sessions set status='abandoned',completed_at=now() where id='70000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated session'; end if;
  update public.session_steps set active_duration_seconds=1 where session_id='70000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated step'; end if;
  update public.session_feedback set rating='same' where session_id='70000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated feedback'; end if;
  update public.saved_routines set deleted_at=now() where user_id='00000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated saved routine'; end if;
  update public.reminder_schedules set enabled=false where id='40000000-0000-0000-0000-000000000001'; get diagnostics n = row_count; if n <> 0 then raise exception 'other user mutated reminder'; end if;
end $$;
do $$ begin perform public.complete_routine_session('70000000-0000-0000-0000-000000000001','raha_001_v1'); raise exception 'other user invoked definer session RPC'; exception when raise_exception then if sqlerrm <> 'session not found' then raise; end if; end $$;
do $$ begin insert into public.point_ledger(user_id,points,reason_code,source_type) values ('00000000-0000-0000-0000-000000000002',5,'test','test'); raise exception 'client wrote ledger'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.user_entitlements(user_id,entitlement_key,is_active,environment,provider_event_id) values ('00000000-0000-0000-0000-000000000002','premium',true,'sandbox','test-event'); raise exception 'client wrote entitlement'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.user_achievements(user_id,achievement_id,criteria_version) values ('00000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000001',1); raise exception 'client wrote achievement'; exception when insufficient_privilege then null; end $$;
do $$ begin insert into public.user_streaks(user_id,rule_version) values ('00000000-0000-0000-0000-000000000002','v1'); raise exception 'client wrote streak'; exception when insufficient_privilege then null; end $$;
reset role;
rollback;

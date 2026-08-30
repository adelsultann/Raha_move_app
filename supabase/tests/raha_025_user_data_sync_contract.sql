-- Local/disposable RAHA-025 trusted push/pull contract. Run after db reset.
begin;
insert into auth.users (id,aud,role,email,encrypted_password,email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
 ('02500000-0000-0000-0000-000000000001','authenticated','authenticated','sync-owner@example.test','',now(),'{}','{}',now(),now()),
 ('02500000-0000-0000-0000-000000000002','authenticated','authenticated','sync-other@example.test','',now(),'{}','{}',now(),now());
insert into public.profiles(user_id) values ('02500000-0000-0000-0000-000000000001'),('02500000-0000-0000-0000-000000000002');
insert into public.content_releases(id,version,published_at,manifest_checksum) overriding system value values (25,'sync-test',now()-interval '1 minute',repeat('a',64));
insert into public.goals(id,key) values ('02500000-0000-0000-0000-000000000010','ease_stiffness');
insert into public.body_areas(id,key) values
 ('02500000-0000-0000-0000-000000000014','neck'),
 ('02500000-0000-0000-0000-000000000015','shoulders');
insert into public.exercises(id,public_id,status,difficulty,release_id) values ('02500000-0000-0000-0000-000000000011','raha_ex_sync','published','beginner',25);
insert into public.routines(id,public_id,status,difficulty,estimated_duration_seconds,version,published_at,release_id) values ('02500000-0000-0000-0000-000000000012','raha_rt_sync','published','beginner',100,1,now()-interval '1 minute',25);
insert into public.routine_steps(id,routine_id,exercise_id,position,duration_seconds) values ('02500000-0000-0000-0000-000000000013','02500000-0000-0000-0000-000000000012','02500000-0000-0000-0000-000000000011',1,100);
set local role authenticated;
select set_config('request.jwt.claim.sub','02500000-0000-0000-0000-000000000001',true);
do $$ begin
 if not has_function_privilege('authenticated','public.sync_push_user_data(jsonb)','execute')
    or not has_function_privilege('authenticated','public.sync_pull_user_data(bigint,integer)','execute')
    or has_function_privilege('anon','public.sync_push_user_data(jsonb)','execute')
    or has_function_privilege('authenticated','public.sync_authoritative_projections(uuid)','execute') then
   raise exception 'RAHA-025 RPC ACL is incorrect';
 end if;
 begin perform count(*) from public.user_sync_changes; raise exception 'client can read sync change log'; exception when insufficient_privilege then null; end;
end $$;
do $$ begin
  begin
    perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000109','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000029','body_state','stiff','goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('02500000-0000-0000-0000-000000000014'),'attacker_field','no'))));
    raise exception 'unknown wire field accepted';
  exception when raise_exception then if sqlerrm <> 'check_in_upsert payload contains unknown field attacker_field' then raise; end if; end;
   begin
     perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000110','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000030','body_state',repeat('x',17),'goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('02500000-0000-0000-0000-000000000014')))));
     raise exception 'oversized string accepted';
   exception when raise_exception then if sqlerrm <> 'body_state must be a non-empty string of at most 16 bytes' then raise; end if; end;
   begin
     perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000112','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000031','body_state','stiff','goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('not-a-uuid')))));
     raise exception 'invalid body area ID accepted';
   exception when raise_exception then if sqlerrm <> 'body_area_ids must contain UUIDs' then raise; end if; end;
   begin
     perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000113','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000032','body_state','stiff','goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('02500000-0000-0000-0000-000000000014','02500000-0000-0000-0000-000000000014')))));
     raise exception 'duplicate body area IDs accepted';
   exception when raise_exception then if sqlerrm <> 'body_area_ids must be unique' then raise; end if; end;
   begin
     perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000114','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000033','body_state','stiff','goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('02500000-0000-0000-0000-000000000014','02500000-0000-0000-0000-000000000015','02500000-0000-0000-0000-000000000016','02500000-0000-0000-0000-000000000017','02500000-0000-0000-0000-000000000018','02500000-0000-0000-0000-000000000019','02500000-0000-0000-0000-000000000020','02500000-0000-0000-0000-000000000021')))));
     raise exception 'too many body area IDs accepted';
   exception when raise_exception then if sqlerrm <> 'body_area_ids must contain between 1 and 7 UUIDs' then raise; end if; end;
 end $$;
do $$ declare r jsonb; begin
 r:=public.sync_push_user_data(jsonb_build_array(
  jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000101','kind','check_in_upsert','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000021','body_state','stiff','goal_id','02500000-0000-0000-0000-000000000010','available_minutes',5,'started_at','2026-08-30T10:00:00Z','body_area_ids',jsonb_build_array('02500000-0000-0000-0000-000000000015','02500000-0000-0000-0000-000000000014'))),
  jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000102','kind','session_start','payload',jsonb_build_object('id','02500000-0000-0000-0000-000000000022','routine_id','02500000-0000-0000-0000-000000000012','routine_version',1,'source','explore','app_version','1.0.0')),
  jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000103','kind','session_step_upsert','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','routine_step_id','02500000-0000-0000-0000-000000000013','exercise_id_snapshot','02500000-0000-0000-0000-000000000011','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)),
  jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000104','kind','session_finalize','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','completion_policy_version','raha_001_v1')),
  jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000105','kind','saved_routine_set','payload',jsonb_build_object('routine_id','02500000-0000-0000-0000-000000000012','saved',false,'operation_at','2026-08-30T10:01:00Z'))));
 if r->'projections' is null or (select status from public.routine_sessions where id='02500000-0000-0000-0000-000000000022') <> 'completed' then raise exception 'push did not create terminal session/projections'; end if;
 if (select count(*) from public.check_in_body_areas where check_in_id='02500000-0000-0000-0000-000000000021') <> 2 then raise exception 'check-in body areas were not synchronized'; end if;
 if r #> '{operations,3,reward_result}' is null or r #>> '{operations,3,reward_result,version}' <> 'raha_025_reward_result_v1' or jsonb_array_length(r #> '{operations,3,reward_result,awards,points}') <> 0 then raise exception 'finalization reward result contract is incorrect'; end if;
 begin update public.routine_sessions set status='abandoned' where id='02500000-0000-0000-0000-000000000022'; raise exception 'direct session update accepted'; exception when insufficient_privilege then null; end;
 begin delete from public.routine_sessions where id='02500000-0000-0000-0000-000000000022'; raise exception 'direct session delete accepted'; exception when insufficient_privilege then null; end;
 if not exists (select 1 from jsonb_array_elements(public.sync_pull_user_data(0,100)->'changes') change where change->>'entity_type'='check_in' and change->'payload' ? 'body_area_ids') then raise exception 'canonical check-in change omitted body_area_ids'; end if;
 if (public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000104','kind','session_finalize','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','completion_policy_version','raha_001_v1')))) #> '{operations,0,reward_result}') <> (r #> '{operations,3,reward_result}') then raise exception 'finalization retry changed reward_result'; end if;
 perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000105','kind','saved_routine_set','payload',jsonb_build_object('routine_id','02500000-0000-0000-0000-000000000012','saved',false,'operation_at','2026-08-30T10:01:00Z'))));
 if (select count(*) from public.saved_routines where user_id=auth.uid())<>1 then raise exception 'identical retry duplicated saved routine'; end if;
 perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000106','kind','saved_routine_set','payload',jsonb_build_object('routine_id','02500000-0000-0000-0000-000000000012','saved',true,'operation_at','2026-08-30T10:00:00Z'))));
 if (select deleted_at is null from public.saved_routines where user_id=auth.uid() and routine_id='02500000-0000-0000-0000-000000000012') then raise exception 'older save resurrected tombstone'; end if;
  begin perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000108','kind','session_step_upsert','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','routine_step_id','02500000-0000-0000-0000-000000000013','exercise_id_snapshot','02500000-0000-0000-0000-000000000011','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',101)))); raise exception 'over-target device time accepted'; exception when raise_exception then if sqlerrm <> 'active_duration_seconds must be between 0 and target_duration_seconds' then raise; end if; end;
  perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000111','kind','feedback_upsert','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','rating','same','note','private feedback note'))));
  begin perform public.sync_push_user_data(jsonb_build_array(jsonb_build_object('operation_id','02500000-0000-0000-0000-000000000107','kind','session_step_upsert','payload',jsonb_build_object('session_id','02500000-0000-0000-0000-000000000022','routine_step_id','02500000-0000-0000-0000-000000000013','exercise_id_snapshot','02500000-0000-0000-0000-000000000011','position_snapshot',1,'status','completed','target_duration_seconds',100,'active_duration_seconds',100)))); raise exception 'terminal session accepted a step'; exception when raise_exception then if sqlerrm <> 'session is missing or terminal' then raise; end if; end;
  if jsonb_array_length(public.sync_pull_user_data(0,100)->'changes') < 6 then raise exception 'pull did not return cursor changes'; end if;
  if jsonb_path_exists(public.sync_pull_user_data(0,100),'$.changes[*].payload.note') then raise exception 'change feed retained feedback note'; end if;
end $$;
select set_config('request.jwt.claim.sub','02500000-0000-0000-0000-000000000002',true);
do $$ begin if jsonb_array_length(public.sync_pull_user_data(0,100)->'changes')<>0 then raise exception 'cross-user pull leak'; end if; end $$;
reset role;
do $$ begin
  update public.sync_applied_operations set applied_at=now()-interval '31 days' where user_id='02500000-0000-0000-0000-000000000001';
  if public.purge_expired_sync_diagnostics(now()-interval '30 days') = 0 then raise exception '30-day sync diagnostic retention was not applied'; end if;
  delete from public.profiles where user_id='02500000-0000-0000-0000-000000000001';
  if exists (select 1 from public.sync_applied_operations where user_id='02500000-0000-0000-0000-000000000001') or exists (select 1 from public.user_sync_changes where user_id='02500000-0000-0000-0000-000000000001') then raise exception 'account deletion left sync records'; end if;
end $$;
rollback;

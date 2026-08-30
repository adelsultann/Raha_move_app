-- Local/disposable RAHA-024 release RPC contract test. Run after db reset.
begin;
insert into public.content_releases(id,version,published_at,minimum_app_version,manifest_checksum) overriding system value values
  (240,'raha-024-contract',now()-interval '1 minute','1.0.0',repeat('0',64));
insert into public.body_areas(id,key) values ('24000000-0000-0000-0000-000000000001','neck');
insert into public.goals(id,key) values ('24000000-0000-0000-0000-000000000001','ease_stiffness');
insert into public.movement_positions(id,key) values ('24000000-0000-0000-0000-000000000001','seated');
insert into public.equipment(id,key) values ('24000000-0000-0000-0000-000000000001','body_weight');
insert into public.body_area_translations values ('24000000-0000-0000-0000-000000000001','ar','الرقبة'),('24000000-0000-0000-0000-000000000001','en','Neck');
insert into public.goal_translations values ('24000000-0000-0000-0000-000000000001','ar','تخفيف التيبس'),('24000000-0000-0000-0000-000000000001','en','Ease stiffness');
insert into public.movement_position_translations values ('24000000-0000-0000-0000-000000000001','ar','جلوس'),('24000000-0000-0000-0000-000000000001','en','Seated');
insert into public.equipment_translations values ('24000000-0000-0000-0000-000000000001','ar','وزن الجسم'),('24000000-0000-0000-0000-000000000001','en','Body weight');
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id,safety_approved_at) values ('24100000-0000-0000-0000-000000000001','raha_ex_contract','published','beginner','free',240,now());
insert into public.exercise_translations values ('24100000-0000-0000-0000-000000000001','ar','تمرين آمن','وصف آمن','توقف عند الألم الحاد'),('24100000-0000-0000-0000-000000000001','en','Safe exercise','Safe description','Stop for sharp pain');
insert into public.media_assets(id,exercise_id,media_type,storage_bucket,storage_key,mime_type,checksum_sha256,is_preferred,status) values ('24200000-0000-0000-0000-000000000001','24100000-0000-0000-0000-000000000001','video','private-media','private/path.mp4','video/mp4',repeat('a',64),true,'published');
insert into public.routines(id,public_id,status,difficulty,access_tier,estimated_duration_seconds,version,published_at,release_id,safety_approved_at) values ('24300000-0000-0000-0000-000000000001','raha_rt_contract','published','beginner','free',60,1,now()-interval '1 minute',240,now());
insert into public.routine_translations values ('24300000-0000-0000-0000-000000000001','ar','روتين آمن','ملخص آمن'),('24300000-0000-0000-0000-000000000001','en','Safe routine','Safe summary');
insert into public.routine_steps(id,routine_id,exercise_id,position,duration_seconds) values ('24400000-0000-0000-0000-000000000001','24300000-0000-0000-0000-000000000001','24100000-0000-0000-0000-000000000001',1,60);
insert into public.exercise_body_areas values ('24100000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001',1);
insert into public.exercise_positions values ('24100000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001');
insert into public.exercise_equipment values ('24100000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001');
insert into public.exercise_goals values ('24100000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001');
insert into public.routine_body_areas values ('24300000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001',1);
insert into public.routine_goals values ('24300000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001',1);
insert into public.routine_positions values ('24300000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001');
insert into public.routine_equipment values ('24300000-0000-0000-0000-000000000001','24000000-0000-0000-0000-000000000001');
insert into public.content_release_tombstones(release_id,entity_type,entity_id,retired_at,entity_public_id) values (240,'routine','24300000-0000-0000-0000-000000000099',now(),'raha_rt_retired');
update public.content_releases set manifest_checksum=encode(digest(convert_to(public.content_release_manifest(240)::text,'UTF8'),'sha256'),'hex') where id=240;
set local role anon;
do $$ declare m jsonb; c text; begin
  select manifest, manifest_checksum into m,c from public.get_next_content_release(239,'1.0.0');
  if m is null or c <> encode(digest(convert_to(m::text,'UTF8'),'sha256'),'hex') then raise exception 'canonical manifest checksum mismatch'; end if;
  if not (m ? 'routine_contexts') or not (m ? 'tombstones') or not (m->'exercises'->0 ? 'status') or not (m->'exercises'->0 ? 'access_tier') or not (m->'exercises'->0 ? 'safety_approved') or not (m->'media_assets'->0 ? 'delivery_reference') then raise exception 'required local catalog contract fields missing'; end if;
  if jsonb_path_exists(m,'$.**.storage_key') or jsonb_path_exists(m,'$.**.storage_bucket') or jsonb_path_exists(m,'$.**.provider_id') or jsonb_path_exists(m,'$.**.provider') or jsonb_path_exists(m,'$.**.license_reference') or m::text like '%private/path.mp4%' then raise exception 'private media data leaked'; end if;
  if has_function_privilege('anon','public.content_release_manifest(bigint)','execute') or has_function_privilege('anon','public.content_release_contract_is_valid(bigint)','execute') or has_function_privilege('anon','public.content_release_manifest_release_delta(bigint)','execute') or has_function_privilege('anon','public.release_filter_by_ids(jsonb,text,text[])','execute') or has_function_privilege('anon','public.get_next_free_content_release(bigint,text)','execute') then raise exception 'release helper or legacy RPC was exposed'; end if;
end $$;
reset role;
-- Release 241 changes only one exercise. Its complete snapshot must retain
-- release-240 routine/exercise rows rather than behaving as a delta.
insert into public.content_releases(id,version,published_at,minimum_app_version,manifest_checksum) overriding system value values (241,'raha-024-contract-2',now()-interval '1 minute','1.0.0',repeat('0',64));
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id,safety_approved_at) values ('24100000-0000-0000-0000-000000000002','raha_ex_contract_two','published','beginner','free',241,now());
insert into public.exercises(id,public_id,status,difficulty,access_tier,release_id,safety_approved_at) values ('24100000-0000-0000-0000-000000000003','raha_ex_contract_premium','published','beginner','premium',241,now());
insert into public.exercise_translations values ('24100000-0000-0000-0000-000000000002','ar','تمرين آمن ثان','وصف آمن','توقف عند الألم الحاد'),('24100000-0000-0000-0000-000000000002','en','Second safe exercise','Safe description','Stop for sharp pain');
insert into public.media_assets(id,exercise_id,media_type,storage_bucket,storage_key,mime_type,checksum_sha256,is_preferred,status) values ('24200000-0000-0000-0000-000000000002','24100000-0000-0000-0000-000000000002','animation','private-media','private/path-2.mp4','video/mp4',repeat('b',64),true,'published');
update public.content_releases set manifest_checksum=encode(digest(convert_to(public.content_release_manifest(241)::text,'UTF8'),'sha256'),'hex') where id=241;
set local role anon;
do $$ declare m jsonb; begin
  select manifest into m from public.get_next_content_release(240,'1.0.0');
  if jsonb_array_length(m->'exercises')<>2 or not jsonb_path_exists(m,'$.routines[*] ? (@.public_id == "raha_rt_contract")') then raise exception 'release-two snapshot omitted unchanged release-one catalog'; end if;
  if exists(select 1 from jsonb_array_elements(m->'exercises') where value->>'access_tier'<>'free') then raise exception 'non-free content leaked to anonymous snapshot'; end if;
  if not (m->'tombstones'->0 ? 'entity_public_id') then raise exception 'tombstone lacks client-resolvable public id'; end if;
end $$;
reset role;
rollback;

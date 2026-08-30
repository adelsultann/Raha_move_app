-- RAHA-024 security follow-up: free-only, complete catalog snapshots.
alter table public.content_release_tombstones add column entity_public_id text;
update public.content_release_tombstones t set entity_public_id = case t.entity_type
  when 'exercise' then (select e.public_id from public.exercises e where e.id=t.entity_id)
  when 'routine' then (select r.public_id from public.routines r where r.id=t.entity_id)
  when 'media_asset' then (select m.delivery_reference::text from public.media_assets m where m.id=t.entity_id)
end where entity_public_id is null;
alter table public.content_release_tombstones alter column entity_public_id set not null;

alter function public.content_release_manifest(bigint) rename to content_release_manifest_release_delta;
create function public.release_filter_by_ids(p_array jsonb, p_field text, p_ids text[])
returns jsonb language sql immutable set search_path = '' as $$
  select coalesce(jsonb_agg(value order by ordinality), '[]'::jsonb) from jsonb_array_elements(coalesce(p_array, '[]'::jsonb)) with ordinality where value ->> p_field = any(p_ids)
$$;
create function public.content_release_manifest(p_release_id bigint)
returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare base jsonb; snapshot jsonb; exercise_ids text[]; routine_ids text[]; tombstone_ids uuid[];
begin
  select public.content_release_manifest_release_delta(p_release_id) into base; if base is null then return null; end if;
  select jsonb_object_agg(key, case when key in ('contract_version','release','body_areas','body_area_translations','goals','goal_translations','movement_positions','movement_position_translations','equipment','equipment_translations','routine_contexts','routine_context_translations','tags','tag_translations') then base -> key when key = 'tombstones' then (select coalesce(jsonb_agg(jsonb_build_object('entity_type',t.entity_type,'entity_id',t.entity_id,'entity_public_id',t.entity_public_id,'retired_at',t.retired_at) order by t.entity_type,t.entity_public_id), '[]'::jsonb) from public.content_release_tombstones t where t.release_id <= p_release_id) else (select coalesce(jsonb_agg(value order by r.id, ordinality), '[]'::jsonb) from public.content_releases r cross join lateral jsonb_array_elements(public.content_release_manifest_release_delta(r.id) -> key) with ordinality where r.id <= p_release_id) end) into snapshot from jsonb_object_keys(base) key;
  select coalesce(array_agg((value->>'entity_id')::uuid), '{}'::uuid[]) into tombstone_ids from jsonb_array_elements(snapshot->'tombstones') where value->>'entity_type'='exercise';
  snapshot := snapshot || jsonb_build_object('exercises',coalesce((select jsonb_agg(value order by value->>'public_id') from jsonb_array_elements(snapshot->'exercises') where value->>'access_tier'='free' and not ((value->>'id')::uuid=any(tombstone_ids))),'[]'::jsonb));
  select coalesce(array_agg(value->>'id'),'{}'::text[]) into exercise_ids from jsonb_array_elements(snapshot->'exercises');
  select coalesce(array_agg((value->>'entity_id')::uuid),'{}'::uuid[]) into tombstone_ids from jsonb_array_elements(snapshot->'tombstones') where value->>'entity_type'='routine';
  snapshot := snapshot || jsonb_build_object('routines',coalesce((select jsonb_agg(value order by value->>'public_id') from jsonb_array_elements(snapshot->'routines') where value->>'access_tier'='free' and not ((value->>'id')::uuid=any(tombstone_ids))),'[]'::jsonb));
  select coalesce(array_agg(value->>'id'),'{}'::text[]) into routine_ids from jsonb_array_elements(snapshot->'routines');
  snapshot := snapshot || jsonb_build_object('exercise_translations',public.release_filter_by_ids(snapshot->'exercise_translations','exercise_id',exercise_ids),'media_assets',public.release_filter_by_ids(snapshot->'media_assets','exercise_id',exercise_ids),'exercise_body_areas',public.release_filter_by_ids(snapshot->'exercise_body_areas','exercise_id',exercise_ids),'exercise_positions',public.release_filter_by_ids(snapshot->'exercise_positions','exercise_id',exercise_ids),'exercise_equipment',public.release_filter_by_ids(snapshot->'exercise_equipment','exercise_id',exercise_ids),'exercise_goals',public.release_filter_by_ids(snapshot->'exercise_goals','exercise_id',exercise_ids),'exercise_tags',public.release_filter_by_ids(snapshot->'exercise_tags','exercise_id',exercise_ids),'routine_translations',public.release_filter_by_ids(snapshot->'routine_translations','routine_id',routine_ids),'routine_steps',public.release_filter_by_ids(public.release_filter_by_ids(snapshot->'routine_steps','routine_id',routine_ids),'exercise_id',exercise_ids),'routine_body_areas',public.release_filter_by_ids(snapshot->'routine_body_areas','routine_id',routine_ids),'routine_goals',public.release_filter_by_ids(snapshot->'routine_goals','routine_id',routine_ids),'routine_positions',public.release_filter_by_ids(snapshot->'routine_positions','routine_id',routine_ids),'routine_context_memberships',public.release_filter_by_ids(snapshot->'routine_context_memberships','routine_id',routine_ids),'routine_equipment',public.release_filter_by_ids(snapshot->'routine_equipment','routine_id',routine_ids));
  return snapshot;
end $$;

create or replace function public.content_release_contract_is_valid(p_release_id bigint)
returns boolean language sql stable security definer set search_path = public, pg_temp as $$
 select exists(select 1 from public.content_releases where id=p_release_id)
 and not exists(select 1 from public.exercises e where e.release_id<=p_release_id and e.status='published' and e.access_tier='free' and (e.safety_approved_at is null or not exists(select 1 from public.exercise_translations t where t.exercise_id=e.id and t.locale='ar') or not exists(select 1 from public.exercise_translations t where t.exercise_id=e.id and t.locale='en') or not exists(select 1 from public.media_assets m where m.exercise_id=e.id and m.status='published' and m.is_preferred and m.media_type in ('video','animation'))))
 and not exists(select 1 from public.routines x where x.release_id<=p_release_id and x.status='published' and x.access_tier='free' and (x.published_at is null or x.safety_approved_at is null or not exists(select 1 from public.routine_translations t where t.routine_id=x.id and t.locale='ar') or not exists(select 1 from public.routine_translations t where t.routine_id=x.id and t.locale='en') or exists(select 1 from public.routine_steps s left join public.exercises e on e.id=s.exercise_id where s.routine_id=x.id and (s.duration_seconds is null or s.repetition_count is not null or e.id is null or e.release_id>p_release_id or e.status<>'published' or e.access_tier<>'free' or e.safety_approved_at is null)) or x.estimated_duration_seconds<>coalesce((select sum(s.duration_seconds+s.rest_after_seconds) from public.routine_steps s where s.routine_id=x.id),0)))
 and not exists(select 1 from public.body_areas x where x.active and (not exists(select 1 from public.body_area_translations t where t.body_area_id=x.id and t.locale='ar') or not exists(select 1 from public.body_area_translations t where t.body_area_id=x.id and t.locale='en')))
 and not exists(select 1 from public.goals x where x.active and (not exists(select 1 from public.goal_translations t where t.goal_id=x.id and t.locale='ar') or not exists(select 1 from public.goal_translations t where t.goal_id=x.id and t.locale='en')))
 and not exists(select 1 from public.movement_positions x where x.active and (not exists(select 1 from public.movement_position_translations t where t.position_id=x.id and t.locale='ar') or not exists(select 1 from public.movement_position_translations t where t.position_id=x.id and t.locale='en')))
 and not exists(select 1 from public.equipment x where x.active and (not exists(select 1 from public.equipment_translations t where t.equipment_id=x.id and t.locale='ar') or not exists(select 1 from public.equipment_translations t where t.equipment_id=x.id and t.locale='en')))
 and not exists(select 1 from public.routine_contexts x where x.active and (not exists(select 1 from public.routine_context_translations t where t.context_id=x.id and t.locale='ar') or not exists(select 1 from public.routine_context_translations t where t.context_id=x.id and t.locale='en')))
 and not exists(select 1 from public.tags x where x.active and (not exists(select 1 from public.tag_translations t where t.tag_id=x.id and t.locale='ar') or not exists(select 1 from public.tag_translations t where t.tag_id=x.id and t.locale='en')))
$$;
create or replace function public.get_next_content_release(after_release_id bigint, app_version text)
returns table (release_id bigint, version text, published_at timestamptz, minimum_app_version text, manifest_checksum text, manifest jsonb)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if public.semver_parts(app_version) is null then raise exception 'app_version must be MAJOR.MINOR.PATCH'; end if;
  return query select r.id,r.version,r.published_at,r.minimum_app_version,r.manifest_checksum,m.manifest
  from public.content_releases r cross join lateral (select public.content_release_manifest(r.id) manifest) m
  where r.id>coalesce(after_release_id,0) and public.release_is_available(r.id,app_version)
    and public.content_release_contract_is_valid(r.id)
    and encode(digest(convert_to(m.manifest::text,'UTF8'),'sha256'),'hex')=r.manifest_checksum
  order by r.id limit 1;
end $$;
revoke all on function public.content_release_manifest_release_delta(bigint),public.content_release_manifest(bigint),public.content_release_contract_is_valid(bigint),public.release_filter_by_ids(jsonb,text,text[]),public.get_next_free_content_release(bigint,text),public.get_next_content_release(bigint,text) from public,anon,authenticated;
grant execute on function public.get_next_content_release(bigint,text) to anon,authenticated;

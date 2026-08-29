-- RAHA-022 forward-only catalog contract and deployment guard.
--
-- Deployment gate: for a new API environment, apply 20260829000000 through
-- this migration as one baseline before exposing PostgREST. Migration 00000
-- contains superseded direct catalog grants; 00100 revokes them. Existing
-- environments must apply this forward migration immediately.

do $$
begin
  if has_table_privilege('anon', 'public.exercises', 'select')
     or has_table_privilege('authenticated', 'public.exercises', 'select')
     or has_table_privilege('anon', 'public.media_assets', 'select')
     or has_table_privilege('authenticated', 'public.media_assets', 'select') then
    raise exception 'RAHA-022 deployment blocked: direct catalog grants must be revoked before the manifest RPC is published';
  end if;
end $$;

-- Stable Raha IDs are sufficient to authorize media separately. Deliberately
-- omit provider IDs, storage buckets/keys, raw imports, and license metadata.
create or replace function public.get_next_free_content_release(after_release_id bigint, app_version text)
returns table (release_id bigint, version text, published_at timestamptz, manifest_checksum text, manifest jsonb)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if public.semver_parts(app_version) is null then
    raise exception 'app_version must be MAJOR.MINOR.PATCH';
  end if;
  return query
  with selected as (
    select r.* from public.content_releases r
    where r.id > coalesce(after_release_id, 0)
      and public.release_is_available(r.id, app_version)
    order by r.id limit 1
  )
  select r.id, r.version, r.published_at, r.manifest_checksum,
    jsonb_build_object(
      'exercises', coalesce((select jsonb_agg(jsonb_build_object('id',e.id,'public_id',e.public_id,'difficulty',e.difficulty,'updated_at',e.updated_at)) from public.exercises e where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'exercise_translations', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',t.exercise_id,'locale',t.locale,'name',t.name,'description',t.description,'short_cue',t.short_cue)) from public.exercise_translations t join public.exercises e on e.id=t.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'media_assets', coalesce((select jsonb_agg(jsonb_build_object('id',m.id,'exercise_id',m.exercise_id,'media_type',m.media_type,'mime_type',m.mime_type,'width',m.width,'height',m.height,'duration_ms',m.duration_ms,'checksum_sha256',m.checksum_sha256,'is_preferred',m.is_preferred,'updated_at',m.updated_at)) from public.media_assets m join public.exercises e on e.id=m.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free' and m.status='published'),'[]'),
      'routines', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'public_id',x.public_id,'difficulty',x.difficulty,'estimated_duration_seconds',x.estimated_duration_seconds,'version',x.version,'updated_at',x.updated_at)) from public.routines x where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]'),
      'routine_translations', coalesce((select jsonb_agg(jsonb_build_object('routine_id',t.routine_id,'locale',t.locale,'name',t.name,'summary',t.summary)) from public.routine_translations t join public.routines x on x.id=t.routine_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]'),
      'routine_steps', coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'routine_id',s.routine_id,'exercise_id',s.exercise_id,'position',s.position,'duration_seconds',s.duration_seconds,'rest_after_seconds',s.rest_after_seconds,'side_mode',s.side_mode,'is_optional',s.is_optional)) from public.routine_steps s join public.routines x on x.id=s.routine_id join public.exercises e on e.id=s.exercise_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now() and e.status='published' and e.access_tier='free' and public.release_is_available(e.release_id,app_version)),'[]'),
      'body_areas', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order)) from public.body_areas x where x.active),'[]'),
      'body_area_translations', coalesce((select jsonb_agg(jsonb_build_object('body_area_id',t.body_area_id,'locale',t.locale,'name',t.name)) from public.body_area_translations t join public.body_areas x on x.id=t.body_area_id where x.active),'[]'),
      'goals', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order)) from public.goals x where x.active),'[]'),
      'goal_translations', coalesce((select jsonb_agg(jsonb_build_object('goal_id',t.goal_id,'locale',t.locale,'name',t.name)) from public.goal_translations t join public.goals x on x.id=t.goal_id where x.active),'[]'),
      'movement_positions', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order)) from public.movement_positions x where x.active),'[]'),
      'movement_position_translations', coalesce((select jsonb_agg(jsonb_build_object('position_id',t.position_id,'locale',t.locale,'name',t.name)) from public.movement_position_translations t join public.movement_positions x on x.id=t.position_id where x.active),'[]'),
      'equipment', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order)) from public.equipment x where x.active),'[]'),
      'equipment_translations', coalesce((select jsonb_agg(jsonb_build_object('equipment_id',t.equipment_id,'locale',t.locale,'name',t.name)) from public.equipment_translations t join public.equipment x on x.id=t.equipment_id where x.active),'[]'),
      'exercise_body_areas', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'body_area_id',j.body_area_id,'relevance_weight',j.relevance_weight)) from public.exercise_body_areas j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'exercise_positions', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'position_id',j.position_id)) from public.exercise_positions j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'exercise_equipment', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'equipment_id',j.equipment_id)) from public.exercise_equipment j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'exercise_goals', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'goal_id',j.goal_id)) from public.exercise_goals j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.access_tier='free'),'[]'),
      'routine_body_areas', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'body_area_id',j.body_area_id,'relevance_weight',j.relevance_weight)) from public.routine_body_areas j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]'),
      'routine_goals', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'goal_id',j.goal_id,'relevance_weight',j.relevance_weight)) from public.routine_goals j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]'),
      'routine_positions', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'position_id',j.position_id)) from public.routine_positions j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]'),
      'routine_equipment', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'equipment_id',j.equipment_id)) from public.routine_equipment j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.access_tier='free' and x.published_at<=now()),'[]')
    )
  from selected r;
end
$$;

revoke all on function public.get_next_free_content_release(bigint, text) from public;
grant execute on function public.get_next_free_content_release(bigint, text) to anon, authenticated;
revoke create on schema public from public, anon, authenticated;

do $$
declare fn regprocedure;
begin
  foreach fn in array array[
    'public.release_is_available(bigint,text)'::regprocedure,
    'public.get_next_free_content_release(bigint,text)'::regprocedure,
    'public.start_routine_session(uuid,uuid,integer,uuid,text,text)'::regprocedure,
    'public.complete_routine_session(uuid,text)'::regprocedure
  ] loop
    if not (select prosecdef and coalesce(proconfig,array[]::text[]) @> array['search_path=public, pg_temp'] from pg_proc where oid=fn) then
      raise exception 'RAHA-022 deployment blocked: unsafe SECURITY DEFINER function %', fn;
    end if;
  end loop;
  if has_schema_privilege('anon','public','create') or has_schema_privilege('authenticated','public','create') then
    raise exception 'RAHA-022 deployment blocked: API roles retain CREATE on public';
  end if;
end $$;

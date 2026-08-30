-- RAHA-024: additive, client-safe atomic catalog-release contract.
--
-- Canonical manifest v1 is the UTF-8 encoding of `manifest::text`, where
-- `manifest` is the jsonb returned by content_release_manifest(). PostgreSQL
-- jsonb orders object keys deterministically; every array below has an
-- explicit stable ORDER BY. Clients that independently construct a manifest
-- MUST use that same JSONB textual form: object keys sorted by UTF-8 byte
-- length and then bytewise UTF-8 order (the PostgreSQL jsonb comparator), one
-- ASCII space after ':' and ',', no whitespace after '[' or before ']', JSON strings
-- escaped per RFC 8259, and timestamps copied as JSON strings (not reparsed).
-- The checksum is lower-case hex SHA-256 of those UTF-8 bytes.

alter table public.exercises
  add column if not exists safety_approved_at timestamptz;
alter table public.routines
  add column if not exists safety_approved_at timestamptz;
alter table public.media_assets
  add column if not exists delivery_reference uuid not null default gen_random_uuid(),
  add constraint media_assets_delivery_reference_key unique (delivery_reference);

-- Tombstones remove retired items from a local current catalog while the
-- source rows remain available to server-owned historical session references.
create table public.content_release_tombstones (
  release_id bigint not null references public.content_releases(id) on delete restrict,
  entity_type text not null check (entity_type in ('exercise', 'routine', 'media_asset')),
  entity_id uuid not null,
  retired_at timestamptz not null,
  primary key (release_id, entity_type, entity_id)
);
alter table public.content_release_tombstones enable row level security;

create function public.content_release_manifest(p_release_id bigint)
returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'contract_version', 'raha-content-release-v1',
    'release', jsonb_build_object(
      'id', r.id, 'version', r.version, 'published_at', r.published_at,
      'minimum_app_version', r.minimum_app_version
    ),
    'exercises', coalesce((select jsonb_agg(jsonb_build_object(
      'id', e.id, 'public_id', e.public_id, 'status', e.status,
      'access_tier', e.access_tier, 'safety_approved', true,
      'difficulty', e.difficulty, 'updated_at', e.updated_at
    ) order by e.public_id) from public.exercises e
      where e.release_id = r.id and e.status = 'published' and e.safety_approved_at is not null), '[]'::jsonb),
    'exercise_translations', coalesce((select jsonb_agg(jsonb_build_object(
      'exercise_id', t.exercise_id, 'locale', t.locale, 'name', t.name,
      'description', t.description, 'short_cue', t.short_cue
    ) order by e.public_id, t.locale) from public.exercise_translations t join public.exercises e on e.id=t.exercise_id
      where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'media_assets', coalesce((select jsonb_agg(jsonb_build_object(
      'id', m.id, 'exercise_id', m.exercise_id, 'delivery_reference', m.delivery_reference,
      'status', m.status, 'media_type', m.media_type, 'mime_type', m.mime_type,
      'width', m.width, 'height', m.height, 'duration_ms', m.duration_ms,
      'checksum_sha256', m.checksum_sha256, 'is_preferred', m.is_preferred,
      'updated_at', m.updated_at
    ) order by e.public_id, m.id) from public.media_assets m join public.exercises e on e.id=m.exercise_id
      where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null and m.status='published'), '[]'::jsonb),
    'routines', coalesce((select jsonb_agg(jsonb_build_object(
      'id', x.id, 'public_id', x.public_id, 'status', x.status,
      'access_tier', x.access_tier, 'safety_approved', true, 'difficulty', x.difficulty,
      'estimated_duration_seconds', x.estimated_duration_seconds, 'version', x.version,
      'published_at', x.published_at, 'updated_at', x.updated_at
    ) order by x.public_id) from public.routines x
      where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_translations', coalesce((select jsonb_agg(jsonb_build_object(
      'routine_id', t.routine_id, 'locale', t.locale, 'name', t.name, 'summary', t.summary
    ) order by x.public_id, t.locale) from public.routine_translations t join public.routines x on x.id=t.routine_id
      where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_steps', coalesce((select jsonb_agg(jsonb_build_object(
      'id', s.id, 'routine_id', s.routine_id, 'exercise_id', s.exercise_id,
      'position', s.position, 'duration_seconds', s.duration_seconds,
      'repetition_count', s.repetition_count, 'rest_after_seconds', s.rest_after_seconds,
      'side_mode', s.side_mode, 'is_optional', s.is_optional
    ) order by x.public_id, s.position) from public.routine_steps s join public.routines x on x.id=s.routine_id
      join public.exercises e on e.id=s.exercise_id
      where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null
        and e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'body_areas', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.body_areas x where x.active), '[]'::jsonb),
    'body_area_translations', coalesce((select jsonb_agg(jsonb_build_object('body_area_id',t.body_area_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.body_area_translations t join public.body_areas x on x.id=t.body_area_id where x.active), '[]'::jsonb),
    'goals', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.goals x where x.active), '[]'::jsonb),
    'goal_translations', coalesce((select jsonb_agg(jsonb_build_object('goal_id',t.goal_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.goal_translations t join public.goals x on x.id=t.goal_id where x.active), '[]'::jsonb),
    'movement_positions', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.movement_positions x where x.active), '[]'::jsonb),
    'movement_position_translations', coalesce((select jsonb_agg(jsonb_build_object('position_id',t.position_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.movement_position_translations t join public.movement_positions x on x.id=t.position_id where x.active), '[]'::jsonb),
    'equipment', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.equipment x where x.active), '[]'::jsonb),
    'equipment_translations', coalesce((select jsonb_agg(jsonb_build_object('equipment_id',t.equipment_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.equipment_translations t join public.equipment x on x.id=t.equipment_id where x.active), '[]'::jsonb),
    'routine_contexts', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.routine_contexts x where x.active), '[]'::jsonb),
    'routine_context_translations', coalesce((select jsonb_agg(jsonb_build_object('context_id',t.context_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.routine_context_translations t join public.routine_contexts x on x.id=t.context_id where x.active), '[]'::jsonb),
    'tags', coalesce((select jsonb_agg(jsonb_build_object('id',x.id,'key',x.key,'sort_order',x.sort_order,'active',x.active) order by x.key) from public.tags x where x.active), '[]'::jsonb),
    'tag_translations', coalesce((select jsonb_agg(jsonb_build_object('tag_id',t.tag_id,'locale',t.locale,'name',t.name) order by x.key,t.locale) from public.tag_translations t join public.tags x on x.id=t.tag_id where x.active), '[]'::jsonb),
    'exercise_body_areas', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'body_area_id',j.body_area_id,'relevance_weight',j.relevance_weight) order by e.public_id,j.body_area_id) from public.exercise_body_areas j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'exercise_positions', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'position_id',j.position_id) order by e.public_id,j.position_id) from public.exercise_positions j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'exercise_equipment', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'equipment_id',j.equipment_id) order by e.public_id,j.equipment_id) from public.exercise_equipment j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'exercise_goals', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'goal_id',j.goal_id) order by e.public_id,j.goal_id) from public.exercise_goals j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'exercise_tags', coalesce((select jsonb_agg(jsonb_build_object('exercise_id',j.exercise_id,'tag_id',j.tag_id) order by e.public_id,j.tag_id) from public.exercise_tags j join public.exercises e on e.id=j.exercise_id where e.release_id=r.id and e.status='published' and e.safety_approved_at is not null), '[]'::jsonb),
    'routine_body_areas', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'body_area_id',j.body_area_id,'relevance_weight',j.relevance_weight) order by x.public_id,j.body_area_id) from public.routine_body_areas j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_goals', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'goal_id',j.goal_id,'relevance_weight',j.relevance_weight) order by x.public_id,j.goal_id) from public.routine_goals j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_positions', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'position_id',j.position_id) order by x.public_id,j.position_id) from public.routine_positions j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_context_memberships', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'context_id',j.context_id) order by x.public_id,j.context_id) from public.routine_context_memberships j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'routine_equipment', coalesce((select jsonb_agg(jsonb_build_object('routine_id',j.routine_id,'equipment_id',j.equipment_id) order by x.public_id,j.equipment_id) from public.routine_equipment j join public.routines x on x.id=j.routine_id where x.release_id=r.id and x.status='published' and x.published_at<=now() and x.safety_approved_at is not null), '[]'::jsonb),
    'tombstones', coalesce((select jsonb_agg(jsonb_build_object('entity_type',t.entity_type,'entity_id',t.entity_id,'retired_at',t.retired_at) order by t.entity_type,t.entity_id) from public.content_release_tombstones t where t.release_id=r.id), '[]'::jsonb)
  ) from public.content_releases r where r.id=p_release_id;
$$;

create function public.content_release_contract_is_valid(p_release_id bigint)
returns boolean language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from public.content_releases where id=p_release_id)
    and not exists (select 1 from public.exercises e where e.release_id=p_release_id and e.status='published' and (e.safety_approved_at is null or not exists (select 1 from public.exercise_translations t where t.exercise_id=e.id and t.locale='ar') or not exists (select 1 from public.exercise_translations t where t.exercise_id=e.id and t.locale='en') or not exists (select 1 from public.media_assets m where m.exercise_id=e.id and m.status='published' and m.is_preferred)))
    and not exists (select 1 from public.routines x where x.release_id=p_release_id and x.status='published' and (x.published_at is null or x.safety_approved_at is null or not exists (select 1 from public.routine_translations t where t.routine_id=x.id and t.locale='ar') or not exists (select 1 from public.routine_translations t where t.routine_id=x.id and t.locale='en') or not exists (select 1 from public.routine_steps s join public.exercises e on e.id=s.exercise_id where s.routine_id=x.id and e.release_id=p_release_id and e.status='published' and e.safety_approved_at is not null) or exists (select 1 from public.routine_steps s left join public.exercises e on e.id=s.exercise_id where s.routine_id=x.id and (e.id is null or e.release_id<>p_release_id or e.status<>'published' or e.safety_approved_at is null))));
$$;

create function public.get_next_content_release(after_release_id bigint, app_version text)
returns table (release_id bigint, version text, published_at timestamptz, minimum_app_version text, manifest_checksum text, manifest jsonb)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if public.semver_parts(app_version) is null then raise exception 'app_version must be MAJOR.MINOR.PATCH'; end if;
  return query
  select r.id, r.version, r.published_at, r.minimum_app_version, r.manifest_checksum, m.manifest
  from public.content_releases r
  cross join lateral (select public.content_release_manifest(r.id) as manifest) m
  where r.id > coalesce(after_release_id, 0)
    and public.release_is_available(r.id, app_version)
    and public.content_release_contract_is_valid(r.id)
    and encode(digest(convert_to(m.manifest::text, 'UTF8'), 'sha256'), 'hex') = r.manifest_checksum
  order by r.id limit 1;
end $$;

revoke all on function public.content_release_manifest(bigint), public.content_release_contract_is_valid(bigint), public.get_next_content_release(bigint,text) from public;
grant execute on function public.get_next_content_release(bigint,text) to anon, authenticated;

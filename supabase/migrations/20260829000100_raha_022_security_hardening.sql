-- RAHA-022 forward security hardening. Apply after 20260829000000.

create function public.semver_parts(value text) returns integer[]
language sql immutable strict set search_path = '' as $$
  select case when value ~ '^(0|[1-9][0-9]{0,8})\.(0|[1-9][0-9]{0,8})\.(0|[1-9][0-9]{0,8})$'
    then array[(regexp_match(value, '^(\d+)\.(\d+)\.(\d+)$'))[1]::integer, (regexp_match(value, '^(\d+)\.(\d+)\.(\d+)$'))[2]::integer, (regexp_match(value, '^(\d+)\.(\d+)\.(\d+)$'))[3]::integer]
  end
$$;

create function public.release_is_available(release_id bigint, app_version text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select public.semver_parts(app_version) is not null and exists (
    select 1 from public.content_releases r
    where r.id = release_id and r.published_at <= now()
      and (r.minimum_app_version is null or public.semver_parts(app_version) >= public.semver_parts(r.minimum_app_version))
  )
$$;
revoke all on function public.semver_parts(text) from public;
revoke all on function public.release_is_available(bigint, text) from public;

-- No direct REST catalog reads: release compatibility is evaluated only here.
revoke select on public.content_releases, public.exercises, public.exercise_translations, public.media_assets, public.body_areas, public.goals, public.movement_positions, public.equipment, public.routine_contexts, public.tags, public.body_area_translations, public.goal_translations, public.movement_position_translations, public.equipment_translations, public.routine_context_translations, public.tag_translations, public.routines, public.routine_translations, public.routine_steps, public.exercise_body_areas, public.exercise_positions, public.exercise_equipment, public.exercise_goals, public.exercise_tags, public.routine_body_areas, public.routine_goals, public.routine_positions, public.routine_context_memberships, public.routine_equipment, public.recommendation_rule_sets, public.achievements, public.achievement_translations from anon, authenticated;
drop policy if exists catalog_releases_read on public.content_releases; drop policy if exists catalog_exercises_read on public.exercises; drop policy if exists catalog_routines_read on public.routines; drop policy if exists catalog_media_read on public.media_assets; drop policy if exists catalog_exercise_translations_read on public.exercise_translations; drop policy if exists catalog_routine_translations_read on public.routine_translations; drop policy if exists catalog_routine_steps_read on public.routine_steps; drop policy if exists catalog_rule_sets_read on public.recommendation_rule_sets; drop policy if exists catalog_achievements_read on public.achievements; drop policy if exists catalog_achievement_translations_read on public.achievement_translations;
drop policy if exists catalog_body_areas_read on public.body_areas; drop policy if exists catalog_goals_read on public.goals; drop policy if exists catalog_positions_read on public.movement_positions; drop policy if exists catalog_equipment_read on public.equipment; drop policy if exists catalog_contexts_read on public.routine_contexts; drop policy if exists catalog_tags_read on public.tags; drop policy if exists catalog_body_area_translations_read on public.body_area_translations; drop policy if exists catalog_goal_translations_read on public.goal_translations; drop policy if exists catalog_position_translations_read on public.movement_position_translations; drop policy if exists catalog_equipment_translations_read on public.equipment_translations; drop policy if exists catalog_context_translations_read on public.routine_context_translations; drop policy if exists catalog_tag_translations_read on public.tag_translations;
drop policy if exists catalog_exercise_body_areas_read on public.exercise_body_areas; drop policy if exists catalog_exercise_positions_read on public.exercise_positions; drop policy if exists catalog_exercise_equipment_read on public.exercise_equipment; drop policy if exists catalog_exercise_goals_read on public.exercise_goals; drop policy if exists catalog_exercise_tags_read on public.exercise_tags; drop policy if exists catalog_routine_body_areas_read on public.routine_body_areas; drop policy if exists catalog_routine_goals_read on public.routine_goals; drop policy if exists catalog_routine_positions_read on public.routine_positions; drop policy if exists catalog_routine_contexts_read on public.routine_context_memberships; drop policy if exists catalog_routine_equipment_read on public.routine_equipment;

create function public.get_next_free_content_release(after_release_id bigint, app_version text)
returns table (release_id bigint, version text, published_at timestamptz, manifest_checksum text, manifest jsonb)
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare selected_release public.content_releases%rowtype;
begin
  if public.semver_parts(app_version) is null then
    raise exception 'app_version must be MAJOR.MINOR.PATCH';
  end if;
  select r.* into selected_release from public.content_releases r
  where r.id > coalesce(after_release_id, 0) and public.release_is_available(r.id, app_version)
  order by r.id limit 1;
  if not found then return; end if;
  return query select selected_release.id, selected_release.version, selected_release.published_at, selected_release.manifest_checksum,
    jsonb_build_object(
      'exercises', coalesce((select jsonb_agg(jsonb_build_object('id', e.id, 'public_id', e.public_id, 'difficulty', e.difficulty, 'updated_at', e.updated_at)) from public.exercises e where e.release_id = selected_release.id and e.status = 'published' and e.access_tier = 'free'), '[]'::jsonb),
      'exercise_translations', coalesce((select jsonb_agg(jsonb_build_object('exercise_id', t.exercise_id, 'locale', t.locale, 'name', t.name, 'description', t.description, 'short_cue', t.short_cue)) from public.exercise_translations t join public.exercises e on e.id = t.exercise_id where e.release_id = selected_release.id and e.status = 'published' and e.access_tier = 'free'), '[]'::jsonb),
      'media_assets', coalesce((select jsonb_agg(jsonb_build_object('id', m.id, 'exercise_id', m.exercise_id, 'media_type', m.media_type, 'mime_type', m.mime_type, 'width', m.width, 'height', m.height, 'duration_ms', m.duration_ms, 'checksum_sha256', m.checksum_sha256, 'is_preferred', m.is_preferred, 'updated_at', m.updated_at)) from public.media_assets m join public.exercises e on e.id = m.exercise_id where e.release_id = selected_release.id and e.status = 'published' and e.access_tier = 'free' and m.status = 'published'), '[]'::jsonb),
      'routines', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'public_id', r.public_id, 'difficulty', r.difficulty, 'estimated_duration_seconds', r.estimated_duration_seconds, 'version', r.version, 'updated_at', r.updated_at)) from public.routines r where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now()), '[]'::jsonb),
      'routine_translations', coalesce((select jsonb_agg(jsonb_build_object('routine_id', t.routine_id, 'locale', t.locale, 'name', t.name, 'summary', t.summary)) from public.routine_translations t join public.routines r on r.id = t.routine_id where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now()), '[]'::jsonb),
      'routine_steps', coalesce((select jsonb_agg(jsonb_build_object('id', s.id, 'routine_id', s.routine_id, 'exercise_id', s.exercise_id, 'position', s.position, 'duration_seconds', s.duration_seconds, 'repetition_count', s.repetition_count, 'rest_after_seconds', s.rest_after_seconds, 'side_mode', s.side_mode, 'is_optional', s.is_optional)) from public.routine_steps s join public.routines r on r.id = s.routine_id join public.exercises e on e.id = s.exercise_id where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now() and e.status = 'published' and e.access_tier = 'free' and public.release_is_available(e.release_id, app_version)), '[]'::jsonb),
      'body_areas', coalesce((select jsonb_agg(jsonb_build_object('id', b.id, 'key', b.key, 'sort_order', b.sort_order, 'active', b.active)) from public.body_areas b where b.active), '[]'::jsonb),
      'goals', coalesce((select jsonb_agg(jsonb_build_object('id', g.id, 'key', g.key, 'sort_order', g.sort_order, 'active', g.active)) from public.goals g where g.active), '[]'::jsonb),
      'exercise_body_areas', coalesce((select jsonb_agg(jsonb_build_object('exercise_id', x.exercise_id, 'body_area_id', x.body_area_id, 'relevance_weight', x.relevance_weight)) from public.exercise_body_areas x join public.exercises e on e.id = x.exercise_id where e.release_id = selected_release.id and e.status = 'published' and e.access_tier = 'free'), '[]'::jsonb),
      'routine_body_areas', coalesce((select jsonb_agg(jsonb_build_object('routine_id', x.routine_id, 'body_area_id', x.body_area_id, 'relevance_weight', x.relevance_weight)) from public.routine_body_areas x join public.routines r on r.id = x.routine_id where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now()), '[]'::jsonb),
      'routine_goals', coalesce((select jsonb_agg(jsonb_build_object('routine_id', x.routine_id, 'goal_id', x.goal_id, 'relevance_weight', x.relevance_weight)) from public.routine_goals x join public.routines r on r.id = x.routine_id where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now()), '[]'::jsonb),
      'routine_positions', coalesce((select jsonb_agg(jsonb_build_object('routine_id', x.routine_id, 'position_id', x.position_id)) from public.routine_positions x join public.routines r on r.id = x.routine_id where r.release_id = selected_release.id and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now()), '[]'::jsonb)
    );
end $$;
revoke all on function public.get_next_free_content_release(bigint, text) from public;
grant execute on function public.get_next_free_content_release(bigint, text) to anon, authenticated;

-- Mobile clients may create/update only resumable state, or explicitly abandon it.
drop policy own_sessions on public.routine_sessions;
create policy own_sessions_read on public.routine_sessions for select to authenticated using (user_id = auth.uid());
create policy own_sessions_insert on public.routine_sessions for insert to authenticated with check (user_id = auth.uid() and status = 'in_progress' and completed_at is null and actual_duration_seconds = 0 and steps_completed = 0 and steps_partial = 0 and steps_skipped = 0);
create policy own_sessions_update on public.routine_sessions for update to authenticated using (user_id = auth.uid() and status = 'in_progress') with check (user_id = auth.uid() and status in ('in_progress', 'abandoned') and (status = 'in_progress' or completed_at is not null));
create policy own_sessions_delete on public.routine_sessions for delete to authenticated using (user_id = auth.uid() and status = 'in_progress');
revoke update on public.routine_sessions from authenticated;
grant update (status, completed_at) on public.routine_sessions to authenticated;

drop policy own_session_steps on public.session_steps;
create policy own_session_steps_read on public.session_steps for select to authenticated using (exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid()));
create policy own_session_steps_write on public.session_steps for all to authenticated using (exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid() and s.status = 'in_progress')) with check (exists (select 1 from public.routine_sessions s join public.routine_steps rs on rs.id = routine_step_id where s.id = session_id and s.user_id = auth.uid() and s.status = 'in_progress' and rs.routine_id = s.routine_id and rs.exercise_id = exercise_id_snapshot and rs.position = position_snapshot and (target_duration_seconds is null or rs.duration_seconds = target_duration_seconds)));

create function public.complete_routine_session(p_session_id uuid, p_completion_policy_version text)
returns public.session_status
language plpgsql security definer set search_path = public, pg_temp as $$
declare session_row public.routine_sessions%rowtype; expected_steps integer; recorded_steps integer; credited_seconds integer; completed_count integer; partial_count integer; skipped_count integer; outcome public.session_status;
begin
  select * into session_row from public.routine_sessions where id = p_session_id for update;
  if not found or session_row.user_id <> auth.uid() then raise exception 'session not found'; end if;
  if session_row.status <> 'in_progress' then raise exception 'session is terminal'; end if;
  if p_completion_policy_version <> 'raha_001_v1' then raise exception 'unsupported completion policy'; end if;
  select count(*) into expected_steps from public.routine_steps where routine_id = session_row.routine_id;
  select count(*), coalesce(sum(case when ss.target_duration_seconds is null then ss.active_duration_seconds else least(ss.active_duration_seconds, ss.target_duration_seconds) end), 0), count(*) filter (where ss.status = 'completed'), count(*) filter (where ss.status = 'partial'), count(*) filter (where ss.status = 'skipped') into recorded_steps, credited_seconds, completed_count, partial_count, skipped_count
  from public.session_steps ss join public.routine_steps rs on rs.id = ss.routine_step_id
  where ss.session_id = p_session_id and rs.routine_id = session_row.routine_id and rs.exercise_id = ss.exercise_id_snapshot and rs.position = ss.position_snapshot and (ss.target_duration_seconds is null or ss.target_duration_seconds = rs.duration_seconds);
  if recorded_steps <> expected_steps or recorded_steps <> (select count(*) from public.session_steps where session_id = p_session_id) then raise exception 'session steps do not match routine'; end if;
  select case when credited_seconds >= r.estimated_duration_seconds * 0.80 and skipped_count <= floor(expected_steps * 0.20) and completed_count + partial_count + skipped_count = expected_steps then 'completed'::public.session_status else 'abandoned'::public.session_status end into outcome from public.routines r where r.id = session_row.routine_id;
  update public.routine_sessions set status = outcome, completed_at = now(), target_duration_seconds = (select estimated_duration_seconds from public.routines where id = session_row.routine_id), actual_duration_seconds = least(credited_seconds, (select estimated_duration_seconds from public.routines where id = session_row.routine_id)), total_step_count_snapshot = expected_steps, steps_completed = completed_count, steps_partial = partial_count, steps_skipped = skipped_count, completion_policy_version = p_completion_policy_version where id = p_session_id;
  return outcome;
end $$;
revoke all on function public.complete_routine_session(uuid, text) from public;
grant execute on function public.complete_routine_session(uuid, text) to authenticated;

-- Account deletion is deliberately reserved for a later verified workflow.
drop policy own_profiles on public.profiles;
create policy own_profiles_read on public.profiles for select to authenticated using (user_id = auth.uid());
create policy own_profiles_insert on public.profiles for insert to authenticated with check (user_id = auth.uid());
create policy own_profiles_update on public.profiles for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
revoke delete on public.profiles from authenticated;

create index provider_exercises_exercise_id on public.provider_exercises(exercise_id);
create index routine_steps_exercise_id on public.routine_steps(exercise_id);
create index recommendations_check_in_id on public.recommendations(check_in_id);
create index recommendations_routine_id on public.recommendations(routine_id);
create index recommendations_engine_version on public.recommendations(engine_version);
create index routine_sessions_routine_id on public.routine_sessions(routine_id);
create index routine_sessions_recommendation_id on public.routine_sessions(recommendation_id);
create index session_steps_routine_step_id on public.session_steps(routine_step_id);
create index session_steps_exercise_snapshot_id on public.session_steps(exercise_id_snapshot);

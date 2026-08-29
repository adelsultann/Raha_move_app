-- RAHA-022 approved MVP contract: timed steps, server-authorized starts, and expiry.

alter table public.routine_steps add constraint routine_steps_timed_only check (duration_seconds is not null and repetition_count is null);
alter table public.routine_steps alter column duration_seconds set not null;
alter table public.session_steps add constraint session_steps_timed_target check (target_duration_seconds is not null);
alter table public.session_steps alter column target_duration_seconds set not null;
alter table public.routine_sessions add column last_credited_at timestamptz not null default now();
create index routine_sessions_expiry on public.routine_sessions(status, last_credited_at) where status = 'in_progress';

create function public.record_session_credit_activity() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_op = 'INSERT' and new.active_duration_seconds > 0 then
    update public.routine_sessions set last_credited_at = now() where id = new.session_id and status = 'in_progress';
  elsif tg_op = 'UPDATE' and new.active_duration_seconds > old.active_duration_seconds then
    update public.routine_sessions set last_credited_at = now() where id = new.session_id and status = 'in_progress';
  end if;
  return new;
end $$;
create trigger session_steps_record_credit after insert or update of active_duration_seconds on public.session_steps for each row execute function public.record_session_credit_activity();
revoke all on function public.record_session_credit_activity() from public;

drop policy own_sessions_insert on public.routine_sessions;
revoke insert on public.routine_sessions from authenticated;

create function public.start_routine_session(p_session_id uuid, p_routine_id uuid, p_routine_version integer, p_recommendation_id uuid, p_source text, p_app_version text)
returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare routine_row public.routines%rowtype; existing_row public.routine_sessions%rowtype; step_count integer;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if public.semver_parts(p_app_version) is null then raise exception 'app_version must be MAJOR.MINOR.PATCH'; end if;
  if p_source not in ('recommendation','explore','saved','repeat','bundled') then raise exception 'invalid session source'; end if;
  select * into existing_row from public.routine_sessions where id = p_session_id;
  if found then
    if existing_row.user_id = auth.uid() and existing_row.routine_id = p_routine_id and existing_row.routine_version = p_routine_version then return existing_row.id; end if;
    raise exception 'session id already belongs to another session';
  end if;
  select * into routine_row from public.routines r
  where r.id = p_routine_id and r.version = p_routine_version and r.status = 'published' and r.access_tier = 'free' and r.published_at <= now() and public.release_is_available(r.release_id, p_app_version);
  if not found then raise exception 'routine is unavailable'; end if;
  if p_recommendation_id is not null and not exists (select 1 from public.recommendations x where x.id = p_recommendation_id and x.user_id = auth.uid() and x.routine_id = p_routine_id) then raise exception 'recommendation is unavailable'; end if;
  if exists (select 1 from public.routine_steps s left join public.exercises e on e.id = s.exercise_id where s.routine_id = p_routine_id and (e.status is distinct from 'published'::public.content_status or e.access_tier is distinct from 'free'::public.access_tier or not public.release_is_available(e.release_id, p_app_version))) then raise exception 'routine is unavailable'; end if;
  select count(*) into step_count from public.routine_steps where routine_id = p_routine_id;
  if step_count = 0 then raise exception 'routine has no steps'; end if;
  insert into public.routine_sessions(id,user_id,routine_id,routine_version,recommendation_id,status,started_at,target_duration_seconds,actual_duration_seconds,total_step_count_snapshot,steps_completed,steps_partial,steps_skipped,completion_policy_version,source,last_credited_at)
  values (p_session_id,auth.uid(),p_routine_id,p_routine_version,p_recommendation_id,'in_progress',now(),routine_row.estimated_duration_seconds,0,step_count,0,0,0,'raha_001_v1',p_source,now());
  return p_session_id;
end $$;
revoke all on function public.start_routine_session(uuid, uuid, integer, uuid, text, text) from public;
grant execute on function public.start_routine_session(uuid, uuid, integer, uuid, text, text) to authenticated;

create function public.expire_my_stale_routine_sessions()
returns setof uuid
language sql security definer set search_path = public, pg_temp as $$
  update public.routine_sessions set status = 'abandoned', completed_at = now()
  where user_id = auth.uid() and status = 'in_progress' and last_credited_at <= now() - interval '24 hours'
  returning id
$$;
create function public.expire_stale_routine_sessions()
returns setof uuid
language sql security definer set search_path = public, pg_temp as $$
  update public.routine_sessions set status = 'abandoned', completed_at = now()
  where status = 'in_progress' and last_credited_at <= now() - interval '24 hours'
  returning id
$$;
revoke all on function public.expire_my_stale_routine_sessions() from public;
revoke all on function public.expire_stale_routine_sessions() from public;
grant execute on function public.expire_my_stale_routine_sessions() to authenticated;
grant execute on function public.expire_stale_routine_sessions() to service_role;

-- Minimum-version input is caller-selectable; it only filters free public manifests and cannot expose private metadata.
create or replace function public.complete_routine_session(p_session_id uuid, p_completion_policy_version text)
returns public.session_status
language plpgsql security definer set search_path = public, pg_temp as $$
declare session_row public.routine_sessions%rowtype; expected_steps integer; recorded_steps integer; credited_seconds integer; completed_count integer; partial_count integer; skipped_count integer; outcome public.session_status;
begin
  select * into session_row from public.routine_sessions where id = p_session_id for update;
  if not found or session_row.user_id <> auth.uid() then raise exception 'session not found'; end if;
  if session_row.status <> 'in_progress' then raise exception 'session is terminal'; end if;
  if p_completion_policy_version <> 'raha_001_v1' then raise exception 'unsupported completion policy'; end if;
  select count(*) into expected_steps from public.routine_steps where routine_id = session_row.routine_id;
  select count(*), coalesce(sum(least(ss.active_duration_seconds, ss.target_duration_seconds)), 0), count(*) filter (where ss.status = 'completed'), count(*) filter (where ss.status = 'partial'), count(*) filter (where ss.status = 'skipped') into recorded_steps, credited_seconds, completed_count, partial_count, skipped_count from public.session_steps ss join public.routine_steps rs on rs.id = ss.routine_step_id where ss.session_id = p_session_id and rs.routine_id = session_row.routine_id and rs.exercise_id = ss.exercise_id_snapshot and rs.position = ss.position_snapshot and ss.target_duration_seconds = rs.duration_seconds;
  if recorded_steps <> expected_steps or recorded_steps <> (select count(*) from public.session_steps where session_id = p_session_id) then raise exception 'session steps do not match routine'; end if;
  select case when credited_seconds >= r.estimated_duration_seconds * 0.80 and skipped_count <= floor(expected_steps * 0.20) and completed_count + partial_count + skipped_count = expected_steps then 'completed'::public.session_status else 'abandoned'::public.session_status end into outcome from public.routines r where r.id = session_row.routine_id;
  update public.routine_sessions set status = outcome, completed_at = now(), target_duration_seconds = (select estimated_duration_seconds from public.routines where id = session_row.routine_id), actual_duration_seconds = least(credited_seconds, (select estimated_duration_seconds from public.routines where id = session_row.routine_id)), total_step_count_snapshot = expected_steps, steps_completed = completed_count, steps_partial = partial_count, steps_skipped = skipped_count, completion_policy_version = p_completion_policy_version where id = p_session_id;
  return outcome;
end $$;

drop policy own_session_steps_write on public.session_steps;
create policy own_session_steps_write on public.session_steps for all to authenticated using (exists (select 1 from public.routine_sessions s where s.id = session_id and s.user_id = auth.uid() and s.status = 'in_progress')) with check (exists (select 1 from public.routine_sessions s join public.routine_steps rs on rs.id = routine_step_id where s.id = session_id and s.user_id = auth.uid() and s.status = 'in_progress' and rs.routine_id = s.routine_id and rs.exercise_id = exercise_id_snapshot and rs.position = position_snapshot and target_duration_seconds = rs.duration_seconds));

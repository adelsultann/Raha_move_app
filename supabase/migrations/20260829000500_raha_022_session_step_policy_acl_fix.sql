-- RAHA-022: evaluate step membership in trusted code so a client does not need
-- SELECT on private catalog tables merely to satisfy a write policy.
create function public.can_write_own_session_step(
  p_session_id uuid, p_routine_step_id uuid, p_exercise_id uuid,
  p_position smallint, p_target_duration_seconds integer
) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select exists (
    select 1
    from public.routine_sessions s
    join public.routine_steps rs on rs.id = p_routine_step_id
    where s.id = p_session_id
      and s.user_id = auth.uid()
      and s.status = 'in_progress'
      and rs.routine_id = s.routine_id
      and rs.exercise_id = p_exercise_id
      and rs.position = p_position
      and rs.duration_seconds = p_target_duration_seconds
  )
$$;
revoke all on function public.can_write_own_session_step(uuid, uuid, uuid, smallint, integer) from public, anon, authenticated;

drop policy own_session_steps_write on public.session_steps;
create policy own_session_steps_write on public.session_steps for all to authenticated
  using (public.can_write_own_session_step(session_id, routine_step_id, exercise_id_snapshot, position_snapshot, target_duration_seconds))
  with check (public.can_write_own_session_step(session_id, routine_step_id, exercise_id_snapshot, position_snapshot, target_duration_seconds));

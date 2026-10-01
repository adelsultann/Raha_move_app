-- Defer gamification from the first MVP without deleting historical data.
-- A later release must use another forward migration to restore approved
-- point, streak, and achievement rules.

create or replace function public.award_completion_points(p_session_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  -- Intentionally disabled for the simplified MVP.
  return;
end $$;

drop trigger if exists award_achievements_on_completed_session
on public.routine_sessions;

drop trigger if exists refresh_streak_on_completed_session
on public.routine_sessions;

comment on function public.award_completion_points(uuid) is
  'No-op while gamification is deferred from the simplified MVP.';

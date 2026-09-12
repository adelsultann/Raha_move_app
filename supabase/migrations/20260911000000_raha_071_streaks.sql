-- RAHA-071: server-authoritative `streak_v1` projections (forward only).
-- A movement date is derived from an accepted completed session and its
-- validated timezone snapshot. Recovery tokens/days are deliberately absent
-- from the approved MVP policy; clients cannot write this projection.

create or replace function public.streak_v1_projection(
  p_user_id uuid,
  p_at timestamptz default now()
) returns jsonb
language sql stable security definer set search_path = public as $$
  with recursive profile as (
    select case when public.is_valid_iana_timezone(timezone) then timezone else 'UTC' end as tz
    from public.profiles where user_id = p_user_id
  ), days as (
    select distinct (s.completed_at at time zone
      case when public.is_valid_iana_timezone(s.completed_timezone)
        then s.completed_timezone else p.tz end)::date as movement_date
    from public.routine_sessions s cross join profile p
    where s.user_id = p_user_id and s.status = 'completed' and s.completed_at is not null
  ), reference_day as (
    select (p_at at time zone p.tz)::date as today from profile p
  ), ordered as (
    select movement_date, row_number() over (order by movement_date) as sequence from days
  ), runs as (
    select count(*)::integer as length
    from ordered
    group by movement_date - sequence::integer
  ), latest as (
    select max(d.movement_date) as movement_date from days d cross join reference_day r
    where d.movement_date <= r.today
  ), backwards(movement_date, length) as (
    select movement_date, 1 from latest where movement_date is not null
    union all
    select d.movement_date, b.length + 1
    from backwards b join days d on d.movement_date = b.movement_date - 1
  ), current_run as (
    select coalesce(max(b.length), 0)::integer as length from backwards b
  )
  select jsonb_build_object(
    'current_streak_days', case when l.movement_date >= r.today - 1 then c.length else 0 end,
    'longest_streak_days', coalesce((select max(length) from runs), 0),
    'last_movement_date', l.movement_date,
    'rule_version', 'streak_v1',
    'updated_at', p_at
  )
  from reference_day r cross join latest l cross join current_run c
$$;

create or replace function public.refresh_user_streak_v1(p_user_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare projection jsonb;
begin
  select public.streak_v1_projection(p_user_id, now()) into projection;
  insert into public.user_streaks(
    user_id, current_streak_days, longest_streak_days, last_movement_date,
    rule_version, updated_at
  ) values (
    p_user_id,
    coalesce((projection->>'current_streak_days')::integer, 0),
    coalesce((projection->>'longest_streak_days')::integer, 0),
    nullif(projection->>'last_movement_date', '')::date,
    'streak_v1', now()
  ) on conflict (user_id) do update set
    current_streak_days = excluded.current_streak_days,
    longest_streak_days = excluded.longest_streak_days,
    last_movement_date = excluded.last_movement_date,
    rule_version = excluded.rule_version,
    updated_at = excluded.updated_at;
end $$;

create or replace function public.refresh_streak_on_completed_session()
returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'completed' then
    perform public.refresh_user_streak_v1(new.user_id);
  end if;
  return new;
end $$;

drop trigger if exists refresh_streak_on_completed_session on public.routine_sessions;
create trigger refresh_streak_on_completed_session
after insert or update of status, completed_at, completed_timezone on public.routine_sessions
for each row when (new.status = 'completed')
execute function public.refresh_streak_on_completed_session();

-- Versioned migration: re-project accepted historical sessions without trusting
-- device clocks or rewriting their captured dates.
select public.refresh_user_streak_v1(user_id) from public.profiles;

-- Expose the persisted server result only through the existing trusted sync
-- envelope. The raw helpers remain unavailable to mobile roles.
create or replace function public.sync_authoritative_projections(p_user_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'points', coalesce((select jsonb_agg(jsonb_build_object('id',id,'points',points,'reason_code',reason_code,'rule_version',rule_version,'source_type',source_type,'source_id',source_id,'created_at',created_at) order by created_at,id) from public.point_ledger where user_id=p_user_id), '[]'::jsonb),
    'points_balance', coalesce((select sum(points)::integer from public.point_ledger where user_id=p_user_id), 0),
    'weekly_progress', public.weekly_movement_progress(p_user_id),
    'achievements', coalesce((select jsonb_agg(jsonb_build_object('achievement_id',achievement_id,'earned_at',earned_at,'source_id',source_id,'criteria_version',criteria_version) order by earned_at,achievement_id) from public.user_achievements where user_id=p_user_id), '[]'::jsonb),
    -- Calculate at trusted server time for every sync response. A persisted
    -- `user_streaks` row is a cache only, so it cannot keep an expired streak
    -- alive after a missed day between completions.
    'streak', public.streak_v1_projection(p_user_id),
    'entitlements', coalesce((select jsonb_agg(jsonb_build_object('entitlement_key',entitlement_key,'is_active',is_active,'product_id',product_id,'expires_at',expires_at,'environment',environment,'updated_at',updated_at) order by entitlement_key) from public.user_entitlements where user_id=p_user_id), '[]'::jsonb)
  )
$$;

revoke all on function public.streak_v1_projection(uuid, timestamptz) from public, anon, authenticated;
revoke all on function public.refresh_user_streak_v1(uuid) from public, anon, authenticated;
